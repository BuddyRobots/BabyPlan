class Client::ApplicationController < ApplicationController
  # before_filter :require_sign_in

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
