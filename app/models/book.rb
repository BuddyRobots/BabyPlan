require 'zip'
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
  field :age_lower_bound, type: Integer
  field :age_upper_bound, type: Integer
  field :tags, type: String
  field :recommendation, type: String
  field :stock, type: Integer
  field :available, type: Boolean


  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book
  has_and_belongs_to_many :transfers

  belongs_to :center
  # has_many :book_borrows
  has_many :book_insts
  has_many :feedbacks
  has_many :favorites

  def self.create_book(staff, center, book_info)
    book = center.books.where(isbn: book_info[:isbn]).first
    if book.present?
      return ErrCode::BOOK_EXIST
    end
    book = center.books.create(
      name: book_info[:name],
      type: book_info[:type],
      isbn: book_info[:isbn],
      tags: (book_info[:tags] || []).join(','),
      author: book_info[:author],
      translator: book_info[:translator],
      illustrator: book_info[:illustrator],
      desc: book_info[:desc],
      age_lower_bound: book_info[:age_lower_bound],
      age_upper_bound: book_info[:age_upper_bound],
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
      tags: tags,
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
        tags: (book_info[:tags] || []).join(','),
        author: book_info["author"],
        translator: book_info["translator"],
        age_lower_bound: book_info["age_lower_bound"],
        age_upper_bound: book_info["age_upper_bound"],
        illustrator: book_info["illustrator"]
      }
    )
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
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

  def generate_compressed_file(number)
    folder = "public/qrcodes/"
    png_files = (0...number).to_a.map do |n|
      book_inst = self.book_insts.create

      qrcode = RQRCode::QRCode.new(book_inst.id.to_s)

      print(folder + book_inst.id.to_s + ".png")

      png = qrcode.as_png(
              resize_gte_to: false,
              resize_exactly_to: false,
              fill: 'white',
              color: 'black',
              size: 300,
              border_modules: 4,
              module_px_size: 6,
              file: folder + book_inst.id.to_s + ".png"
            )
      book_inst.id.to_s + ".png"
    end

    zipfile_name = folder + SecureRandom.uuid.to_s + ".zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      png_files.each do |filename|
        zipfile.add(filename, folder + filename)
      end
      # zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end
    zipfile_name
  end
end