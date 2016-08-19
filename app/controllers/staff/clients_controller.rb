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
  end

  def show
  end
end
