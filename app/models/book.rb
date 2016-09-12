class Book

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :type, type: String
  field :isbn, type: String
  field :author, type: String
  field :translator, type: String
  field :illustrator, type: String
  field :desc, type: String
  field :recommendation, type: String
  field :stock, type: Integer
  field :available, type: Boolean

  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book

  belongs_to :center
  has_many :feedbacks
  has_many :favorites

  def self.create_book(staff, book_info)
    book = staff.staff_center.books.where(isbn: book_info[:isbn]).first
    if book.present?
      return ErrCode::BOOK_EXIST
    end
    book = staff.staff_center.books.create(
      name: book_info[:name],
      type: book_info[:type],
      isbn: book_info[:isbn],
      author: book_info[:author],
      translator: book_info[:translator],
      illustrator: book_info[:illustrator],
      desc: book_info[:desc],
      stock: book_info[:stock],
      available: book_info[:available]
    )
    { book_id: book.id.to_s }
  end

  def book_info
    {
      id: self.id.to_s,
      name: self.name,
      center: self.center.name,
      author: self.author,
      translator: self.translator,
      illustrator: self.illustrator,
      isbn: self.isbn,
      type: self.type,
      stock: self.stock,
      available: self.available
    }
  end

  def update_info(book_info)
    self.update_attributes(
      {
        name: book_info["name"],
        type: book_info["type"],
        stock: book_info["stock"],
        isbn: book_info["isbn"],
        author: book_info["author"],
        translator: book_info["translator"],
        illustrator: book_info["illustrator"]
      }
    )
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
    nil
  end
end