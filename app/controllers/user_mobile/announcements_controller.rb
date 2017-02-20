class UserMobile::AnnouncementsController < UserMobile::ApplicationController
  # similar to search_new
  def index
    @announcements = Announcement.is_available
    @announcements = @announcements.desc(:created_at)
    @announcements.where(unread: true).each { |a| a.update_attributes({unread: false})}
    @announcements = auto_paginate(@announcements)[:data]
  end

  def more
    @announcements = Announcement.is_available
    @announcements = @announcements.desc(:created_at)
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