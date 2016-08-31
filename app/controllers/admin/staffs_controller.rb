class Admin::StaffsController < Admin::ApplicationController

  def index
    @keyword = params[:keyword]
    staffs = @keyword.present? ? User.staff.where(name: /#{@keyword}/) : User.staff
    staffs = staffs.where(mobile_verified: true)
    @staffs = auto_paginate(staffs)
    @staffs[:data] = @staffs[:data].map do |e|
      e.staff_info
    end
  end

  def show
  end

end
