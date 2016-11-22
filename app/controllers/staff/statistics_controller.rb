class Staff::StatisticsController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "statistics"
  end

  def index
    @course_rank = current_center.course_rank
    @book_rank = current_center.book_rank
  end

  def client_stats
    @stat = current_center.client_stats
    render json: retval_wrapper({stat: @stat}) and return
  end

  def course_stats
    @stat = current_center.course_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end

  def book_stats
    @stat = current_center.book_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end
end
