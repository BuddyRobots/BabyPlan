class Staff::AccountsController < Staff::ApplicationController
  before_filter :require_sign_in

  # show the index page
  def index
    staffs = User.only_staff.where(is_admin: false)
    @staffs = auto_paginate(staffs)
    @staffs[:data] = @staffs[:data].map do |e|
      e.staff_info
    end
    # 也可以用下面的实例变量来写
    # @has_new_staff = User.has_new_staff
  end

  def update
    if @current_user.blank?
      redirect_to action: :signin_page and return
    end
    @current_user.name = params[:user_name]
    avatar = Avatar.new
    avatar.avatar = params[:photo_file]
    avatar.store_avatar!
    filepath = avatar.avatar.file.file
    m = Material.create(path: "/uploads/avatars/" + filepath.split('/')[-1])
    @current_user.avatar = m
    @current_user.save
    redirect_to action: :index and return
  end

  def change_status
    @staff = User.only_staff.where(id: params[:id]).first
    if @staff.nil?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    @staff.status = User::LOCKED if params[:status] == "close"
    @staff.status = User::NORMAL if params[:status] == "open"
    @staff.lock = params[:lock]
    @staff.save
    render json: retval_wrapper(nil) and return
  end
 
end
