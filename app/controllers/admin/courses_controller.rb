class Admin::CoursesController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "course"
  end

  def index
    @keyword = params[:keyword]
    params[:page] = params[:course_inst_page]
    course_insts = @keyword.present? ? CourseInst.where(name: /#{Regexp.escape(@keyword)}/).is_available : CourseInst.is_available
    course_insts = course_insts.desc(:start_course)
    @course_insts = auto_paginate(course_insts)
    @course_insts[:data] = @course_insts[:data].map do |e|
      e.course_inst_info
    end
    params[:page] = params[:course_page]
    unshelf_course_insts = @keyword.present? ? CourseInst.where(name: /#{Regexp.escape(@keyword)}/).where(available: false) : CourseInst.where(available: false)
    unshelf_course_insts = unshelf_course_insts.desc(:start_course)
    @unshelf_course_insts = auto_paginate(unshelf_course_insts)
    @unshelf_course_insts[:data] = @unshelf_course_insts[:data].map do |e|
      e.course_inst_info
    end

    @profile = params[:profile]
  end

  def create
    retval = Course.create_course(params[:course])
    render json: retval_wrapper(retval)
  end

  def new
  end

  def show
    # @course = Course.where(id: params[:id]).first
    # course_insts = @course.course_insts
    # @course_insts = auto_paginate(course_insts)
    # @profile = params[:profile]
   
    @profile = params[:profile]
    @course_inst = CourseInst.where(id: params[:id]).first
    
    reviews = @course_inst.reviews
    if params[:review_type].present?
      reviews = reviews.where(status: params[:review_type].to_i)
    end
    params[:page] = params[:review_page]
    @reviews = auto_paginate(reviews)

    participates = @course_inst.course_participates
    params[:page] = params[:participate_page]
    @participates = auto_paginate(participates)

    # stat related
    @income_stat = @course_inst.income_stat
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
