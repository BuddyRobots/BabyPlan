class StaffMobile::BooksController < StaffMobile::ApplicationController

  before_filter :get_book_inst, only: [:show, :do_borrow, :back]

  def get_book_inst
    @book_inst = BookInst.where(id: params[:id]).first
    if @book_inst.present? && @book_inst.book.center != current_center
      @book_inst = nil
    end
  end

  # m_book_borrow
  def index
  end

  # m_borrow
  def borrow
    @mobile = params[:mobile]
  end

  def do_borrow
    client = current_center.clients.where(mobile: params[:mobile]).first
    if client.nil?
      render json: retval_wrapper(ErrCode::USER_NOT_EXIST) and return
    end
    # book_inst = BookInst.where(id: params[:id]).first
    if @book_inst.nil?
      render json: retval_wrapper(ErrCode::BOOK_NOT_EXIST) and return
    end
    if @book_inst.book.available == false
      render json: retval_wrapper(ErrCode::BOOK_NOT_AVAILABLE) and return
    end
    book = @book_inst.book
    retval = @book_inst.borrow(client)
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
    # @book_inst = BookInst.where(id: params[:id]).first
    if @book_inst.present?
      @book_borrow = @book_inst.current_borrow
      if @book_borrow.present?
        @book_borrow.back
        @success = true
      end
    end
  end

  def show
    # @book_inst = BookInst.where(id: params[:id]).first
    @book = @book_inst.try(:book)
  end
end
