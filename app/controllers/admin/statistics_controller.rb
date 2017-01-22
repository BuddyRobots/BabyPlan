class Admin::StatisticsController < Admin::ApplicationController
  before_filter :set_active_tab
  
  def index
    @course_rank = Course.course_rank
    @book_rank = Book.book_rank
  end

  def client_stats
    @stat = User.client_stats
    render json: retval_wrapper({stat: @stat}) and return
  end

  def course_stats
    @stat = Course.course_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end

  def book_stats
    @stat = Book.book_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end

  def set_active_tab
    @active_tab = "statistics"
  end
end
