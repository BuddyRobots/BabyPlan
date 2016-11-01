class UserMobile::CoursesController < UserMobile::ApplicationController
  # similar to search_new
  def index
    if @current_user.client_centers.present?
      @courses = CourseInst.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
      if params[:keyword].present?
        @courses = @courses.where(name: /#{params[:keyword]}/)
      end
    end
  end

  # course_show
  def show
  end

  # wechat_pay
  def new
  end

  # evaluate
  def review
  end
end