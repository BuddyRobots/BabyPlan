class Admin::BooksController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "book"
  end

  def index
    @book_keyword = params[:book_keyword]
    params[:page] = params[:stock_page]
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
    params[:page] = params[:transfer_page]
    @transfers = auto_paginate(transfers)
    @transfers[:data] = @transfers[:data].map do |e|
      e.transfer_info
    end
    @profile=params[:profile]

    @book_num = BorrowSetting.first.try(:book_num)
    @borrow_duration = BorrowSetting.first.try(:borrow_duration)
    @latefee_per_day = BorrowSetting.first.try(:latefee_per_day)
    @deposit = BorrowSetting.first.try(:deposit)
  end

  def update_setting
    s = BorrowSetting.first || BorrowSetting.create
    s.book_num = params[:book_num].to_i
    s.borrow_duration = params[:borrow_duration].to_i
    s.latefee_per_day = params[:latefee_per_day].to_f
    s.deposit = params[:deposit].to_i
    s.save
    render json: retval_wrapper(nil) and return
  end

  def show
    # @book = Book.where(id: params[:id]).first
    # similar_books = Book.where(isbn: @book.isbn).where(:center_id.ne => @book.center_id)
    # @similar_books = auto_paginate(similar_books)

    @profile = params[:profile]
    @book = Book.where(id: params[:id]).first
    if @book.nil?
      redirect_to action: :index and return
    end

    stocks = @book.name
    stocks = Book.where(name: stocks).all
    params[:page] = params[:stock_page]
    @stocks = auto_paginate(stocks)
    @stocks[:data] = @stocks[:data].map do |s|
      s.book_info
    end
  end

  def show_transfer
    @transfer = Transfer.where(id: params[:id]).first
    redirect_to action: :index and return if @transfer.blank?
    books_info_detail = @transfer.books_info_detail
    @books_info_detail = auto_paginate(books_info_detail)
  end
end
