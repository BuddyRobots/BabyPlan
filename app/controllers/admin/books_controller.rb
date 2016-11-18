class Admin::BooksController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "book"
  end

  def index
    @book_keyword = params[:book_keyword]
    @transfer_keyword = params[:transfer_keyword]

    books = @book_keyword.present? ? Book.where(name: /#{@book_keyword}/) : Book.all
    @books = auto_paginate(books)
    @books[:data] = @books[:data].map do |e|
      e.book_info
    end

    if @transfer_keyword.present?
      q1 = Transfer.in(in_center_id: Center.where(name: /#{@transfer_keyword}/).map { |e| e.id})
      q2 = Transfer.in(out_center_id: Center.where(name: /#{@transfer_keyword}/).map { |e| e.id})
      transfers = q1.concat(q2).uniq
    else
      transfers = Transfer.all
    end
    @transfers = auto_paginate(transfers)
    @transfers[:data] = @transfers[:data].map do |e|
      e.transfer_info
    end
    @profile=params[:profile]
  end

  def show
    @book = Book.where(id: params[:id]).first
    similar_books = Book.where(isbn: @book.isbn).where(:center_id.ne => @book.center_id)
    @similar_books = auto_paginate(similar_books)
  end

  def show_transfer
  end
end
