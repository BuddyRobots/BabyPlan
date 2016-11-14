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
  end
end
