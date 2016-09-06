class Admin::CentersController < Admin::ApplicationController

  def index
    @keyword = params[:keyword]
    centers = @keyword.present? ? Center.where(name: /#{@keyword}/) : Center.all
    @centers = auto_paginate(centers)
    @centers[:data] = @centers[:data].map do |e|
      e.center_info
    end
  end

  def new
  end

  def show
  end

end
