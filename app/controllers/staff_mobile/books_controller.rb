class StaffMobile::BooksController < StaffMobile::ApplicationController

  # m_book_borrow
  def index
  end

  # m_borrow
  def borrow
  end

  def do_borrow
    client = User.client.where(mobile: params[:mobile]).first
    retval = ErrCode::USER_NOT_EXIST if client.nil?
    if client.nil?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    book = Book.where(id: params[:book_id]).first
    if book.nil?
      render json: retval_wrapper(ErrCode::BOOK_NOT_EXIST) and return
    end
  end

  # m_continue_borrow, m_unreturn
  def borrow_result
  end

  # m_return
  def back
  end

  def show
    book_inst = Book.where(id: params[:id])
    @book = book_inst.book
  end
end
