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
  end

end
