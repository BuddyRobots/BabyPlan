class UserMobile::SessionsController < StaffMobile::ApplicationController
  # frontpage
	def index
  end

  def create
    retval = User.signin_user(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  # register page
  def sign_up
  end

  # register action
  def signup
    retval = User.create_user(User::CLIENT, params[:mobile])
    render json: retval_wrapper(retval) and return
  end

  # signin
  def new
  end

  # forget_password
  def forget_password
  end

  # set_password
  def set_password
  end
end

  