class Staff::ClientsController < Staff::ApplicationController

  # show the index page
  def index
    @keyword = params[:keyword]
    users = @keyword.present? ? User.client.where(name: /@keyword/) : User.client.all
    @users = auto_paginate(users)
    @users["data"] = @users["data"].map do |e|
      e.client_info
    end
    logger.info "AAAAAAAAAAAA"
    logger.info @users.inspect
    logger.info "AAAAAAAAAAAA"
  end

  # create a new user
  def create
    retval = User.create_user(User::CLIENT, params[:mobile], true)
    render json: retval_wrapper(retval)
  end

  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_client(params[:name], params[:gender], params[:birthday], params[:parent_name], params[:address], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  def show
  end
end
