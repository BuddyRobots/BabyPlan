class Staff::BooksController < Staff::ApplicationController

  def index
    @keyword = params[:keyword]
    books = @keyword.present? ? current_user.staff_center.books.where(name: /#{@keyword}/) : current_user.staff_center.books.all
    @books = auto_paginate(books)
    @books[:data] = @books[:data].map do |e|
      e.book_info
    end
  end

  def create
    retval = Book.create_book(current_user, params[:book])
    render json: retval_wrapper(retval) and return
  end

  def show
    @book = current_user.staff_center.books.where(id: params[:id]).first
    if @book.nil?
      redirect_to action: :index and return
    end
  end

  def update
    @book = current_user.staff_center.books.where(id: params[:id]).first
    retval = ErrCode::BOOK_NOT_EXIST if @book.nil?
    @book.update_info(params[:book])
    render json: retval_wrapper(retval)
  end

  def new
  end

  def set_available
    @book = current_user.staff_center.books.where(id: params[:id]).first
    retval = ErrCode::BOOK_NOT_EXIST if @book.blank?
    retval = @book.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def update_cover
    @book = current_user.staff_center.books.where(id: params[:id]).first
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
    @book = current_user.staff_center.books.where(id: params[:id]).first
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
end
