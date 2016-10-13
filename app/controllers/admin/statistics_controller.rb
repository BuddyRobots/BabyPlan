class Admin::StatisticsController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "statistics"
  end

  def index
  end
end
