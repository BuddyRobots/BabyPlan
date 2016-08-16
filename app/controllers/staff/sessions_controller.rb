class Staff::SessionsController < Staff::ApplicationController

  # show the index page
  def index
  end

  # signin
  def create
  end

  # verify code
  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ErrCode::USER_NOT_EXIST : user.verify_staff(params[:name], params[:center], params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # create new staff user, params include mobile, return verify code
  def signup
    retval = User.create_user(User::CLIENT, params[:mobile])
    render json: retval_wrapper(retval)
  end

end
