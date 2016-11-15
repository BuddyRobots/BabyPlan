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
    
  end
end
