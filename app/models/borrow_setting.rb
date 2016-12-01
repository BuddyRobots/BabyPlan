class BorrowSetting

  include Mongoid::Document
  include Mongoid::Timestamps

  field :book_num, type: Integer
  field :borrow_duration, type: Integer
  field :latefee_per_day, type: Float
  field :deposit, type: Integer

end