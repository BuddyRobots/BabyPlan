class UserMobile::CoursesController < UserMobile::ApplicationController
  skip_before_filter :require_sign_in, only: [:notify]
  # similar to search_new
  def index
    @keyword = params[:keyword]
    @price = params[:price].to_i
    @age = params[:age].to_i
    if @current_user.client_centers.present?
      @courses = CourseInst.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s})
      @courses = @courses.desc(:created_at)
      if params[:keyword].present?
        @courses = @courses.where(name: /#{params[:keyword]}/)
      end
      if params[:price].present?
        internals = [[nil, nil], [nil, 0], [0, 20], [20, 40], [40, nil]]
        internal = internals[params[:price].to_i]
        if params[:price].to_i == 1
          @courses = @courses.where(price_pay: "0")
        else
          @courses = @courses.where(:price_pay.gt => internal[0]) if internal[0].present?
          @courses = @courses.where(:price_pay.lte => internal[1]) if internal[1].present?
        end
      end
      if params[:age].present?
        internals = [[nil, nil], [0, 1], [1, 2], [2, 3], [3, 100]]
        internal = internals[params[:age].to_i]
        if internal[0].present? && internal[1].present?
          @courses = @courses.where(:min_age.lt => internal[1]).where(:max_age.gt => internal[0])
        end
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
    if params[:price].present?
      internals = [[nil, nil], [nil, 0], [0, 20], [20, 40], [40, nil]]
      internal = internals[params[:price].to_i]
      if params[:price].to_i == 1
        @courses = @courses.where(price_pay: "0")
      else
        @courses = @courses.where(:price_pay.gt => internal[0]) if internal[0].present?
        @courses = @courses.where(:price_pay.lte => internal[1]) if internal[1].present?
      end
    end
    if params[:age].present?
      internals = [[nil, nil], [0, 1], [1, 2], [2, 3], [3, 100]]
      internal = internals[params[:age].to_i]
      if internal[0].present? && internal[1].present?
        @courses = @courses.where(:min_age.lt => internal[1]).where(:max_age.gt => internal[0])
      end
    end
    @courses = auto_paginate(@courses)[:data]
    @courses = @courses.map { |e| e.more_info }
    render json: retval_wrapper({more: @courses}) and return
  end

  def show
    @back = params[:back]
    @course = CourseInst.where(id: params[:id]).first
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first

    # refresh order status
    if @course_participate.present? && @course_participate.renew_status
      @course_participate.orderquery
    end

    @refund_status_str = @course_participate.try(:refund_status_str).to_s
  end

  def new
    @course = CourseInst.where(id: params[:state]).first
    @course_participate = @current_user.course_participates.where(course_inst_id: @course.id).first || CourseParticipate.create_new(current_user, @course)

    # refresh order status
    if @course_participate.present? && @course_participate.renew_status
      @course_participate.orderquery
    end

    if @course_participate.prepay_id.present?
      if @course_participate.pay_finished == true || @course_participate.trade_state == "SUCCESS"
        # has pay
        redirect_to action: :show, id: params[:state] and return
      end
      if @course_participate.is_expired == false
        @pay_info = @course_participate.get_pay_info
        return
      end
    end

    if @course.capacity <= @course.effective_signup_num
      redirect_to action: :show, id: params[:state] and return
    end

    @open_id = params[:code].present? ? Weixin.get_oauth_open_id(params[:code]) : ""
    if @open_id.nil?
      # need to re-get the openid
      redirect_to action: :show, id: params[:state] and return
    end

    @course_participate.create_order(@remote_ip, @open_id)
    @pay_info = @course_participate.get_pay_info


  end

  def notify
    logger.info "AAAAAAAAAAAAAAAAA"
    logger.info request.inspect
    logger.info "AAAAAAAAAAAAAAAAA"
    render :xml => {return_code: "SUCCESS"}.to_xml(dasherize: false, root: "xml") and return
  end

  def pay_finished
    @course_participate = CourseParticipate.where(id: params[:id]).first
    @course_participate.update_attributes({pay_finished: true, expired_at: -1})
    if @course_participate.price_pay == 0
      @course_participate.update_attributes({
        trade_state: "SUCCESS"
      })
    else
      Bill.create_course_participate_item(@course_participate)
    end
    render json: retval_wrapper(nil) and return
  end

  def pay_failed
    # @course_participate = CourseParticipate.where(id: params[:id]).first
    # @course_participate.renew
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
    retval = @course_participate.refund
    render json: retval_wrapper(retval) and return
  end

  # judge whether a course_participate is expired
  def is_expired
    cp = CourseParticipate.where(id: params[:id]).first
    render json: retval_wrapper({is_expired: cp.is_expired}) and return
  end
end
