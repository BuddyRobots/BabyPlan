class Staff::SessionsController < Staff::ApplicationController
  before_filter :require_sign_in, only: []

  # show the index page
  def index
  end

  # signin
  def create
    retval = User.signin_staff(params[:mobile], params[:password])
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
    retval = User.create_user(User::STAFF, params[:mobile])
    render json: retval_wrapper(retval)
  end

  def forget_password
    user = User.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def reset_password
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.reset_password(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end
end
