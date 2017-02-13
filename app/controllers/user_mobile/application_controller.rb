class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :require_sign_in

  def require_sign_in
    respond_to do |format|
      format.html do
        if current_user.blank? || !current_user.is_client
          session[:user_return_to] = request.fullpath
          redirect_to signin_user_mobile_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return
        end
        # redirect_to profile_user_mobile_settings_path + "?first_signin=true" and return if current_user.update_first_signin
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end
end
