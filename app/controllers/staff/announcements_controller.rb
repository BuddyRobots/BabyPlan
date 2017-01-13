class Staff::AnnouncementsController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "announcement"
  end

  def index
    # @keyword = params[:keyword]
    # params[:page] = params[:local_page]
    # local_eles = @keyword.present? ? current_center.announcements.where(title: /#{@keyword}/) : current_center.announcements.all
    # local_eles = local_eles.desc(:created_at)
    # @local_eles = auto_paginate(local_eles)
    # params[:page] = params[:global_page]
    # global_eles = @keyword.present? ? Announcement.where(center: nil).where(title: /#{@keyword}/) : Announcement.where(center: nil)
    # global_eles = global_eles.desc(:created_at)
    # @global_eles = auto_paginate(global_eles)

    # @profile = params[:profile]
  end

  def create
    retval = Announcement.create_announcement(current_user, current_center, params[:announcement], "local")
    render json: retval_wrapper(retval)
  end

  def show
    # @announcement = Announcement.where(id: params[:id]).first
    # if @announcement.nil?
    #   redirect_to action: :index and return
    # end
    # logger.info @announcement.inspect
  end

  def set_publish
    @announcement = current_center.announcements.where(id: params[:id]).first
    if @announcement.nil?
      render json: retval_wrapper(ErrCode::ANNOUNCEMENT_NOT_EXIST) and return
    end
    @announcement.set_publish(params[:publish])
    render json: retval_wrapper(nil) and return
  end

  def new
  end

  def update
    @announcement = current_center.announcements.where(id: params[:id]).first
    if @announcement.nil?
      render json: retval_wrapper(ErrCode::ANNOUNCEMENT_NOT_EXIST) and return
    end
    retval = @announcement.update_announcement(params[:announcement])
    render json: retval_wrapper(retval) and return
  end

  def upload_photo
    @announcement = Announcement.where(id: params[:id]).first
    if @announcement.blank?
      redirect_to action: :index and return
    end
    photo = Photo.new
    photo.photo = params[:photo_file]
    photo.store_photo!
    filepath = photo.photo.file.file
    m = Material.create(path: "/uploads/photos/" + filepath.split('/')[-1])
    @announcement.photo = m
    @announcement.save
    redirect_to action: :show, id: @announcement.id.to_s and return
  end
end
