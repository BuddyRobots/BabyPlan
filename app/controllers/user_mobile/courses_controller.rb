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
    @course = CourseInst.where(id: params[:id]).first
    @course_participate = @current_user.get_course_participate(@course)
    @back = params[:back]
  end

  # wechat_pay
  def new
    @course = CourseInst.where(id: params[:state]).first
    @open_id = Weixin.get_oauth_open_id(params[:code])
    @pay_info = CourseParticipate.create_new(@current_user, @course, @remote_ip, @open_id)
  end

  # evaluate
  def review
  end
end