class Operator::ApplicationController < ApplicationController
  layout 'layouts/operator'
  before_filter :refresh_operator_session, :require_sign_in

  attr_reader :current_operator
  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to operator_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_operator.blank?
      end
      format.json do
        if current_operator.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def refresh_operator_session
    @current_operator = cookies[:operator_key].blank? ? nil : Operator.find_by_auth_key(cookies[:operator_key])
    if !current_operator.nil?
      # If current user is not empty, set cookie
      logger.info "AAAAAAAAAA"
      cookies[:operator_key] = {
        :value => cookies[:operator_key],
        :expires => 24.months.from_now,
        :domain => :all
      }
      return true
    else
      # If current user is empty, delete cookie
      cookies.delete(:operator_key, :domain => :all)
      return false
    end
  end

end
