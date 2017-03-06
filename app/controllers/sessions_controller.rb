class SessionsController < ApplicationController
  layout 'layouts/session'
  def index
  end

  def signup_page
  end

  def signin_page
  end

  def forgetpassword_page
  end

  def create
  	retval = User.signin_staff(params[:mobile], params[:password])
  	if retval.class == Hash && retval[:auth_key].present?
  		cookies[:auth_key] = {
        value: retval[:auth_key],
        expires: 24.months.from_now,
        domain: :all 
      }
      user = User.find_by_auth_key(retval[:auth_key])
      retval[:has_name] = user.name.present?
      retval[:user_type] = user.user_type
    end
    render json: retval_wrapper(retval)
  end

  def signup
  	retval = User.create_user(User::STAFF, params[:mobile])
  	render json: retval_wrapper(retval) and return
  end

  def verify
  	user = User.where(id: params[:id]).first
  	retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_staff(params[:password], params[:verify_code])
  	render json: retval_wrapper(retval)
  end

  def forget_password
    user = User.staff.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def reset_password
    user = User.staff.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.reset_password(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  def signout
    if current_user.blank?
      redirect_to signin_page_sessions_path and return
    end
   
    cookies.delete(:auth_key, :domain => :all)
    redirect_to signin_page_sessions_path and return
   
  end

end
