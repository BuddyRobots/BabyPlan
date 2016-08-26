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
    render json: retval_wrapper(retval)
  end

  def show
  end

  def new
  end
end
