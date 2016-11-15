class UserMobile::BooksController < UserMobile::ApplicationController
  # search_book
  def index
    if @current_user.client_centers.present?
      @keyword = params[:keyword]
      @lower = params[:lower]
      @upper = params[:upper]
      @books = Book.any_in(center_id: @current_user.client_centers.map { |e| e.id.to_s})
      if params[:keyword].present?
        @books = @books.where(name: /#{params[:keyword]}/)
        if @lower.present? && @upper.present?
          @books = @books.where(:age_lower_bound.lt => @upper.to_i).where(:age_upper_bound.gt => @lower.to_i)
        end
      end
    end
  end

  def show
    @book = Book.where(id: params[:id]).first
    @back = params[:back]
  end
end
