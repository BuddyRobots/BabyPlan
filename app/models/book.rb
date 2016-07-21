class Book

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :isbn, type: String
  field :author, type: String
  field :traslator, type: String
  field :illustrator, type: String
  field :desc, type: String
  field :recommendation, type: String

  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book

  has_many :book_stocks
  has_many :feed_backs
  has_many :favorites
  has_many :stafflogs

end