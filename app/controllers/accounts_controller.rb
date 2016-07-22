class AccountsController < ApplicationController
  def create
  	Rails.logger.info "AAAAAAAAAAAA"
  	Rails.logger.info params[:mobile]
  	Rails.logger.info "AAAAAAAAAAAA"

  	

  	render json: { success: true }
  end

end
