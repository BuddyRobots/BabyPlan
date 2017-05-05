require 'zip'
class Book

  include Mongoid::Document
  include Mongoid::Timestamps

  # field :name, type: String
  # field :type, type: String
  # field :isbn, type: String
  # field :author, type: String
  # field :publisher, type: String
  # field :translator, type: String
  # field :illustrator, type: String
  # field :desc, type: String
  # field :age_lower_bound, type: Integer
  # field :age_upper_bound, type: Integer
  # field :tags, type: String
  field :stock, type: Integer
  field :available, type: Boolean
  field :deleted, type: Boolean, default: false

  #ralationships specific for material
  # has_one :cover, class_name: "Material", inverse_of: :cover_book
  # has_one :back, class_name: "Material", inverse_of: :back_book

  has_one :feed

  has_one :qr_export

  belongs_to :center
  belongs_to :book_template
  belongs_to :operator
  has_many :book_insts
  has_many :book_borrows
  has_many :reviews
  has_many :favorites

  has_many :stock_changes

  default_scope { where(:deleted.ne => true)}
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

  def self.add_to_center(staff, center, book_template, num, available)
    book = center.books.create(
      book_template_id: book_template.id,
      stock: num,
      available: available
      )
    book.stock_changes.create(num: num.to_i, center_id: center.id, book_template_id: book_template.id)
    Feed.create(book_id: book.id, name: book.name, center_id: center.id, available: available)
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
      available: self.available,
      age_lower_bound: self.age_lower_bound,
      age_upper_bound: self.age_upper_bound
    }
  end

  def name
    return self.try(:book_template).try(:name)
  end

  def author
    return self.try(:book_template).try(:author)
  end

  def publisher
    return self.try(:book_template).try(:publisher)
  end

  def illustrator
    return self.try(:book_template).try(:illustrator)
  end

  def translator
    return self.try(:book_template).try(:translator)
  end

  def isbn
    return self.try(:book_template).try(:isbn)
  end

  def tags
    return self.try(:book_template).try(:tags)
  end

  def type
    return self.try(:book_template).try(:type)
  end

  def age_lower_bound
    return self.try(:book_template).try(:age_lower_bound)
  end

  def age_upper_bound
    return self.try(:book_template).try(:age_upper_bound)
  end

  def desc
    return self.try(:book_template).try(:desc)
  end

  def cover
    return self.try(:book_template).try(:cover)
  end

  def back
    return self.try(:book_template).try(:back)
  end

  def update_info(stock)
    self.update_attribute(:stock, stock)
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

    pdf_filename = Book.export_qrcode_pdf(self.name, self.publisher, folder, png_files)

    # zipfile_name = folder + SecureRandom.uuid.to_s + ".zip"

    # Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    #   png_files.each do |filename|
    #     zipfile.add(filename, folder + filename)
    #   end
    #   # zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    # end
    # zipfile_name
  end


  def self.export_qrcode_pdf(book_name, book_press, folder, png_files)
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
        bounding_box([start_x, start_y], width: 70, height: 100) do
          font("public/simsun/simsun.ttf") do
            text ActionController::Base.helpers.truncate(book_name, length: 22), size: 6
            text ActionController::Base.helpers.truncate(book_press, length: 22), size: 6
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

  def self.cal_idx(start_time, end_time, interval, create_time)
    dp_num = ((end_time.to_i - start_time.to_i) * 1.0 / interval.to_i).ceil
    dp_num - 1 - (end_time.to_i - create_time.to_i) / interval.to_i
  end

  def self.book_stats(duration, start_date, end_date)
    if duration == -1
      start_time_ary = start_date.split('-').map { |e| e.to_i }
      start_time = Time.mktime(start_time_ary[0], start_time_ary[1], start_time_ary[2]).to_i
      end_time_ary = end_date.split('-').map { |e| e.to_i }
      end_time = Time.mktime(end_time_ary[0], end_time_ary[1], end_time_ary[2], 23, 59, 59).to_i
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

    interval = day.days.to_i
    dp_num = ((end_time - start_time) * 1.0 / interval).ceil

    bbs = BookBorrow.where(:created_at.gt => start_time)
                    .where(:created_at.lt => end_time)
                    .asc(:created_at)
    bb_num = bbs.map { |e| self.cal_idx(start_time, end_time, interval, e.created_at) }
    bb_num = bb_num.group_by { |e| e }
    bb_num.each { |k,v| bb_num[k] = v.length }
    bb_num = (0 .. dp_num - 1).to_a.map { |e| bb_num[e].to_i }
    # bb_num.reverse!

    cur_stock_num = Book.all.map { |e| e.stock } .sum
    stock_changes = StockChange.where(:created_at.gt => start_time)
                               .where(:created_at.lt => end_time)
                               .asc(:created_at)
    stock_changes = stock_changes.map { |e| [self.cal_idx(start_time, end_time, interval, e.created_at), e.num] }
    stock_changes = stock_changes.group_by { |e| e[0] }
    stock_changes.each { |k,v| stock_changes[k] = v.map { |e| e[1] } .sum }
    stock_num = (0 .. dp_num - 1).to_a.map do |e|
      if e == 0
        cur_stock_num
      else
        cur_stock_num = cur_stock_num - stock_changes[dp_num - e].to_i
      end
    end
    stock_num.reverse!

    cur_off_shelf_num = BookBorrow.where(retuan_at: nil).length
    borrows = BookBorrow.where(:borrow_at.gt => start_time.to_i)
                        .where(:borrow_at.lt => end_time.to_i)
    borrows = borrows.map { |e| self.cal_idx(start_time, end_time, interval, e.created_at) }
    borrows = borrows.group_by { |e| e }
    borrows.each { |k,v| borrows[k] = v.length }
    borrows = (0 .. dp_num - 1).to_a.map { |e| borrows[e].to_i }

    returns = BookBorrow.where(:return_at.gt => start_time.to_i)
                        .where(:return_at.lt => end_time.to_i)
    returns = returns.map { |e| self.cal_idx(start_time, end_time, interval, e.created_at) }
    returns = returns.group_by { |e| e }
    returns.each { |k,v| returns[k] = v.length }
    returns = (0 .. dp_num - 1).to_a.map { |e| returns[e].to_i }

    off_shelf_num = (0 .. dp_num - 1).to_a.map do |e|
      if e == 0
        cur_off_shelf_num
      else
        cur_off_shelf_num = [cur_off_shelf_num - borrows[dp_num - e] + returns[dp_num - e], 0].max
      end
    end
    off_shelf_num.reverse!

    max_num = 5
    borrow_center_hash = { }
    Center.all.each do |c|
      c_bb_num = bbs.where(center_id: c.id).map { |e| self.cal_idx(start_time, end_time, interval, e.created_at) }
      c_bb_num = c_bb_num.group_by { |e| e }
      c_bb_num.each { |k,v| c_bb_num[k] = v.length }
      c_bb_num = (0 .. dp_num - 1).to_a.map { |e| c_bb_num[e].to_i }
      c_bb_num.reverse!
      borrow_center_hash[c.name] = c_bb_num.sum
    end
    borrow_center = borrow_center_hash.to_a
    borrow_center = borrow_center.sort { |x, y| -x[1] <=> -y[1] }
    if borrow_center.length > max_num
      ele = ["其他", borrow_center[max_num - 1..-1].map { |e| e[1] } .sum]
      borrow_center = borrow_center[0..max_num - 2] + [ele]
    end
    retval = {
      total_borrow: bb_num.sum,
      borrow_time_unit: time_unit,
      borrow_num: bb_num,
      stock_time_unit: time_unit,
      stock_num: stock_num,
      off_shelf_num: off_shelf_num,
      borrow_center: borrow_center
    }
    return retval
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

