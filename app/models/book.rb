require 'zip'
class Book

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
  field :stock, type: Integer
  field :available, type: Boolean

  #ralationships specific for material
  has_one :cover, class_name: "Material", inverse_of: :cover_book
  has_one :back, class_name: "Material", inverse_of: :back_book

  has_one :feed

  has_one :qr_export

  belongs_to :center
  has_many :book_insts
  has_many :book_borrows
  has_many :reviews
  has_many :favorites

  scope :is_available, ->{ where(available: true) }

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
      publisher: book_info[:publisher],
      translator: book_info[:translator],
      illustrator: book_info[:illustrator],
      desc: book_info[:desc],
      age_lower_bound: book_info[:age_lower_bound],
      age_upper_bound: book_info[:age_upper_bound],
      stock: book_info[:stock],
      available: book_info[:available]
    )
    Feed.create(book_id: book.id, name: book.name, center_id: center.id, available: book_info[:available])
    { book_id: book.id.to_s }
  end

  def book_info
    available_stock = self.stock - self.book_borrows.where(status: BookBorrow::NORMAL, return_at: nil).length
    available_stock = [0, available_stock].max
    {
      id: self.id.to_s,
      name: self.name,
      center: self.center.name,
      author: self.author,
      publisher: self.publisher,
      translator: self.translator,
      illustrator: self.illustrator,
      tags: tags,
      isbn: self.isbn,
      type: self.type,
      stock: self.stock,
      available_stock: available_stock,
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
        publisher: book_info["publisher"],
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
    self.feed.update_attributes({available: available == true}) if self.feed.present?
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

    pdf_filename = Book.export_qrcode_pdf(self.name, folder, png_files)

    # zipfile_name = folder + SecureRandom.uuid.to_s + ".zip"

    # Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    #   png_files.each do |filename|
    #     zipfile.add(filename, folder + filename)
    #   end
    #   # zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    # end
    # zipfile_name
  end


  def self.export_qrcode_pdf(book_name, folder, png_files)
    start_point = [-20, 750]
    hor_interval = 100
    ver_interval = 110
    per_line = 6
    line_per_page = 7
    per_page = line_per_page * per_line
    last_page_idx = 0
    pdf_filename = folder + SecureRandom.uuid.to_s + ".pdf"
    Prawn::Document.generate(pdf_filename) do
      png_files.each_with_index do |png_file, e|
        page_idx = e / per_page
        if page_idx != last_page_idx
          start_new_page
          last_page_idx = page_idx
        end
        in_page_idx = e % per_page
        ver_idx = in_page_idx / per_line
        hor_idx = in_page_idx % per_line
        start_y = start_point[1] - ver_interval * ver_idx
        start_x = start_point[0] + hor_interval * hor_idx
        bounding_box([start_x, start_y], width: 70, height: 90) do
          font("public/simsun/simsun.ttf") do
            text ActionController::Base.helpers.truncate(book_name, length: 23), size: 6
          end
          image folder + png_file, position: :center, width: 70, height: 70
        end
      end
    end
    return pdf_filename
  end

  def more_info
    {
      ele_name: self.name,
      ele_id: self.id.to_s,
      ele_photo: self.cover.nil? ? ActionController::Base.helpers.asset_path("banner.png") : self.cover.path,
      ele_content: ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.desc).strip(), length: 50),
      ele_center: self.center.name
    }
  end

  def self.book_stats(duration, start_date, end_date)
    if duration == -1
      start_time_ary = start_date.split('-').map { |e| e.to_i }
      start_time = Time.mktime(start_time_ary[0], start_time_ary[1], start_time_ary[2]).to_i
      end_time_ary = end_date.split('-').map { |e| e.to_i }
      end_time = Time.mktime(end_time_ary[0], end_time_ary[1], end_time_ary[2]).to_i
      duration = [0, end_time - start_time].max
    else
      start_time = Time.now.to_i - duration
      end_time = Time.now.to_i
    end
    duration_days = duration / 1.days.to_i
    if duration_days < 15
      time_unit = "天数"
      day = 1
    elsif duration_days < 120
      time_unit = "周数"
      day = 7
    else
      time_unit = "月数"
      day = 30
    end
    borrow_num = Statistic.where(type: Statistic::BORROW_NUM).
                           where(:stat_date.gt => start_time).
                           where(:stat_date.lt => end_time).
                           desc(:stat_date).map { |e| e.value }
    borrow_num = borrow_num.each_slice(day).map { |a| a }
    borrow_num = borrow_num.map { |e| e.sum } .reverse
    stock_num = Statistic.where(type: Statistic::STOCK).
                          where(:stat_date.gt => start_time).
                          where(:stat_date.lt => end_time).
                          desc(:stat_date).map { |e| e.value }
    stock_num = stock_num.each_slice(day).map { |a| a }
    stock_num = stock_num.map { |e| e.sum } .reverse
    off_shelf_num = Statistic.where(type: Statistic::OFF_SHELF).
                              where(:stat_date.gt => start_time).
                              where(:stat_date.lt => end_time).
                              desc(:stat_date).map { |e| e.value }
    off_shelf_num = off_shelf_num.each_slice(day).map { |a| a }
    off_shelf_num = off_shelf_num.map { |e| e.sum } .reverse


    max_num = 5
    borrow_center_hash = { }
    Center.all.each do |c|
      borrow_num = c.statistics.where(type: Statistic::BORROW_NUM).
                                where(:stat_date.gt => start_time).
                                where(:stat_date.lt => end_time).
                                desc(:stat_date).map { |e| e.value }
      borrow_center_hash[c.name] = borrow_num.sum
    end
    borrow_center = borrow_center_hash.to_a
    borrow_center = borrow_center.sort { |x, y| -x[1] <=> -y[1] }
    if borrow_center.length > max_num
      ele = ["其他", borrow_center[max_num - 1..-1].map { |e| e[1] } .sum]
      borrow_center = borrow_center[0..max_num - 2] + [ele]
    end
    {
      total_borrow: borrow_num.sum,
      borrow_time_unit: time_unit,
      borrow_num: borrow_num,
      stock_time_unit: time_unit,
      stock_num: stock_num,
      off_shelf_num: off_shelf_num,
      borrow_center: borrow_center
    }
  end

  def self.book_rank(max_num = 5)
    books = Book.all.map do |e|
      reviews = e.reviews
      score = reviews.map { |r| r.score || 0 } .sum * 1.0
      {
        id: e.id.to_s,
        name: e.name,
        borrow_num: e.book_borrows.length,
        review_score: (reviews.blank? ? 0 : score / reviews.length).round(1)
      }
    end
    {
      review_rank: books.sort { |x, y| -x[:review_score] <=> -y[:review_score] } [0...[max_num, books.length - 1].min],
      borrow_rank: books.sort { |x, y| -x[:borrow_num] <=> -y[:borrow_num] } [0...[max_num, books.length - 1].min],
    }
  end

  def self.auto_merge(center)
    books_info = center.books.map do |b|
      info_str = b.name + b.isbn + b.author + b.translator + b.illustrator +
        b.desc + b.age_upper_bound.to_s + b.age_lower_bound.to_s + b.tags +
        b.cover.try(:path).to_s + b.back.try(:path).to_s
      {
        id: b.id.to_s,
        md5_str: Digest::MD5.new.hexdigest(info_str)
      }
    end
    groups = books_info.group_by do |e|
      e[:md5_str]
    end
    group_num = 0
    book_num = 0
    groups.each do |k, group|
      next if group.length <= 1
      group_num += 1
      book_num += group.length
      target = Book.find(group[0][:id])
      group.each_with_index do |ele, idx|
        next if idx == 0
        b = Book.find(group[idx][:id])
        target.merge(b)
      end
    end
    {
      group_num: group_num,
      book_num: book_num
    }
  end

  def self.mannual_merge(default_id, book_id_ary)
    target == Book.find(default_id)
    book_num = target.stock
    book_id_ary.each do |bid|
      b = Book.find(bid)
      target.merge(b)
      book_num += b.stock
    end
    {
      group_num: book_id_ary.length + 1,
      book_num: book_num
    }
  end

  def merge(target)
    # only books in the same center can be merged
    return false if self.center != target.center
    target.book_insts.each do |bi|
      bi.book = self
      bi.save
    end
    target.book_borrows.each do |bb|
      bb.book = self
      bb.save
    end
    target.reviews.each do |r|
      r.book = self
      r.save
    end
    target.favorites.each do |f|
      f.book = self
      f.save
    end
    feed = target.feed
    if feed.present? && self.feed.blank?
      feed.book = self
      feed.save
    end
    target.destroy
    return true
  end
end

