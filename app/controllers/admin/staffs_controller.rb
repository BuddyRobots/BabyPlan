class Admin::StaffsController < Admin::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "staff"
  end

  def index
    @keyword = params[:keyword]
    staffs = @keyword.present? ? User.only_staff.where(name: /#{Regexp.escape(@keyword)}/) : User.only_staff
    staffs = staffs.where(mobile_verified: true)
    @staffs = auto_paginate(staffs)
    @staffs[:data] = @staffs[:data].map do |e|
      e.staff_info
    end
    @profile = params[:profile]
    operators = @keyword.present? ? Operator.where(name: /#{Regexp.escape(@keyword)}/) : Operator.all
    @operators = auto_paginate(operators)
    @operators[:data] = @operators[:data].map do |o|
      o.operator_info
    end
  end

  def show
    @staff = User.staff.where(id: params[:id]).first
  end

  def change_center
    @staff = User.staff.where(id: params[:id]).first
    @center = Center.where(id: params[:center_id]).first
    @staff.staff_center = @center
    @staff.save
    render json: retval_wrapper(nil) and return
  end

  def change_status
    @staff = User.staff.where(id: params[:id]).first
    @staff.status = User::LOCKED if params[:admin_action] == "lock"
    @staff.status = User::NORMAL if params[:admin_action] == "open"
    @staff.status = User::NORMAL if params[:admin_action] == "unlock"
    @staff.save
    render json: retval_wrapper(nil) and return
  end

  def create
    retval = Operator.create_operator(params[:operator])
    render json: retval_wrapper(retval) and return
  end

  def update
    @operator = Operator.where(id: params[:id]).first
    retval = @operator.update_info(params[:operator])
    render json: retval_wrapper(retval) and return
  end

  def set_available
    @operator = Operator.where(id: params[:id]).first
    retval = ErrCode::OPERATOR_NOT_EXIST if @operator.blank?
    retval = @operator.update_attribute(:available, params[:available])
    render json: retval_wrapper(nil)
  end
end
