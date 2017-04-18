class StockChange
  include Mongoid::Document
  include Mongoid::Timestamps

  field :num, type: Integer

  belongs_to :book
  belongs_to :book_template
  belongs_to :center

end