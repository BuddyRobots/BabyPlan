class UserMobile::SessionsController < UserMobile::ApplicationController
  skip_before_filter :require_sign_in

  # frontpage
	def index
    if @current_user.present?
      @announcements = Announcement.is_available.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s} + [nil]).limit(3)
    else
      @announcements = Announcement.is_available.where(:center_id => nil).limit(3)
    end
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

  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_client(params[:name], params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # signin
  def new
  end

  # forget_password
  def forget_password
  end

  def forget_password_submit_mobile
    user = User.client.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def forget_password_submit_code
    user = User.client.where(id: params[:uid]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_password_code(params[:code])
    render json: retval_wrapper(retval)
  end

  # set_password
  def set_password
    @uid = params[:uid]
  end

  def update_password
    user = User.client.where(id: params[:uid]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.set_password(params[:password])
    render json: retval_wrapper(retval)
  end

  def signout
    cookies.delete(:auth_key, :domain => :all)
    redirect_to user_mobile_sessions_path
  end
end

  