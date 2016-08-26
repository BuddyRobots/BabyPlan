class Staff::BooksController < Staff::ApplicationController

  def index
  end

  def create
    retval = Book.create_book(current_user, params[:book])
    render json: retval_wrapper(retval)
  end

  def show
  end

  def new
  end
end
