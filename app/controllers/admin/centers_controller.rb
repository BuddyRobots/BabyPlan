class Admin::CentersController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "center"
  end

  def index
    @keyword = params[:keyword]
    centers = @keyword.present? ? Center.where(name: /#{@keyword}/) : Center.all
    @centers = auto_paginate(centers)
    @centers[:data] = @centers[:data].map do |e|
      e.center_info
    end
  end

  def create
    retval = Center.create_center(params[:center])
    render json: retval_wrapper(retval)
  end

  def new
  end

  def show
    @center = Center.where(id: params[:id]).first
  end

  def set_available
    @center = Center.where(id: params[:id]).first
    retval = ErrCode::CENTER_NOT_EXIST if @center.blank?
    retval = @center.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def set_current
    @center = Center.where(id: params[:id]).first
    if @center.present?
      cookies[:center_id] = {
        :value => @center.id.to_s,
        :expires => 24.months.from_now,
        :domain => :all
      }
      redirect_to staff_clients_path and return
    else
      redirect_to admin_centers_path and return
    end
  end

  def update
    @center = Center.where(id: params[:id]).first
    render json: retval_wrapper(ErrCode::CENTER_NOT_EXIST) and return if @center.nil?
    retval = @center.update_info(params[:center])
    render json: retval_wrapper(retval)
  end
end
