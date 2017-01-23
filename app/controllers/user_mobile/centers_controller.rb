class UserMobile::CentersController < UserMobile::ApplicationController
  def index
    @keyword = params[:keyword]
    @centers = @keyword.blank? ? Center.all : Center.where(name: /#{Regexp.escape(@keyword)}/)
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
      if @current_user.client_centers.length < 3
        current_user.client_centers << @center
      end
    else
      current_user.client_centers.delete(@center)
    end
    redirect_to action: :new and return
  end
end
