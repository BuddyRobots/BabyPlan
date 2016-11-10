class StaffMobile::BooksController < StaffMobile::ApplicationController

  # m_book_borrow
  def index
  end

  # m_borrow
  def borrow
  end

  def do_borrow
    client = User.client.where(mobile: params[:mobile]).first
    if client.nil?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    book_inst = BookInst.where(id: params[:book_id]).first
    if book_inst.nil?
      render json: retval_wrapper(ErrCode::BOOK_NOT_EXIST) and return
    end
    book = book_inst.book
    retval = book_inst.borrow(client)
    render json: retval_wrapper(retval) and return
  end

  # m_continue_borrow, m_unreturn
  def borrow_result
    if params[:borrow_id].present?
      @borrow = BookBorrow.where(id: params[:borrow_id]).first
    end
    @err = params[:err]
  end

  # m_return
  def back
  end

  def show
    book_inst = BookInst.where(id: params[:id]).first
    @book = book_inst.book
  end
end
