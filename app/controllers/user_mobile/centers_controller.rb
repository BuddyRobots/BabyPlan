class UserMobile::CentersController < StaffMobile::ApplicationController
  def index
    @centers = current_user.client_centers
  end

  def show
  end

  def new
  end
end
