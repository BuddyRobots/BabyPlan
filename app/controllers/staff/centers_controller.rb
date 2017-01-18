class Staff::CentersController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "centers"
  end

  def index
   
  end

  def new
    
  end

  def show
    @transfer = Transfer.where(id: params[:id]).first
    if @transfer.nil?
      redirect_to action: :index and return
    end
    books_info_detail = @transfer.books_info_detail
    @books_info_detail = auto_paginate(books_info_detail)
    if @transfer.in_center_id == @current_center.id
      @profile = "in"
    else
      @profile = "out"
    end
  end

  def remove
    @transfer = Transfer.where(id: params[:id]).first
    if @transfer.status == Transfer::PREPARE && @transfer.book_insts.blank?
      @transfer.update_attribute(:deleted, true)
    end
    redirect_to "/staff/transfers?code=" + ErrCode::DONE.to_s and return
  end
end
