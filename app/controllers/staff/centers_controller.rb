class Staff::CentersController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "center"
  end

  def index
    @keyword = params[:keyword]
    centers = @keyword.present? ? Center.any_of({name: /#{@keyword}/},{address: /#{@keyword}/}) : Center.all
    centers = centers.desc(:created_at)
    @centers = auto_paginate(centers)
  end

  def new
    
  end

  def show
    @center = Center.where(id: params[:id]).first
    if @center.nil?
      redirect_to action: :index and return
    end
    course_insts = Center.where(id: params[:id]).first.course_insts
    @course_insts = auto_paginate(course_insts)
    @course_insts[:data] = @course_insts[:data].map do |e|
      e.course_inst_info
    end
    @profile = params[:profile]
  end

  def create
    retval = Center.create_center(current_user, params[:center])
    render json: retval_wrapper(retval) and return
  end

  def destroy
    Center.where(id: params[:id]).delete
    render json: retval_wrapper(nil) and return
  end

  def remove
    @transfer = Transfer.where(id: params[:id]).first
    if @transfer.status == Transfer::PREPARE && @transfer.book_insts.blank?
      @transfer.update_attribute(:deleted, true)
    end
    redirect_to "/staff/transfers?code=" + ErrCode::DONE.to_s and return
  end
end
