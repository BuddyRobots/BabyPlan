class Operator::BooksController < Operator::ApplicationController

  def index
    @keyword = params[:keyword]
    book_templates = @keyword.present? ? current_operator.book_templates.where(name: /#{Regexp.escape(@keyword)}/) : current_operator.book_templates.all
    book_templates = book_templates.desc(:created_at)
    @book_templates = auto_paginate(book_templates)
    @book_templates[:data] = @book_templates[:data].map do |b|
      b.book_info
    end
  end

  def new
    
  end

  def show
   
  end

  def create
    retval = BookTemplate.create_book(current_operator, params[:book_template])
    render json: retval_wrapper(retval) and return
  end

  def upload_photo
    @book_template = current_operator.book_templates.where(id: params[:id]).first
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
    @book_template = current_operator.book_templates.where(id: params[:id]).first
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
    @book_template = current_operator.book_templates.where(id: params[:id]).first
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
