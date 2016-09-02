class Admin::CoursesController < Admin::ApplicationController

  def index
    @keyword = params[:keyword]
    courses = @keyword.present? ? Course.where(name: /#{@keyword}/) : Course.all
    @courses = auto_paginate(courses)
    @courses[:data] = @courses[:data].map do |e|
      e.course_info
    end
  end

  def create
    retval = Course.create_course(params[:course])
    render json: retval_wrapper(retval)
  end

  def new
  end

  def show
  end

end
