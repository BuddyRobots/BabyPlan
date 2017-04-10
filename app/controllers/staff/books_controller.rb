class Staff::BooksController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "book"
  end

  def index
    @profile = params[:profile]
    @keyword = params[:keyword]
    if @keyword.present?
      book_template_id_ary = BookTemplate.where(name: /#{Regexp.escape(@keyword)}/).map { |e| e.id.to_s }
      books = current_center.books.where(:book_template_id.in => book_template_id_ary)
    else
      books = current_center.books.all
    end
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
    @book.update_info(params[:stock])
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

  def code_list
    qr_exports = current_center.qr_exports
    @total = QrExport.qr_amount(qr_exports)
    @qr_exports = auto_paginate(qr_exports)
    @qr_exports[:data] = @qr_exports[:data].map do |e|
      e.message_info
    end
  end

  def clear_list
    current_center.qr_exports.destroy_all
    render json: retval_wrapper(nil) and return
  end

  def destroy
    QrExport.find(id: params[:id]).delete
    redirect_to action: :code_list and return
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

  def download_all_qr
    retval = current_center.batch_export_qrcode
    # retval = retval.slice(6, retval.length)
    render json: retval_wrapper({filename:retval}) and return
  end

  def download_qr_list
    send_file(params[:filename], filename: "图书二维码.pdf")
  end

  def add_to_list
    retval = QrExport.create_qr(current_center, params[:id], params[:num])
    render json: retval_wrapper(retval) and return
  end

  def isbn_search
    if !BookTemplate.where(isbn: params[:isbn]).first.present?
      render json: retval_wrapper(ErrCode::BOOK_NOT_EXIST) and return
    else
      book_template = BookTemplate.where(isbn: params[:isbn]).first
      books = current_center.books.unscoped.where(book_template_id: book_template.id).first 
      if books.present?
        if books.deleted == true
          render json: retval_wrapper(ErrCode::BOOK_DELETE) and return
        else
          render json: retval_wrapper(ErrCode::BOOK_IN_CENTER) and return
        end
      else
        book = BookTemplate.where(isbn: params[:isbn]).first
        retval = book.try(:name)
        render json: retval_wrapper({name:retval}) and return
      end
    end
  end

  def isbn_add_book
    book_template = BookTemplate.where(isbn: params[:isbn]).first
    @books = current_center.books.unscoped.where(book_template_id: book_template.id).first
    if @books.present?
      if @books.deleted == true
        @books.update_attributes(deleted: false, stock: params[:num].to_i)
        @books.save
        Feed.create(book_id: @books.id, name: @books.name, center_id: current_center.id, available: @books.available)
        render json: retval_wrapper(nil) and return
      else
        stock = @books.stock
        @books.update_attribute(:stock, stock + params[:num].to_i)
        @books.save
        render json: retval_wrapper(nil) and return
      end
    else
      retval = Book.add_to_center(current_user, current_center, book_template, params[:num], params[:available])
      render json: retval_wrapper(retval) and return
    end
  end

  def set_delete
    @book = Book.where(id: params[:id]).first
    if @book.stock != 0
      render json: retval_wrapper(ErrCode::BOOK_EXIST) and return
    end
    @book.update_attribute(:deleted, params[:deleted])
    @book.feed.destroy
    @book.favorites.destroy
    @book.save
    render json: retval_wrapper(nil)
  end
end
