class UserMobile::ReviewsController < UserMobile::ApplicationController
  def index
    @review_type = params[:review_type]
    if @review_type == "book"
      @book = Book.where(id: params[:book_id]).first
    else
      @course = CourseInst.where(id: params[:course_id]).first
    end
  end

  def create
  end
end
