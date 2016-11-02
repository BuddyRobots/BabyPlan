class StaffMobile::SessionsController < StaffMobile::ApplicationController
  before_filter :require_sign_in, only: []

  # m_frontpage
  def index
  end

  def create
    retval = User.signin_staff_mobile(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  def signout
    cookies.delete(:auth_key, :domain => :all)
    redirect_to staff_mobile_sessions_path
  end
end
