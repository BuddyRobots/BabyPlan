class UserMobile::AnnouncementsController < UserMobile::ApplicationController
  # similar to search_new
  def index
    if @current_user.client_centers.present?
      @announcements = Announcement.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s} + [nil])
      if params[:keyword].present?
        @announcements = @announcements.where(title: /#{params[:keyword]}/)
      end
    end
  end

  # noticedescription
  def show
    @announcement = Announcement.where(id: params[:id]).first
    @back = params[:back]
  end
end