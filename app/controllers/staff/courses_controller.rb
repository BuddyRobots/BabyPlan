class Staff::CoursesController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "course"
  end

  def index
    # @keyword = params[:keyword]
    # params[:page] = params[:course_inst_page]
    # course_insts = @keyword.present? ? current_center.course_insts.where(name: /#{@keyword}/) : current_center.course_insts.all
    # @course_insts = auto_paginate(course_insts)
    # @course_insts[:data] = @course_insts[:data].map do |e|
    #   e.course_inst_info
    # end
    # params[:page] = params[:course_page]
    # courses = @keyword.present? ? Course.is_available.where(name: /#{@keyword}/) : Course.is_available
    # @courses = auto_paginate(courses)
    # @courses[:data] = @courses[:data].map do |e|
    #   e.course_info
    # end

    @profile = params[:profile]
  end
  
  def description
  end

  def create
    retval = CourseInst.create_course_inst(current_user, current_center, params[:course])
    render json: retval_wrapper(retval) and return
  end

  def new
    # @course = Course.where(id: params[:course_id]).first
    # if @course.blank?
    #   redirect_to action: :index and return
    # end
  end

  def show_template
    # @course = Course.where(id: params[:id]).first
    # if @course.blank?
    #   redirect_to action: :index and return
    # end
  end

  def show
    @profile = params[:profile]
    @course_inst = CourseInst.where(id: params[:id]).first

    reviews = @course_inst.reviews
    if params[:review_type].present?
      reviews = reviews.where(status: params[:review_type].to_i)
    end
    params[:page] = params[:review_page]
    @reviews = auto_paginate(reviews)

    participates = @course_inst.course_participates
    params[:page] = params[:participate_page]
    @participates = auto_paginate(participates)

    # stat related
    @income_stat = @course_inst.income_stat
  end

  def stat
    @course_inst = CourseInst.where(id: params[:id]).first
    @stat = @course_inst.get_stat
    # retval = {
    #   gender: [['男生', 60], ['女生', 40]],
    #   age: [['0-3岁', 10], ['3-6岁', 15], ['6-9岁', 20], ['9-12岁', 25], ['12-15岁', 20], ['15-18岁', 10]],
    #   num: [1.0, 2.3, 2.8, 3.2, 4.5, 6.0, 6.6, 7.5, 8.5, 15.3],
    #   signin: [100, 99, 97, 95, 97, 91, 93, 85, 88, 5, 96, 97, 91, 93],
    #   signup_start_str: "2016-10-5"
    # }
    render json: retval_wrapper({stat: @stat}) and return
  end

  def update
    @course_inst = CourseInst.where(id: params[:id]).first
    render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return if @course_inst.nil?
    retval = @course_inst.update_info(params[:course_inst])
    render json: retval_wrapper(retval)
  end

  def upload_photo
    @course_inst = CourseInst.where(id: params[:id]).first
    if @course_inst.blank?
      redirect_to action: :index and return
    end
    photo = Photo.new
    photo.photo = params[:photo_file]
    photo.store_photo!
    filepath = photo.photo.file.file
    m = Material.create(path: "/uploads/photos/" + filepath.split('/')[-1])
    @course_inst.photo = m
    @course_inst.save
    redirect_to action: :show, id: @course_inst.id.to_s and return
  end

  def get_id_by_name
    course_name = params[:course_name]
    scan_result = course_name.scan(/\((.+)\)/)
    if scan_result[0].present?
      code = scan_result[0][0]
      course = Course.where(code: code).first
      if course.present?
        render json: retval_wrapper({ id: course.id.to_s }) and return
      else
        render json: retval_wrapper(ErrCode::COURSE_NOT_EXIST) and return
      end
    else
      render json: retval_wrapper(ErrCode::COURSE_NOT_EXIST) and return
    end
  end

  def set_available
    @course_inst = CourseInst.where(id: params[:id]).first
    retval = ErrCode::COURSE_INST_NOT_EXIST if @course.blank?
    retval = @course_inst.set_available(params[:available])
    render json: retval_wrapper(retval)
  end

  def qrcode
    @course_inst = CourseInst.where(id: params[:id]).first
    signin_url = "http://#{Rails.configuration.host}/user_mobile/courses/#{@course_inst.id.to_s}/signin?time=#{Time.now.to_i.to_s}&class_idx=#{params[:class_num].to_s}"
    qrcode = RQRCode::QRCode.new(signin_url)
    filename = "#{@course_inst.id.to_s}_#{params[:class_num].to_s}"
    png = qrcode.as_png(
            resize_gte_to: false,
            resize_exactly_to: false,
            fill: 'white',
            color: 'black',
            size: 500,
            border_modules: 4,
            module_px_size: 6,
            file: "public/qrcodes/#{filename}"
            )
    render json: retval_wrapper({img_src: "/qrcodes/#{filename}"})
  end

  def signin_client
    course_inst = CourseInst.where(id: params[:id]).first
    if course_inst.blank?
      render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return
    end
    client = User.client.where(mobile: params[:mobile]).first
    if client.blank?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    course_participate = client.course_participates.where(course_inst_id: course_inst.id).first
    if course_participate.blank?
      render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return
    end
    retval = course_participate.signin(params[:class_num].to_i)
    render json: retval_wrapper(retval) and return
  end

  def signin_info
    course_inst = CourseInst.where(id: params[:id]).first
    if course_inst.blank?
      render json: retval_wrapper(ErrCode::COURSE_INST_NOT_EXIST) and return
    end
    retval = course_inst.signin_info(params[:class_num])
    render json: retval_wrapper(retval) and return
  end

  def next_refund_request
    cp = CourseParticipate.waiting_for_refund(@current_center)
    if cp.present?
      retval = {
        id: cp.id.to_s,
        course_name: cp.course_inst.name || cp.course_inst.course.name,
        course_id: cp.course_inst.id.to_s,
        client_name: cp.client.name,
        client_id: cp.client.id.to_s
      }
      render json: retval_wrapper(retval) and return
    else
      render json: retval_wrapper(ErrCode::BLANK_DATA) and return
    end
  end

  def reject_refund
    @course_participate = CourseParticipate.where(id: params[:id]).first
    retval = @course_participate.reject_refund(params[:feedback])
    render json: retval_wrapper(retval) and return
  end

  def approve_refund
    @course_participate = CourseParticipate.where(id: params[:id]).first
    retval = @course_participate.approve_refund(params[:feedback])
    render json: retval_wrapper(retval) and return
  end
end
