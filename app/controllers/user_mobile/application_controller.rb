class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :refresh_session, :require_sign_in, :get_keyword, :bind_openid

  def get_keyword
  	@keyword = params[:keyword].to_s
  end

  def require_sign_in
    respond_to do |format|
      format.html do
        if current_user.blank? || !current_user.is_client
          session[:user_return_to] = request.fullpath
          redirect_to new_user_mobile_session_path(code: ErrCode::REQUIRE_SIGNIN) and return
        end
        if current_user.name_or_parent.blank? && request.path != "/user_mobile/settings/profile"
          redirect_to profile_user_mobile_settings_path + "?unnamed=true" and return
        end
      end
      format.json do
        if current_user.blank?
          render json: retval_wrapper(ErrCode::REQUIRE_SIGNIN) and return
        end
      end
    end
  end

  def bind_openid
    if current_user.present?
      url = request.fullpath.split('?')[0]
      if url != "/user_mobile/settings/get_openid" && url != "/user_mobile/settings/profile" && current_user.user_openid.blank?
        @state = request.fullpath
        # render template: "/user_mobile/settings/openid"
        redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx0bad9193f1246547&redirect_uri=#{CGI::escape('http://' + Rails.configuration.domain + '/user_mobile/settings/get_openid/')}&response_type=code&scope=snsapi_base&state=#{@state}#wechat_redirect"
      end
    end
  end

  def refresh_session
    auth_key = params[:auth_key] || cookies[:auth_key]
    @current_user = auth_key.blank? ? nil : User.find_by_auth_key(auth_key)
    if !current_user.nil?
      # If current user is not empty, set cookie
      if current_user.is_client
        logger.info "AAAAAAAAAA"
        cookies[:auth_key] = {
          :value => auth_key,
          :expires => 24.months.from_now,
          :domain => :all
        }
        return true
      else
        logger.info "AAAAAAAAAA"
        logger.info "AAAAAAAAAA"
        cookies[:auth_key] = {
          :value => auth_key,
          :expires => Rails.env == "production" ? 5.minutes.from_now : 24.months.from_now,
          :domain => :all
        }
        return true
      end
    else
      # If current user is empty, delete cookie
      cookies.delete(:auth_key, :domain => :all)
      return false
    end
  end
end
