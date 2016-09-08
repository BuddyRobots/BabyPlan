class Admin::CentersController < Admin::ApplicationController

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

  def update
    @center = Center.where(id: params[:id]).first
    render json: retval_wrapper(ErrCode::CENTER_NOT_EXIST) and return if @center.nil?
    retval = @center.update_info(params[:center])
    render json: retval_wrapper(retval)
  end
end
