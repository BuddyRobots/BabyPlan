class StaffMobile::SessionsController < StaffMobile::ApplicationController
  before_filter :require_sign_in, only: []

  # m_frontpage
  def index
  end

  def create
    retval = User.signin_staff(params[:mobile], params[:password])
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
    if current_user.is_admin
      cookies.delete(:center_id, :domain => :all)
      redirect_to admin_centers_path and return
    else
      cookies.delete(:auth_key, :domain => :all)
      redirect_to staff_sessions_path
    end
  end
end
