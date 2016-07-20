class BookBorrow

  include Mongoid::Document
  include Mongoid::Timestamps

  field :borrow_time, type: Integer
  field :return_time, type: Integer
  field :renew_number, type: Integer

  belongs_to :book_stock
  belongs_to :client, class_name: "User", inverse_of: :book_borrows

end