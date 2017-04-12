class Operator::ApplicationController < ApplicationController
  layout 'layouts/operator'
  skip_before_filter :refresh_session
  before_filter :refresh_operator_session, :require_sign_in

  attr_reader :current_operator
  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to operator_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return if current_operator.blank? || !current_operator.is_admin
      end
      format.json do
        if current_operator.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def refresh_operator_session
    if cookies[:operator_key].blank?
      @current_operator = nil
    else
      @current_operator = Operator.find_by_auth_key(cookies[:operator_key])
      if @current_operator.blank?
        @current_operator = User.find_by_auth_key(cookies[:operator_key])
        @current_operator = nil if @current_operator.try(:is_admin) != true
      end
    end
    logger.info "!!!!!!!!!!!!!"
    logger.info current_operator.inspect
    logger.info "!!!!!!!!!!!!!"
    if !current_operator.nil?
      # If current user is not empty, set cookie
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
