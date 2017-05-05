class Operator::BooksController < Operator::ApplicationController

  def get_book_templates
    if current_operator.class == User
      BookTemplate.all
    else
      current_operator.book_templates
    end
  end

  def index
    @keyword = params[:keyword]
    book_templates = current_operator.class  == User ? BookTemplate.all : current_operator.book_templates
    book_templates = book_templates.where(name: /#{Regexp.escape(@keyword)}/) if @keyword.present?
    book_templates = book_templates.desc(:created_at)
    @book_templates = auto_paginate(book_templates)
    @book_templates[:data] = @book_templates[:data].map do |b|
      b.book_info
    end
  end

  def new
    
  end

  def show
    @book = BookTemplate.where(id: params[:id]).first
  end

  def create
    retval = BookTemplate.create_book(current_operator, params[:book_template])
    render json: retval_wrapper(retval) and return
  end

  def update
    @book = get_book_templates.where(id: params[:id]).first
    if @book.nil?
      retval = ErrCode::BOOK_NOT_EXIST
      render json: retval_wrapper(retval) and return
    end
    book_template = BookTemplate.where(isbn: params[:book]["isbn"], :id.ne => params[:id])
    if book_template.length > 0
      retval = ErrCode::REPEAT_ISBN
      render json: retval_wrapper(retval) and return
    end
    @book.update_info(params[:book])
    render json: retval_wrapper(retval) and return
  end

  def destroy
    @book = get_book_templates.where(id: params[:id]).first
    if !@book.books.present?
      retval = @book.destroy
      render json: retval_wrapper(nil)
    else
      retval = ErrCode::BOOK_EXIST
      render json: retval_wrapper(retval)
    end
  end

  def upload_photo
    @book_template = get_book_templates.where(id: params[:id]).first
    if @book_template.blank?
      redirect_to action: :index and return
    end
    if params[:has_cover].to_s == "true"
      cover = Cover.new
      cover.cover = params[:cover_file]
      cover.store_cover!
      filepath = cover.cover.file.file
      m = Material.create(path: "/uploads/covers/" + filepath.split('/')[-1])
      @book_template.cover = m
      @book_template.save
    end
    if params[:has_back].to_s == "true"
      back = Back.new
      back.back = params[:back_file]
      back.store_back!
      filepath = back.back.file.file
      m = Material.create(path: "/uploads/backs/" + filepath.split('/')[-1])
      @book_template.back = m
      @book_template.save
    end
    redirect_to action: :show, id: @book_template.id.to_s and return
  end

  def update_cover
    @book_template = get_book_templates.where(id: params[:id]).first
    if @book_template.blank?
      redirect_to action: :index and return
    end
    cover = Cover.new
    cover.cover = params[:cover_file]
    cover.store_cover!
    filepath = cover.cover.file.file
    m = Material.create(path: "/uploads/covers/" + filepath.split('/')[-1])
    @book_template.cover = m
    @book_template.save
    redirect_to action: :show, id: @book_template.id.to_s and return
  end

  def update_back
    @book_template = get_book_templates.where(id: params[:id]).first
    if @book_template.blank?
      redirect_to action: :index and return
    end
    back = Back.new
    back.back = params[:back_file]
    back.store_back!
    filepath = back.back.file.file
    m = Material.create(path: "/uploads/backs/" + filepath.split('/')[-1])
    @book_template.back = m
    @book_template.save
    redirect_to action: :show, id: @book_template.id.to_s and return
  end

end
