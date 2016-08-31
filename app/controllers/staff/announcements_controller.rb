class Staff::AnnouncementsController < Staff::ApplicationController

  def index
  end

  def create
    retval = Announcement.create_announcement(current_user, params[:announcement], "local")
    render json: retval_wrapper(retval)
  end

  def show
    @announcement = current_user.staff_center.announcements.where(id: params[:id]).first
    if @announcement.nil?
      redirect_to action: :index and return
    end
    logger.info @announcement.inspect
  end

  def set_publish
    @announcement = current_user.staff_center.announcements.where(id: params[:id]).first
    if @announcement.nil?
      render json: retval_wrapper(ErrCode::ANNOUNCEMENT_NOT_EXIST) and return
    end
    @announcement.update_attribute(:is_published, params[:publish] == true)
    render json: retval_wrapper(nil) and return
  end

  def new
  end
end
