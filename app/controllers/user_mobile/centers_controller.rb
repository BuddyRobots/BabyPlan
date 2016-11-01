class UserMobile::CentersController < StaffMobile::ApplicationController
  def index
    @keyword = params[:keyword]
    @centers = @keyword.blank? ? Center.all : Center.where(name: /#{@keyword}/)
  end

  def show
    @center = Center.where(id: params[:id]).first
    @follow = @current_user.client_centers.include?(@center)
  end

  def new
    @centers = current_user.client_centers
  end

  def set_follow
    @center = Center.where(id: params[:id]).first
    if params[:follow].to_s == "true"
      current_user.client_centers << @center
    else
      current_user.client_centers.delete(@center)
    end
    redirect_to action: :new and return
  end
end
