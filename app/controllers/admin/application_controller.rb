class Admin::ApplicationController < ApplicationController
  layout 'layouts/admin'
  before_filter :admin_init
  before_filter :require_sign_in

  def admin_init
    if @current_user.try(:user_type) != User::ADMIN
      @current_user = nil
    end
  end

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to staff_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_user.blank?
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end
end
