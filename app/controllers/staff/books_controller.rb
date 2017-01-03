class Staff::BooksController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "book"
  end

  def index
    @profile = params[:profile]
    @keyword = params[:keyword]
    books = @keyword.present? ? current_center.books.where(name: /#{@keyword}/) : current_center.books.all
    @books = auto_paginate(books)
    @books[:data] = @books[:data].map do |e|
      e.book_info
    end

    params[:page] = params[:borrow_page]
    borrows = BookBorrow.expired.any_in(book_id: books.map { |e| e.id.to_s}) 
    @borrows = auto_paginate(borrows)
  end

  def create
    retval = Book.create_book(current_user, current_center, params[:book])
    render json: retval_wrapper(retval) and return
  end

  def show
    @profile = params[:profile]
    @book = current_center.books.where(id: params[:id]).first
    if @book.nil?
      redirect_to action: :index and return
    end

    reviews = @book.reviews
    if params[:review_type].present?
      reviews = reviews.where(status: params[:review_type].to_i)
    end
    params[:page] = params[:review_page]
    @reviews = auto_paginate(reviews)

    borrows = @book.book_borrows
    params[:page] = params[:borrow_page]
    @borrows = auto_paginate(borrows)

    unreturned = @book.book_borrows.unreturned
    params[:page] = params[:unreturned_page]
    @unreturned = auto_paginate(unreturned)
  end

  def back
    book_borrow = BookBorrow.where(id: params[:id]).first
    retval = book_borrow.back
    render json: retval_wrapper(retval) and return
  end

  def lost
    book_borrow = BookBorrow.where(id: params[:id]).first
    retval = book_borrow.lost
    render json: retval_wrapper(retval) and return
  end

  def update
    @book = current_center.books.where(id: params[:id]).first
    retval = ErrCode::BOOK_NOT_EXIST if @book.nil?
    @book.update_info(params[:book])
    render json: retval_wrapper(retval)
  end

  def new
  end

  def auto_merge
    retval = Book.auto_merge(@current_center)
    render json: retval_wrapper(retval) and return
  end

  def mannual_merge
    retval = Book.mannual_merge(params[:books_id_ary], params[:default_id])
    render json: retval_wrapper(retval) and return
  end

  def merge
    @page = params[:page].to_s
    @keyword = params[:keyword].to_s
    books = params[:keyword].present? ? @current_center.books.any_of({name: /#{params[:keyword]}/}, {author: /#{params[:keyword]}/}) : @current_center.books
    @books = auto_paginate(books)
    @merge_books = (params[:books_id_str] || "").split(',').select { |e| e.present? } .map do |e|
      Book.find(e)
    end
    @books_id_str = params[:books_id_str].to_s
    @books_id_ary = params[:books_id_str].to_s.split(',')
  end

  def set_available
    @book = current_center.books.where(id: params[:id]).first
    retval = ErrCode::BOOK_NOT_EXIST if @book.blank?
    retval = @book.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def upload_photo
    @book = current_center.books.where(id: params[:id]).first
    if @book.blank?
      redirect_to action: :index and return
    end
    if params[:has_cover].to_s == "true"
      cover = Cover.new
      cover.cover = params[:cover_file]
      cover.store_cover!
      filepath = cover.cover.file.file
      m = Material.create(path: "/uploads/covers/" + filepath.split('/')[-1])
      @book.cover = m
      @book.save
    end
    if params[:has_back].to_s == "true"
      back = Back.new
      back.back = params[:back_file]
      logger.info "AAAAAAAAAAAAA"
      logger.info params[:back_file]
      logger.info "AAAAAAAAAAAAA"
      back.store_back!
      filepath = back.back.file.file
      m = Material.create(path: "/uploads/backs/" + filepath.split('/')[-1])
      @book.back = m
      @book.save
    end
    redirect_to action: :show, id: @book.id.to_s and return
  end

  def update_cover
    @book = current_center.books.where(id: params[:id]).first
    if @book.blank?
      redirect_to action: :index and return
    end
    cover = Cover.new
    cover.cover = params[:cover_file]
    cover.store_cover!
    filepath = cover.cover.file.file
    m = Material.create(path: "/uploads/covers/" + filepath.split('/')[-1])
    @book.cover = m
    @book.save
    redirect_to action: :show, id: @book.id.to_s and return
  end

  def update_back
    @book = current_center.books.where(id: params[:id]).first
    if @book.blank?
      redirect_to action: :index and return
    end
    back = Back.new
    back.back = params[:back_file]
    back.store_back!
    filepath = back.back.file.file
    m = Material.create(path: "/uploads/backs/" + filepath.split('/')[-1])
    @book.back = m
    @book.save
    redirect_to action: :show, id: @book.id.to_s and return
  end

  def download_qrcode
    @book = current_center.books.where(id: params[:id]).first
    if @book.blank?
      redirect_to action: :index and return
    end
    send_file(@book.generate_compressed_file(params[:amount].to_i), filename: @book.name + ".pdf")
  end
end
