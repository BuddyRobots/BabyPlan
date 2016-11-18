class BookBorrow

  include Mongoid::Document
  include Mongoid::Timestamps

  NOT_RETURN = 1
  RETURN = 2
  LOST = 4

  field :status, type: Integer
  field :borrow_at, type: Integer
  field :return_at, type: Integer
  field :renew_at, type: Array

  belongs_to :book_inst
  belongs_to :book
  belongs_to :client, class_name: "User", inverse_of: :book_borrows


  def back
  	self.update_attributes({return_at: Time.now.to_i})
  end

  def review
    self.client.reviews.where(book_id: self.book.id).first
  end

  def return_class
    if false
      return "overtime"
    end
    if self.return_at.blank?
      return "unreturn"
    end
  end
end