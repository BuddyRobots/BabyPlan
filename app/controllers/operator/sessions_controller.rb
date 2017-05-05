class Operator::SessionsController < Operator::ApplicationController
  before_filter :require_sign_in, only: []

  # show the index page
  def index
    if @current_operator.present?
      redirect_to operator_books_path and return
    end
  end

  # signin
  def create
    retval = Operator.signin(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:operator_key] = {
        :value => retval[:auth_key],
        :expires => Rails.env == "production" ? 5.minutes.from_now : 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  def change_password
    retval = @current_operator.change_password(params[:password], params[:new_password])
    render json: retval_wrapper(retval) and return
  end

  def signout
    if current_operator.blank?
      redirect_to operator_sessions_path and return
    end
    if current_operator.class == User
      cookies.delete(:operator_key, :domain => :all)
      redirect_to operator_sessions_path and return
    else
      cookies.delete(:operator_key, :domain => :all)
      redirect_to operator_sessions_path and return
    end
  end
end
