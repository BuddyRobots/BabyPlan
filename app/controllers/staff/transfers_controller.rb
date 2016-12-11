class Staff::TransfersController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "transfers"
  end

  def index
    @profile = params[:profile]
    @keyword = params[:keyword]
    out_transfers = current_center.out_transfers
    in_transfers = current_center.in_transfers
    if @keyword.present?
      out_transfers = out_transfers.in(in_center_id: Center.where(name: /#{@keyword}/).map { |e| e.id})
      in_transfers = in_transfers.in(out_center_id: Center.where(name: /#{@keyword}/).map { |e| e.id})
    end

    @out_transfers = auto_paginate(out_transfers)
    @out_transfers[:data] = @out_transfers[:data].map do |e|
      e.transfer_info
    end
    @in_transfers = auto_paginate(in_transfers)
    @in_transfers[:data] = @in_transfers[:data].map do |e|
      e.transfer_info
    end
  end

  def show
    @transfer = Transfer.where(id: params[:id]).first
    if @transfer.nil?
      redirect_to action: :index and return
    end
    books_info_detail = @transfer.books_info_detail
    @books_info_detail = auto_paginate(books_info_detail)
    if @transfer.in_center_id == @current_center.id
      @profile = "in"
    else
      @profile = "out"
    end
  end

  def remove
    @transfer = Transfer.where(id: params[:id]).first
    if @transfer.status == Transfer::PREPARE && @transfer.book_insts.blank?
      @transfer.update_attribute(:deleted, true)
    end
    redirect_to "/staff/transfers?code=" + ErrCode::DONE.to_s and return
  end
end
