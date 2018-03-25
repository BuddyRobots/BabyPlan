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
    if retval.class == Hash
      retval[:user_return_to] = session[:user_return_to]
      session.delete(:user_return_to)
    end
    if params[:redirect].to_s == "http://babyplan.bjfpa.org.cn/czqx/login/"
      user = User.find_by_auth_key(retval[:auth_key])
      retval[:user_return_to] = params[:redirect] + user.user_openid
    end
    render json: retval_wrapper(retval)
  end

  # register page
  def sign_up
    @user_openid = current_user.user_openid
  end

  # register action
  def signup
    retval = User.create_user(User::CLIENT, params[:mobile])
    render json: retval_wrapper(retval) and return
  end

  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_client(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # signin
  def new
    @redirect = params[:redirect]
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
    redirect_to new_user_mobile_session_path
  end

  def feeds
    @feeds = Feed.is_available
    @feeds = @feeds.desc(:created_at)
    @feeds = auto_paginate(@feeds)[:data]
    render "user_mobile/feeds/index"
  end

  def announcements
    @announcements = Announcement.is_available
    @announcements = @announcements.desc(:created_at)
    @announcements = auto_paginate(@announcements)[:data]
    render "user_mobile/announcements/index"
  end

  def courses
    @courses = CourseInst.is_available
    @courses = @courses.desc(:created_at)
    @courses = auto_paginate(@courses)[:data]
    render "user_mobile/courses/index"
  end

  def books
    @books = Book.is_available
    @books = @books.desc(:created_at)
    @books = auto_paginate(@books)[:data]
    render "user_mobile/books/index"
  end

  def agreement
    @agreement = Agreement.first
  end
end

  
