class BookInst

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :book
  has_many :book_borrows

end