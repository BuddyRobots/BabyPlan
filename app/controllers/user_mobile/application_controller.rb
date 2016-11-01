class UserMobile::ApplicationController < ApplicationController
  layout 'layouts/user_mobile'
  # before_filter :require_sign_in, :get_current_center
  before_filter :get_keyword

  def get_keyword
  	@keyword = params[:keyword].to_s
  end
end
