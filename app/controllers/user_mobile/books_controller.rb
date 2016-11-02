class UserMobile::BooksController < UserMobile::ApplicationController
  # search_book
  def index
    if @current_user.client_centers.present?
      @books = Book.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
      if params[:keyword].present?
        @books = @books.where(name: /#{params[:keyword]}/)
      end
    end
  end

  # centerbook
  def show
    @book = Book.where(id: params[:id]).first
    @back = params[:back]
  end
end



  