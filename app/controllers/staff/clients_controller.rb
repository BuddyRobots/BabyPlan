class Staff::ClientsController < Staff::ApplicationController

  # show the index page
  def index
    users = User.client.where(name: /#{params[:keyword]}/)
    @users = auto_paginate(users)
    @users["data"].map do |e|
      e.client_info
    end
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
