class DeploysController < ApplicationController
  http_basic_authenticate_with :name => "deploy_user", :password => "br@2016"

  def index
  end

  def create
    @address = Deploy.deploy()
    render json: retval_wrapper(stat: @address) and return
  end
end
