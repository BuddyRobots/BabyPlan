class StaffMobile::BooksController < StaffMobile::ApplicationController

  # m_book_borrow
  def index
  end

  # m_borrow
  def borrow
    @mobile = params[:mobile]
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

  def borrow_result
    @mobile = params[:mobile]
    if params[:borrow_id].present?
      @borrow = BookBorrow.where(id: params[:borrow_id]).first
    end
    @err = params[:err]
  end

  def back
    @book_inst = BookInst.where(id: params[:id]).first
    if @book_inst.present?
      @book_borrow = @book_inst.current_borrow
      if @book_borrow.present?
        @book_borrow.back
        @success = true
      end
    end
  end

  def show
    @book_inst = BookInst.where(id: params[:id]).first
    @book = @book_inst.book
  end
end
