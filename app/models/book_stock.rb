class BookStock

  include Mongoid::Document
  include Mongoid::Timestamps

  field :stock_number, type: Integer

  belongs_to :center
  belongs_to :book

end