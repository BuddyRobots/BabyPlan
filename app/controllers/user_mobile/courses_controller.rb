class UserMobile::CoursesController < UserMobile::ApplicationController
  skip_before_filter :require_sign_in, only: [:notify]
  # similar to search_new
  def index
    @keyword = params[:keyword]
    if @current_user.client_centers.present?
      @courses = CourseInst.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s})
      @courses = @courses.desc(:created_at)
      if params[:keyword].present?
        @courses = @courses.where(name: /#{params[:keyword]}/)
      end
      @courses = auto_paginate(@courses)[:data]
    end
  end

  def more
    @courses = CourseInst.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s})
    @courses = @courses.desc(:created_at)
    if params[:keyword].present?
      @courses = @courses.where(name: /#{params[:keyword]}/)
    end
    @courses = auto_paginate(@courses)[:data]
    @courses = @courses.map { |e| e.more_info }
    render json: retval_wrapper({more: @courses}) and return
  end

  def show
    @back = params[:back]
    @course = CourseInst.where(id: params[:id]).first
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
    @refund_status_str = @course_participate.try(:refund_status_str).to_s
  end

  def new
    @course = CourseInst.where(id: params[:state]).first
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first
    @course_participate = @course_participate || CourseParticipate.create_new(current_user, @course)
    @course_participate.renew
    @course_participate.clear_refund
    if @course.price_pay > 0
      @course_participate.update_attributes({renew_status: true})
      @open_id = Weixin.get_oauth_open_id(params[:code])
      if @course_participate.prepay_id.blank?
        @course_participate.unifiedorder_interface(@remote_ip, @open_id)
      end
      @pay_info = @course_participate.get_pay_info
    end
  end

  def notify
    # get out_trade_no, which is the order_id in CourseParticipate
    # ci = CourseParticipate.where(order_id: out_trade_no).first
    # get result_code, err_code and err_code_des
    # ci.update_order(result_code, err_code, err_code_des)
    logger.info "AAAAAAAAAAAAAAAAA"
    logger.info request.inspect
    logger.info "AAAAAAAAAAAAAAAAA"
    render :xml => {return_code: "SUCCESS"}.to_xml(dasherize: false, root: "xml") and return
  end

  def pay_finished
    @course_participate = CourseParticipate.where(id: params[:id]).first
    @course_participate.update_attributes({pay_finished: true})
    if @course_participate.price_pay == 0
      @course_participate.update_attributes({
        prepay_id: "free",
        trade_state: "SUCCESS"
      })
    else
      Bill.create_course_participate_item(@course_participate)
    end
    render json: retval_wrapper(nil) and return
  end

  def pay_failed
    @course_participate = CourseParticipate.where(id: params[:id]).first
    @course_participate.renew
    render json: retval_wrapper(nil) and return
  end

  def signin
    course_participate = @current_user.course_participates.where(course_inst_id: params[:id]).first
    if course_participate.nil?
      redirect_to "/user_mobile/settings/sign?err=course_inst_not_exist&success=false" and return
      # render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return
    else
      retval = course_participate.signin(params[:class_idx].to_i)
      if retval.class == Hash
        redirect_to "/user_mobile/settings/sign?success=true&course_id=#{params[:id]}&class_num=#{params[:class_idx]}"
      elsif retval == ErrCode::NOT_PAID
        redirect_to "/user_mobile/settings/sign?err=not_paid&success=false" and return
      else
        redirect_to "/user_mobile/settings/sign?err=course_inst_not_exist&success=false" and return
      end
      # render json: retval_wrapper(retval) and return
    end
  end

  def favorite
    course_inst = CourseInst.where(id: params[:id]).first
    fav = current_user.favorites.where(course_inst: course_inst).first
    fav = fav || current_user.favorites.create(course_inst_id: course_inst.id)
    if params[:favorite].to_s == "true"
      fav.enabled = true
    else
      fav.enabled = false
    end
    fav.save
    render json: retval_wrapper(nil) and return
  end

  def pay_success
    @course = CourseInst.where(id: params[:id]).first
  end

  def request_refund
    @course_participate = CourseParticipate.where(id: params[:id]).first
    retval = @course_participate.approve_refund
    render json: retval_wrapper(retval) and return
  end
end