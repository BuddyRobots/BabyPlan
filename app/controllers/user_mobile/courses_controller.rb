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
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
    @back = params[:back]
  end

  # wechat_pay
  def new
    @course = CourseInst.where(id: params[:state]).first
    @open_id = Weixin.get_oauth_open_id(params[:code])
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
    @course_participate = @course_participate || CourseParticipate.create_new(current_user, @course)
    if @course_participate.is_expired
      @course_participate.renew
    end
    @pay_info = @course_participate.unifiedorder_interface(@remote_ip, @open_id)
  end

  def notify
    # get out_trade_no, which is the order_id in CourseParticipate
    # ci = CourseParticipate.where(order_id: out_trade_no).first
    # get result_code, err_code and err_code_des
    # ci.update_order(result_code, err_code, err_code_des)
    render :xml => {return_code: "SUCCESS"} and return
  end

  def pay_finished
    @course_participate = CourseParticipate.where(id: params[:id]).first
    @course_participate.update_attributes({pay_finished: true})
    render_json retval_wrapper(nil) and return
  end

  # evaluate
  def review
  end
end