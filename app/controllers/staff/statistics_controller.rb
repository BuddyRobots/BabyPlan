class Staff::StatisticsController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "statistics"
  end

  def index
  end

  def client_stats
    @stat = current_center.client_stats
    render json: retval_wrapper({stat: @stat}) and return
  end

  def course_stats
  end

  def book_stats
  end
end
