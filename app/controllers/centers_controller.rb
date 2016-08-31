class CentersController < ApplicationController
  def index
  	center_names = Center.all.select { |e| e.name.include?(params[:term]) } .map { |e| e.name }
  	render json: center_names and return
  end

end
