class AccountsController < ApplicationController
  def create
    Rails.logger.info "AAAAAAAAAAAA"
    Rails.logger.info params[:mobile]
    Rails.logger.info "AAAAAAAAAAAA"
    Rails.logger.info params[:html]

    uid = User.create_client(params[:mobile])

    if uid == -1
      render json: { condition: false }
    else
      render json: { condition: true, user_id: uid }
    end

  end

  def activate
    Rails.logger.info params[:id]
    us1 = User.where(id: params[:id]).first
    ret = us1.active(params[:name], params[:password], params[:code])

    if ret == -2
      render json: {request: false}
    else
      render json: {request: true, user_id: us1.id.to_s}
    end

  end

  def new
  
  end

end

