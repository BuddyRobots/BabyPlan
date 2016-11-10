class StaffMobile::TransfersController < StaffMobile::ApplicationController

  # m_transfer
  def index
  end

  def create
    retval = Transfer.create_new(params[:out_transfer_id], params[:in_transfer_id])
    render json: retval_wrapper(retval) and return
  end

  def add_to_transfer
    transfer = Transfer.where(id: params[:id]).first
    retval = transfer.add(params[:book_inst_id])
    render json: retval_wrapper(retval) and return
  end

  # m_transfer_out_record
  def list
  end

  # m_transfer_out
  def out_list
  end

  # m_transfer_in
  def in_list
  end

  # m_transport_to_center
  def new
  end

  # m_transfer_back, m_back, m_transfer_continue, m_transfer_desc, m_transfer_start
  def show
  end

  # m_continue_transport_out, m_transport_out_end, m_transport_out
  def transfer_out
    @transfer_id = params[:transfer_id]
    @auto = params[:auto]
  end

  # m_transport_in, m_transport
  def transfer_in
  end

  # m_transport_lost
  def confirm_lost
  end
end
