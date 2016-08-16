class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def retval_wrapper(value)
  	retval = ErrCode.ret_false(value)
  	retval.nil? ? { success: true }.merge(value || {}) : retval
  end
end
