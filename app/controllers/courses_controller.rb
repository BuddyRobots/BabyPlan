class CoursesController < ApplicationController
  def index
    courses = Course.where(available: true).select do |e|
      e.name.include?(params[:term]) || e.code.include?(params[:term])
    end
    course_name_code = courses.map { |e| "(#{e.code}) " + e.name }
    render json: course_name_code and return
  end

end
