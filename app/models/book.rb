class Book

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :isbn, type: String
  field :author, type: String
  field :translator, type: String
  field :illustrator, type: String
  field :desc, type: String
  field :recommendation, type: String
  field :stock, type: Integer

  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book

  belongs_to :center
  has_many :feed_backs
  has_many :favorites
  has_many :stafflogs

  def self.create_book(staff, book_info)
    book = staff.center.books.where(isbn: book_info[:isbn]).first
    if book.present?
      return ErrCode::BOOK_EXIST
    end
    book = staff.center.books.create(
      name: book_info[:name],
      isbn: params[:isbn],
      author: params[:author],
      translator: params[:translator],
      illustrator: params[:illustrator],
      desc: params[:desc],
      stock: params[:stock]
    )
    { book_id: book.id.to_s }
  end
end