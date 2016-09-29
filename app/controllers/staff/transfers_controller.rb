class Staff::TransfersController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "transfers"
  end

  def index
  end

  def show
  end
end
