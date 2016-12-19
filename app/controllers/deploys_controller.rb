class DeploysController < ApplicationController
  http_basic_authenticate_with :name => "deploy_user", :password => "br@2016"

  def index
  end

  def create
  	if params[:deploy_type] == "production"
  		@retval = Deploy.deploy()
  	elsif params[:deploy_type] == "staging"
  		@retval = Deploy.deploy_staging()
  	else params[:deploy_type] == "development"
  		@retval = Deploy.deploy_practice()
  	end
    render json: retval_wrapper(stat: @retval) and return
  end

end
