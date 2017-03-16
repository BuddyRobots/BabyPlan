class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :require_sign_in, :first_sign_in, :bind_openid

  def require_sign_in
    respond_to do |format|
      format.html do
        if current_user.blank? || !current_user.is_client
          session[:user_return_to] = request.fullpath
          redirect_to signin_user_mobile_sessions_path(code: ErrCode::REQUIRE_SIGNIN) and return
        end
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def first_sign_in
    if current_user.update_first_signin
      redirect_to profile_user_mobile_settings_path + "?first_signin=true" and return
    end
  end

  def bind_openid
    url = request.fullpath.split('?')[0]
    if url != "/user_mobile/settings/get_openid" && url != "/user_mobile/settings/profile" && current_user.user_openid.blank?
      @state = request.fullpath
      # render template: "/user_mobile/settings/openid"
      redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx0bad9193f1246547&redirect_uri=#{CGI::escape('http://maker.buddyrobots.com/user_mobile/settings/get_openid/')}&response_type=code&scope=snsapi_base&state=#{@state}#wechat_redirect"
    end
  end
end
