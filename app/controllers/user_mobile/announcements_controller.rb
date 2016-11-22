class UserMobile::AnnouncementsController < UserMobile::ApplicationController
  # similar to search_new
  def index
    @keyword = params[:keyword]
    if @current_user.client_centers.present?
      @announcements = Announcement.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s} + [nil])
      if params[:keyword].present?
        @announcements = @announcements.where(title: /#{params[:keyword]}/)
      end
      @announcements = auto_paginate(@announcements)[:data]
    end
  end

  def more
    @announcements = Announcement.is_available.any_in(center_id: @current_user.client_centers.is_available.map { |e| e.id.to_s} + [nil])
    if params[:keyword].present?
      @announcements = @announcements.where(title: /#{params[:keyword]}/)
    end
    @announcements = auto_paginate(@announcements)[:data]
    @announcements = @announcements.map { |e| e.more_info }
    render json: retval_wrapper({more: @announcements}) and return
  end

  # noticedescription
  def show
    @announcement = Announcement.where(id: params[:id]).first
    @back = params[:back]
  end
end