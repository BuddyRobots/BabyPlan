class AccountsController < ApplicationController
  def create
    Rails.logger.info "AAAAAAAAAAAA"
    Rails.logger.info params[:mobile]
    Rails.logger.info "AAAAAAAAAAAA"

    uid = User.create_client(params[:mobile])

    if uid == -1
      render json: { success: false }
    else
      render json: { success: true, user_id: uid }
    end
  end

end
