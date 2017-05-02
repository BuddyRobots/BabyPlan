class UserMobile::ReviewsController < UserMobile::ApplicationController
 
  def index
    @back = params[:back]
    @course_inst = CourseInst.where(id: params[:course_inst_id]).first
    @cp = @course_inst.course_participates.where(client_id: @current_user.id).first
    @self_review = (@cp.present? && @cp.trade_state == "SUCCESS") && @current_user.reviews.where(course_inst_id: @course_inst.id).blank?
    reviews = @course_inst.reviews.where(status: Review::PUBLIC).desc(:created_at)
    @ele = @course_inst
    @reviews = auto_paginate(reviews)[:data]
  end

  def create
    @ele = CourseInst.where(id: params[:course_id]).first
    course = @ele.course
    review = @ele.reviews.create(score: params[:score].to_i,
                                content: params[:content],
                                client_id: @current_user.id)
    if course.present?
      review.update_attribute(:course_id, course.id)
    end
    render json: retval_wrapper(nil) and return
  end

  def more
    @course_inst = CourseInst.where(id: params[:course_id]).first
    @reviews = @course_inst.reviews.where(status: Review::PUBLIC).desc(:created_at)
    @reviews = auto_paginate(@reviews)[:data]
    @reviews = @reviews.map { |r| r.more_info }
    render json: retval_wrapper({more: @reviews}) and return
  end
end


