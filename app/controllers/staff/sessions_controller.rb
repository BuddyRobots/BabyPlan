class Staff::SessionsController < Staff::ApplicationController
  before_filter :require_sign_in, only: []

  # show the index page
  def index
  end

  # signin
  def create
    retval = User.signin_staff(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => Rails.env == "production" ? 3.minutes.from_now : 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  # verify code
  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_staff(params[:name], params[:center], params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # create new staff user, params include mobile, return verify code
  def signup
    if params[:captcha] != session[:_rucaptcha]
      render json: retval_wrapper(ErrCode::WRONG_CAPTCHA) and return
    end
    retval = User.create_user(User::STAFF, params[:mobile])
    render json: retval_wrapper(retval) and return
  end

  def forget_password
    if params[:captcha] != session[:_rucaptcha]
      render json: retval_wrapper(ErrCode::WRONG_CAPTCHA) and return
    end
    user = User.staff.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def reset_password
    user = User.staff.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.reset_password(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  def change_password
    retval = @current_user.change_password(params[:password], params[:new_password])
    render json: retval_wrapper(retval) and return
  end

  def signout
    if current_user.blank?
      redirect_to staff_sessions_path and return
    end
    if current_user.is_admin
      cookies.delete(:center_id, :domain => :all)
      redirect_to admin_centers_path and return
    else
      cookies.delete(:auth_key, :domain => :all)
      redirect_to staff_sessions_path and return
    end
  end
end
