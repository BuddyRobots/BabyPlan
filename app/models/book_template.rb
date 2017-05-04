require 'zip'
class BookTemplate

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :type, type: String
  field :isbn, type: String
  field :author, type: String
  field :publisher, type: String
  field :translator, type: String
  field :illustrator, type: String
  field :desc, type: String
  field :age_lower_bound, type: Integer
  field :age_upper_bound, type: Integer
  field :tags, type: String

  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book

  belongs_to :operator
  has_many :books
  has_many :stock_changes

  def self.create_book(operator, book_info)
    book_template = operator.book_templates.where(isbn: book_info[:isbn]).first
    if book_template.present?
      return ErrCode::BOOK_EXIST
    end
    book_template = operator.book_templates.create(
      name: book_info[:name],
      type: book_info[:type],
      isbn: book_info[:isbn],
      tags: (book_info[:tags] || []).join(','),
      author: book_info[:author],
      publisher: book_info[:publisher],
      translator: book_info[:translator],
      illustrator: book_info[:illustrator],
      desc: book_info[:desc],
      age_lower_bound: book_info[:age_lower_bound],
      age_upper_bound: book_info[:age_upper_bound]
    )
    { book_template_id: book_template.id.to_s }
  end

  def book_info
    {
      id: self.id.to_s,
      name: self.name,
      author: self.author,
      publisher: self.publisher,
      translator: self.translator,
      illustrator: self.illustrator,
      isbn: self.isbn,
      type: self.type,
      age_lower_bound: self.age_lower_bound,
      age_upper_bound: self.age_upper_bound
    }
  end

  def update_info(book_info)
    self.update_attributes(
      {
        isbn: book_info["isbn"],
        name: book_info["name"],
        author: book_info["author"],
        type: book_info["type"],
        translator: book_info["translator"],
        tags: (book_info[:tags] || []).join(','),
        illustrator: book_info["illustrator"],
        publisher: book_info["publisher"],
        age_lower_bound: book_info["age_lower_bound"],
        age_upper_bound: book_info["age_upper_bound"],
        desc: book_info["desc"]
      }
    )
    nil
  end


  def age_range_str
    if self.age_lower_bound.present? && self.age_upper_bound.present?
      if self.age_upper_bound < self.age_lower_bound
        return ""
      end
      if self.age_upper_bound == self.age_lower_bound
        return self.age_upper_bound.to_s + "岁"
      end
      return self.age_lower_bound.to_s + "~" + self.age_upper_bound.to_s + "岁"
    elsif self.age_upper_bound.present?
      return self.age_upper_bound.to_s + "岁以下"
    elsif self.age_lower_bound.present?
      return self.age_lower_bound.to_s + "岁以上"
    else
      ""
    end
  end


  def self.migrate
    Book.all.each do |b|
      bt = BookTemplate.where(isbn: b.isbn).first
      if bt.present?
        next
      end
      bt = BookTemplate.create({
        name: b.name,
        type: b.type,
        isbn: b.isbn,
        tags: b.tags || "",
        author: b.author,
        publisher: b.publisher,
        translator: b.translator,
        illustrator: b.illustrator,
        desc: b.desc,
        age_lower_bound: b.age_lower_bound,
        age_upper_bound: b.age_upper_bound
      })
      b.book_template = bt
      b.save
    end
  end

  def self.pic_migrate
    Book.all.each do |b|
      bt = BookTemplate.where(isbn: b.isbn).first
      bt.cover = b.cover
      bt.back = b.back
      bt.save
    end
  end
end

