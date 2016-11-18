class BorrowSetting

  include Mongoid::Document
  include Mongoid::Timestamps

  field :book_num, type: Integer
  field :borrow_duration, type: Integer

end