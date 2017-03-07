class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :require_sign_in, :first_sign_in, :bind_openid

  def require_sign_in
    respond_to do |format|
      format.html do
        if current_user.blank? || !current_user.is_client
          session[:user_return_to] = request.fullpath
          redirect_to signin_user_mobile_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return
        end
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def first_sign_in
    if current_user.update_first_signin
      redirect_to profile_user_mobile_settings_path + "?first_signin=true" and return
    end
  end

  def bind_openid
    if request.fullpath != "/user_mobile/settings/profile" && current_user.user_openid.blank?
      @state = request.fullpath
      render template: "/user_mobile/settings/openid"
    end
  end
end
