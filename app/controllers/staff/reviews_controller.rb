class Staff::ReviewsController < Staff::ApplicationController
  before_filter :get_review

  def get_review
    @review = Review.where(id: params[:id]).first
    if @review.blank?
      render json: retval_wrapper(ErrCode::REVIEW_NOT_EXIST) and return
    end
  end

  def show_review
    retval = @review.show
    render json: retval_wrapper(retval) and return
  end

  def hide_review
    retval = @review.hide
    render json: retval_wrapper(retval) and return
  end
end
