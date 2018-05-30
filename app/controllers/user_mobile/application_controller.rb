class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :refresh_session, :require_sign_in, :get_keyword, :bind_openid
  # before_filter :refresh_session, :require_sign_in, :get_keyword

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
      openid = cookies[:openid]
      user_openid = UserOpenid.where(openid: openid).first
      has_user_openid = user_openid.present? && user_openid.user_id == current_user.id.to_s
      url = request.fullpath.split('?')[0]
      if url != "/user_mobile/settings/get_openid" && url != "/user_mobile/settings/update_profile" && url != "/user_mobile/settings/profile" && (current_user.user_openid.blank? || !has_user_openid)
        @state = request.fullpath
        # render template: "/user_mobile/settings/openid"
        redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{Rails.configuration.wechat_app_id}&redirect_uri=#{CGI::escape('http://' + Rails.configuration.domain + '/user_mobile/settings/get_openid/')}&response_type=code&scope=snsapi_base&state=#{@state}#wechat_redirect"
      end
    end
  end

end
