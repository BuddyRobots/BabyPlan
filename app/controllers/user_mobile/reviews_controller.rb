class UserMobile::ReviewsController < UserMobile::ApplicationController
  # def index
  #   @back = params[:back]
  #   @review_type = params[:review_type]
  #   if @review_type == "book"
  #     @book = Book.where(id: params[:book_id]).first
  #     reviews = @book.reviews.public_and_mine(@current_user)
  #     @ele = @book
  #   else
  #     @course = CourseInst.where(id: params[:course_id]).first
  #     reviews = @course.reviews.public_and_mine(@current_user)
  #     @ele = @course
  #   end
  #   @reviews = reviews.map { |e| e.review_info }
  # end
  def index
    @back = params[:back]
    @course_inst = CourseInst.where(id: params[:course_inst_id]).first
    @cp = @course_inst.course_participates.where(client_id: @current_user.id).first
    @self_review = (@cp.present? && @cp.trade_state == "SUCCESS") && @current_user.reviews.where(course_inst_id: @course_inst.id).blank?
    reviews = @course_inst.reviews.public_and_mine(@current_user)
    @ele = @course_inst
    @reviews = reviews.map { |e| e.review_info}
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
end

#   def create
#     if params[:review_type] == "book"
#       @ele = Book.where(id: params[:book_id]).first
#     else
#       @ele = CourseInst.where(id: params[:course_id]).first
#       course = @ele.course
#     end
#     review = @ele.reviews.create(score: params[:score].to_i,
#                         content: params[:content],
#                         client_id: @current_user.id)
#     if course.present?
#       review.update_attribute(:course_id, course.id)
#     end
#     render json: retval_wrapper(nil) and return
#   end
# end
