class DeploysController < ApplicationController
  http_basic_authenticate_with :name => "deploy_user", :password => "br@2016"

  def index
  end

  def create
    retval = Deploy.deploy
    render json: retval_wrapper(retval) and return
  end
end
