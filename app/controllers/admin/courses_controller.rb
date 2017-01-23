class Admin::CoursesController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "course"
  end

  def index
    @keyword = params[:keyword]
    courses = @keyword.present? ? Course.where(name: /#{Regexp.escape(@keyword)}/) : Course.all
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
    course_insts = @course.course_insts
    @course_insts = auto_paginate(course_insts)
    @profile = params[:profile]
  end

  def set_available
    @course = Course.where(id: params[:id]).first
    retval = ErrCode::COURSE_NOT_EXIST if @course.blank?
    retval = @course.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def update
    @course = Course.where(id: params[:id]).first
    render json: retval_wrapper(ErrCode::COURSE_NOT_EXIST) and return if @course.nil?
    retval = @course.update_info(params[:course])
    render json: retval_wrapper(retval)
  end

  def get_calendar
    course_inst = CourseInst.where(id: params[:id]).first
    render json: retval_wrapper({ calendar: course_inst.date_in_calendar }) and return
  end
end
