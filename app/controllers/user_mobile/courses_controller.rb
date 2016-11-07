class UserMobile::CoursesController < UserMobile::ApplicationController
  skip_before_filter :require_sign_in, only: [:notify]
  # similar to search_new
  def index
    if @current_user.client_centers.present?
      @courses = CourseInst.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
      if params[:keyword].present?
        @courses = @courses.where(name: /#{params[:keyword]}/)
      end
    end
  end

  # course_show
  def show
    @course = CourseInst.where(id: params[:id]).first
    @course_participate = @current_user.get_course_participate(@course)
    @back = params[:back]
  end

  # wechat_pay
  def new
    @course = CourseInst.where(id: params[:state]).first
    @open_id = Weixin.get_oauth_open_id(params[:code])
    @pay_info = CourseParticipate.create_new(@current_user, @course, @remote_ip, @open_id)
  end

  def notify
    Rails.logger.info "AAAAAAAAAAAAAAAA"
    Rails.logger.info params.inspect
    Rails.logger.info "AAAAAAAAAAAAAAAA"
    # get out_trade_no, which is the order_id in CourseParticipate
    ci = CourseParticipate.where(order_id: out_trade_no).first
    # get result_code, err_code and err_code_des
    ci.update_order(result_code, err_code, err_code_des)
    render :xml => {return_code: "SUCCESS"} and return
  end

  # evaluate
  def review
  end
end