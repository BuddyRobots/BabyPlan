class Admin::BooksController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "book"
  end

  def index
    @keyword = params[:keyword]
    books = @keyword.present? ? Book.where(name: /#{@keyword}/) : Book.all
    @books = auto_paginate(books)
    @books[:data] = @books[:data].map do |e|
      e.book_info
    end
  end

  def show
    @book = Book.where(id: params[:id]).first
    similar_books = Book.where(isbn: @book.isbn).where(:center_id.ne => @book.center_id)
    @similar_books = auto_paginate(similar_books)
  end

end
