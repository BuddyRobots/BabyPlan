class Admin::BooksController < Admin::ApplicationController

  def index
    @keyword = params[:keyword]
    books = @keyword.present? ? Book.where(name: /#{@keyword}/) : Book.all
    @books = auto_paginate(books)
    @books[:data] = @books[:data].map do |e|
      e.book_info
    end
  end

  def show
  end

end
