class UserMobile::ReviewsController < UserMobile::ApplicationController
  def index
    @review_type = params[:review_type]
    if @review_type == "book"
      @book = Book.where(id: params[:book_id]).first
      reviews = @book.reviews.public_and_mine(@current_user)
    else
      @course = CourseInst.where(id: params[:course_id]).first
      reviews = @course.reviews.public_and_mine(@current_user)
    end
    @reviews = reviews.map { |e| e.review_info }
  end

  def create
    if params[:review_type] == "book"
      @ele = Book.where(id: params[:book_id]).first
    else
      @ele = CourseInst.where(id: params[:course_id]).first
    end
    @ele.reviews.create(score: params[:score].to_i, content: params[:content], client_id: @current_user.id)
    render json: retval_wrapper(nil) and return
  end
end
