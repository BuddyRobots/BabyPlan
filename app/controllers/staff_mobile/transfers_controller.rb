class StaffMobile::TransfersController < StaffMobile::ApplicationController

  # m_transfer
  def index
  end

  def create
    retval = Transfer.create_new(params[:out_center_id], params[:in_center_id])
    render json: retval_wrapper(retval) and return
  end

  def add_to_transfer
    transfer = Transfer.where(id: params[:id]).first
    retval = transfer.add(@current_user.staff_center.id.to_s, params[:book_inst_id])
    render json: retval_wrapper(retval) and return
  end

  def transfer_arrive
    transfer = Transfer.where(id: params[:id]).first
    retval = transfer.arrive(params[:book_inst_id])
    render json: retval_wrapper(retval) and return
  end

  def list
  end

  def out_list
    @prepare_transfers = @current_user.staff_center.out_transfers.where(status: Transfer::PREPARE)
  end

  def in_list
    @ongoing_transfers = @current_user.staff_center.in_transfers.where(status: Transfer::ONGOING)
  end

  def new
  end

  def show
    @transfer = Transfer.where(id: params[:id]).first
    @books_info = @transfer.books_info
    @lost_books_info = @transfer.lost_books_info
  end

  def transfer_out
    @transfer_id = params[:transfer_id]
    @name = params[:name].to_s
    @isbn = params[:isbn].to_s
    @code = params[:code].to_s
  end

  def transfer_in
    @transfer_id = params[:transfer_id]
    @name = params[:name].to_s
    @isbn = params[:isbn].to_s
    @code = params[:code].to_s
  end

  def confirm_lost
  end

  def confirm_transfer_out
    @transfer = Transfer.where(id: params[:id]).first
    retval = @transfer.confirm_transfer_out
    render json: retval_wrapper(retval) and return
  end

  def transfer_done
  end
end
