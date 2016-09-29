class Staff::CoursesController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "course"
  end

  def index
    @keyword = params[:keyword]
    course_insts = @keyword.present? ? current_center.course_insts.where(name: /#{@keyword}/) : current_center.course_insts.all
    @course_insts = auto_paginate(course_insts)
    @course_insts[:data] = @course_insts[:data].map do |e|
      e.course_inst_info
    end
  end

  def create
    retval = CourseInst.create_course_inst(current_user, current_center, params[:course])
    render json: retval_wrapper(retval) and return
  end

  def new
    @course = Course.where(id: params[:course_id]).first
  end

  def show
    @course_inst = CourseInst.where(id: params[:id]).first
  end

  def update
    @course_inst = CourseInst.where(id: params[:id]).first
    render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return if @course_inst.nil?
    retval = @course_inst.update_info(params[:course_inst])
    render json: retval_wrapper(retval)
  end

  def get_id_by_name
    course_name = params[:course_name]
    scan_result = course_name.scan(/\((.+)\)/)
    if scan_result[0].present?
      code = scan_result[0][0]
      course = Course.where(code: code).first
      if course.present?
        render json: retval_wrapper({ id: course.id.to_s }) and return
      else
        render json: retval_wrapper(ErrCode::COURSE_NOT_EXIST) and return
      end
    else
      render json: retval_wrapper(ErrCode::COURSE_NOT_EXIST) and return
    end
  end

  def set_available
    @course_inst = CourseInst.where(id: params[:id]).first
    retval = ErrCode::COURSE_INST_NOT_EXIST if @course.blank?
    retval = @course_inst.set_available(params[:available])
    render json: retval_wrapper(retval)
  end
end
