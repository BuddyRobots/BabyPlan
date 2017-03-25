class Admin::SchoolsController < Admin::ApplicationController
  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "school"
  end

  def index
    @keyword = params[:keyword]
    params[:page] = params[:open_page]
    schools = @keyword.present? ? School.where(name: /#{Regexp.escape(@keyword)}/).is_available : School.is_available
    @schools = auto_paginate(schools)
    @schools[:data] = @schools[:data].map do |s|
      s.school_info
    end

    params[:page] = params[:close_page]
    close_schools = @keyword.present? ? School.where(name: /#{Regexp.escape(@keyword)}/).where(available: false) : School.where(available: false)
    @close_schools = auto_paginate(close_schools)
    @close_schools[:data] = @close_schools[:data].map do |s|
      s.school_info
    end
    @profile = params[:profile]
  end

  def show
    
  end
  def create
  	retval = School.create_school(params[:school])
    byebug
    render json: retval_wrapper(retval) and return
  end
end