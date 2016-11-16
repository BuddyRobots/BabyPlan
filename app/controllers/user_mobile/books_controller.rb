class UserMobile::BooksController < UserMobile::ApplicationController
  # search_book
  def index
    if @current_user.client_centers.present?
      @keyword = params[:keyword]
      @lower = params[:lower]
      @upper = params[:upper]
      @books = Book.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
      if @keyword.present?
        @books = @books.where(name: /#{params[:keyword]}/)
      end
      if @lower.present? && @upper.present?
        @books = @books.where(:age_lower_bound.lt => @upper.to_i).where(:age_upper_bound.gt => @lower.to_i)
      end
      @books = auto_paginate(@books)[:data]
    end
  end

  def more
    @keyword = params[:keyword]
    @lower = params[:lower]
    @upper = params[:upper]
    @books = Book.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
    if @keyword.present?
      @books = @books.where(name: /#{params[:keyword]}/)
    end
    if @lower.present? && @upper.present?
      @books = @books.where(:age_lower_bound.lt => @upper.to_i).where(:age_upper_bound.gt => @lower.to_i)
    end
    @books = auto_paginate(@books)[:data]
    @books = @books.map { |e| e.more_info }
    render json: retval_wrapper({more: @books}) and return
  end

  def show
    @book = Book.where(id: params[:id]).first
    @back = params[:back]
  end

  def favorite
    book = Book.where(id: params[:id]).first
    fav = current_user.favorites.where(book: book).first
    fav = fav || current_user.favorites.create(book_id: book.id)
    if params[:favorite].to_s == "true"
      fav.enabled = true
    else
      fav.enabled = false
    end
    fav.save
    render json: retval_wrapper(nil) and return
  end
end
