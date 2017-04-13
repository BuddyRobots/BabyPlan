class Admin::ApplicationController < ApplicationController
  layout 'layouts/admin'
  before_filter :admin_init
  before_filter :refresh_session, :require_sign_in

  def admin_init
    if @current_user.try(:user_type) != User::ADMIN
      @current_user = nil
    end
  end

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to admin_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_user.blank?
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def refresh_session
    auth_key = params[:auth_key] || cookies[:auth_key]
    @current_user = auth_key.blank? ? nil : User.find_by_auth_key(auth_key)
    if !current_user.nil?
      # If current user is not empty, set cookie
      if current_user.is_client
        logger.info "AAAAAAAAAA"
        cookies[:auth_key] = {
          :value => auth_key,
          :expires => 24.months.from_now,
          :domain => :all
        }
        return true
      else
        logger.info "AAAAAAAAAA"
        logger.info "AAAAAAAAAA"
        cookies[:auth_key] = {
          :value => auth_key,
          :expires => Rails.env == "production" ? 5.minutes.from_now : 24.months.from_now,
          :domain => :all
        }
        return true
      end
    else
      # If current user is empty, delete cookie
      cookies.delete(:auth_key, :domain => :all)
      return false
    end
  end
end
