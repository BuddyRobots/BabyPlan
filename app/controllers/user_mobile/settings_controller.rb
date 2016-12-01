class UserMobile::SettingsController < UserMobile::ApplicationController
	def index
    @msg_num = @current_user.messages.where(unread: true).length
  end

  def book
    @book_borrows = @current_user.book_borrows
    if params[:state].to_s == "true"
      @pay_deposit = "true"
      @open_id = Weixin.get_oauth_open_id(params[:code])
      @deposit = @current_user.deposit
      @deposit = @deposit || Deposit.create_new(@current_user)
      if @deposit.is_expired
        @deposit.renew
      end
      if @deposit.prepay_id.blank?
        @deposit.unifiedorder_interface(@remote_ip, @open_id)
      end
      @pay_info = @deposit.get_pay_info
    end
  end

  def pay_finished
    @deposit = current_user.deposit
    @deposit.update_attributes({pay_finished: true})
    render json: retval_wrapper(nil) and return
  end

  def pay_failed
    @deposit = current_user.deposit
    @deposit.renew
    render json: retval_wrapper(nil) and return
  end

  def course
    @courses_participates = @current_user.course_participates
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
end
