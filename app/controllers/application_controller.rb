class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :init

  attr_reader :current_user

  def retval_wrapper(value)
    retval = ErrCode.ret_false(value)
    if value.class == Hash && value[:auth_key].present?
      refresh_session(value[:auth_key])
    end
    retval.nil? ? { success: true }.merge(value || {}) : retval
  end

  def init
    refresh_session(params[:auth_key] || cookies[:auth_key])
  end

  def refresh_session(auth_key)
    @current_user = auth_key.blank? ? nil : User.find_by_auth_key(auth_key)
    if !current_user.nil?
      # If current user is not empty, set cookie
      cookies[:auth_key] = {
        :value => auth_key,
        :expires => 24.months.from_now,
        :domain => :all
      }
      return true
    else
      # If current user is empty, delete cookie
      cookies.delete(:auth_key, :domain => :all)
      return false
    end
  end

end
