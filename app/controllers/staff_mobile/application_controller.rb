class StaffMobile::ApplicationController < ApplicationController
  layout 'layouts/staff_mobile'
  before_filter :require_sign_in, :get_current_center

  attr_reader :current_center

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to staff_mobile_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_user.blank? || !current_user.is_staff
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def get_current_center
    return if current_user.nil?
    if current_user.is_admin
      center_id = cookies[:center_id]
      @current_center = Center.where(id: center_id).first
      if @current_center.blank?
        redirect_to admin_centers_path and return
      end
    else
      @current_center = current_user.staff_center
    end
  end
end
