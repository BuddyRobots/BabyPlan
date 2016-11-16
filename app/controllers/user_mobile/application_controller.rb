class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :require_sign_in, :get_keyword

  def get_keyword
  	@keyword = params[:keyword].to_s
  end

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to new_user_mobile_session_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_user.blank?
        redirect_to profile_user_mobile_settings_path + "?first_signin=true" and return if current_user.update_first_signin
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end
end
