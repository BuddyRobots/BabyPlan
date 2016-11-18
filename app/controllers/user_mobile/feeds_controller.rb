class UserMobile::FeedsController < UserMobile::ApplicationController
  def index
    @keyword = params[:keyword]
  	@code = params[:code]
    if @current_user.client_centers.present?
      @feeds = Feed.is_available.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s} + [nil]).desc(:updated_at)
      if params[:keyword].present?
        @feeds = @feeds.where(name: /#{params[:keyword]}/)
      end
      @feeds = auto_paginate(@feeds)[:data]
    end
  end

  def more
    @feeds = Feed.is_available.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s} + [nil]).desc(:updated_at)
    if params[:keyword].present?
      @feeds = @feeds.where(name: /#{params[:keyword]}/)
    end
    @feeds = auto_paginate(@feeds)[:data]
    @feeds = @feeds.map { |e| e.more_info }
    render json: retval_wrapper({more: @feeds}) and return
  end
end
