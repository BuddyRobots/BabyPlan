class BookBorrow

  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: Integer
  field :borrow_at, type: Integer
  field :return_at, type: Integer
  field :renew_at, type: Array

  belongs_to :book_inst
  belongs_to :client, class_name: "User", inverse_of: :book_borrows


  def back
  	self.update_attributes({return_at: Time.now.to_i})
  end
end