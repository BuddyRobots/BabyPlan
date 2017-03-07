class UserMobile::SettingsController < UserMobile::ApplicationController
	def index
    @msg_num = @current_user.messages.where(unread: true).length

    @signin = params[:signin]
  end

  def book
    @book_borrows = @current_user.book_borrows.desc(:created_at)
    if params[:state].to_s == "true"
      @pay_deposit = "true"
      @open_id = Weixin.get_oauth_open_id(params[:code])
      @deposit = @current_user.deposit
      @deposit = @deposit || Deposit.create_new(@current_user)
      @deposit.renew
      if @deposit.prepay_id.blank?
        @deposit.unifiedorder_interface(@remote_ip, @open_id)
      end
      @pay_info = @deposit.get_pay_info
    end
  end

  def pay_finished
    @deposit = current_user.deposit
    @deposit.update_attributes({pay_finished: true})
    Bill.create_online_deposit_pay_item(@deposit)
    render json: retval_wrapper(nil) and return
  end

  def pay_failed
    @deposit = current_user.deposit
    @deposit.renew
    render json: retval_wrapper(nil) and return
  end

  def course
    @courses_participates = @current_user.course_participates.desc(:created_at)
    @courses_participates = auto_paginate(@courses_participates)
    @courses_participates[:data] = @courses_participates[:data].map do |e|
      e.course_participate_info
    end
  end

  def more
    @courses_participates = @current_user.course_participates.desc(:created_at)
    @courses_participates = auto_paginate(@courses_participates)[:data]
    @courses_participates = @courses_participates.map {|e| e.more_info}
    render json: retval_wrapper(more: @courses_participates) and return
  end

  def favorite
    @favorites = @current_user.favorites.where(enabled: true).desc(:created_at)
  end

  def remove_favorite
    @favorite = Favorite.where(id: params[:favorite_id]).first
    @favorite.update_attributes({enabled: false})
    render json: retval_wrapper(nil) and return
  end

  def message
    @messages = @current_user.messages.desc(:created_at)
    @messages.where(unread: true).each { |e| e.update_attributes({unread: false}) }
  end

  def account
  end

  def reset_password
  end

  def profile
    @first_signin = params[:first_signin]
  end

  def update_profile
    retval = @current_user.update_profile(params[:profile])
    render json: retval_wrapper(retval) and return
  end

  def update_password
    retval = current_user.change_password(params[:old_password], params[:new_password])
    render json: retval_wrapper(retval) and return 
  end

  def sign
    @err = params[:err]
    @success = params[:success].to_s == "true"
    @course = CourseInst.where(id: params[:course_id]).first
    @class_num = params[:class_num]
  end

  def upload_avatar
    retval = @current_user.get_avatar(params[:server_id])
    render json: retval_wrapper(retval) and return
  end

  def openid
    
  end

  def get_openid
    @open_id = Weixin.get_oauth_open_id(params[:code])
    current_user.update_attribute(:user_openid, @open_id)
    current_user.save
    redirect_to params[:state]
  end
end
