class Staff::AnnouncementsController < Staff::ApplicationController

  def index
    @keyword = params[:keyword]
    local_eles = @keyword.present? ? current_center.announcements.where(title: /#{@keyword}/) : current_center.announcements.all
    @local_eles = auto_paginate(local_eles)
    global_eles = @keyword.present? ? Announcement.where(center: nil).where(title: /#{@keyword}/) : Announcement.where(center: nil)
    @global_eles = auto_paginate(global_eles)

    @profile = params[:profile]
  end

  def create
    retval = Announcement.create_announcement(current_user, params[:announcement], "local")
    render json: retval_wrapper(retval)
  end

  def show
    @announcement = Announcement.where(id: params[:id]).first
    if @announcement.nil?
      redirect_to action: :index and return
    end
    logger.info @announcement.inspect
  end

  def set_publish
    @announcement = current_center.announcements.where(id: params[:id]).first
    if @announcement.nil?
      render json: retval_wrapper(ErrCode::ANNOUNCEMENT_NOT_EXIST) and return
    end
    @announcement.update_attribute(:is_published, params[:publish] == true)
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
end
