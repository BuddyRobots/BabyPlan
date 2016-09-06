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
    @course = Course.where(id: params[:id]).first
  end

  def set_available
    @course = Course.where(id: params[:id]).first
    retval = ErrCode::COURSE_NOT_EXIST if @course.blank?
    retval = @course.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def update
    @course = Course.where(id: params[:id]).first
    retval = ErrCode::COURSE_NOT_EXIST if @course.nil?
    @course.update_info(params[:course])
    render json: retval_wrapper(retval)
  end
end
