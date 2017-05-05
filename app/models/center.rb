class Center

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :lat, type: String
  field :lng, type: String
  field :desc, type: String
  field :available, type: Boolean
  field :abbr, type: String
  field :open_time, type: String
  field :price_upper, type: Integer
  field :classtime_upper, type: Integer
  field :code, type: Integer
  field :year, type: Integer

  has_one :photo, class_name: "Material", inverse_of: :center_photo
  has_many :course_insts
  has_many :books
  has_many :announcements
  has_many :staffs, class_name: "User", inverse_of: :staff_center
  has_many :qr_exports


  has_many :out_transfers, class_name: "Transfer", inverse_of: "out_center"
  has_many :in_transfers, class_name: "Transfer", inverse_of: "in_center"

  has_many :feeds
  has_many :statistics
  has_many :bills
  has_many :stock_changes

  has_many :course_participates
  has_many :book_borrows

  has_and_belongs_to_many :clients, class_name: "User", inverse_of: :client_centers

  scope :is_available, ->{ where(available: true) }

  def self.create_center(center_info)
    if Center.where(name: center_info[:name]).present?
      return ErrCode::CENTER_EXIST
    end
    center = Center.create(
      name: center_info[:name],
      address: center_info[:address],
      desc: center_info[:desc],
      available: center_info[:available],
      lat: center_info[:lat],
      lng: center_info[:lng],
      abbr: center_info[:abbr],
      open_time: center_info[:open_time],
      price_upper: center_info[:price_upper].to_i,
      classtime_upper: center_info[:classtime_upper].to_i,
      code: center_info[:code],
      year: center_info[:year]
    )
    { center_id: center.id.to_s }
  end

  def self.centers_for_select
    hash = { }
    Center.all.each do |c|
      hash[c.name] = c.id.to_s
    end
    hash 
  end

  def staffs_desc
    if self.staffs.length == 0
      "无"
    elsif self.staffs.length == 1
      self.staffs.first.name
    else
      self.staffs.first.name + "等" + self.staffs.length.to_s + "人"
    end
  end

  def books_desc
    total_stock = 0
    self.books.each { |e| total_stock = total_stock + e.stock }
    self.books.length.to_s + "种/" + total_stock.to_s + "本"
  end

  def courses_desc
    self.course_insts.length.to_s + "门"
  end

  def center_info
    {
      id: self.id.to_s,
      name: self.name,
      address: self.address,
      staffs_desc: self.staffs_desc,
      books_desc: self.books_desc,
      courses_desc: self.courses_desc,
      available: self.available
    }
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
    if available != true
      self.clients.each do |c|
        self.clients.delete(c)
      end
    end
    nil
  end

  def batch_export_qrcode
    folder = "public/qrcodes/"
    export_info = []
    self.qr_exports.each do |e|
      e.num.times do |i|
        book_inst = e.book.book_insts.create
        qrcode = RQRCode::QRCode.new(book_inst.id.to_s)
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

        png_file = book_inst.id.to_s + ".png"
        export_info << { book_name: e.book.name, press: e.book.publisher, png_file: png_file }
      end
    end
    pdf_filename = QrExport.export_qrcode_pdf(export_info)
  end

  def update_info(center_info)
    center = Center.where(name: center_info["name"]).first
    if center.present? && center.id != self.id
      return ErrCode::CENTER_EXIST
    end
    self.update_attributes(
      {
        name: center_info["name"],
        address: center_info["address"],
        desc: center_info["desc"],
        lat: center_info["lat"],
        lng: center_info["lng"],
        open_time: center_info["open_time"],
        abbr: center_info["abbr"],
        price_upper: center_info["price_upper"].to_i,
        classtime_upper: center_info["classtime_upper"].to_i
      }
    )
    nil
  end

  def client_stats
    gender = {'男生' => 0, '女生' => 0, '不详' => 0}
    age = {'0-3岁' => 0, '3-6岁' => 0, '6-9岁' => 0, '9-12岁' => 0, '12-15岁' => 0, "其他及不详" => 0}
    self.clients.each do |e|
      if e.gender == 0
        gender['男生'] += 1
      elsif e.gender == 1
        gender['女生'] += 1
      else
        gender['不详'] += 1
      end
      if e.birthday.blank?
        age["其他及不详"] += 1
      else
        birth_at = Time.mktime(e.birthday.year, e.birthday.month, e.birthday.day)
        if Time.now - 15.years > birth_at
          age["其他及不详"] += 1
        elsif Time.now - 12.years > birth_at
          age["12-15岁"] += 1
        elsif Time.now - 9.years > birth_at
          age["9-12岁"] += 1
        elsif Time.now - 6.years > birth_at
          age["6-9岁"] += 1
        elsif Time.now - 3.years > birth_at
          age["3-6岁"] += 1
        else
          age["0-3岁"] += 1
        end
      end
    end
    num = self.clients.where(:created_at.gt => Time.now - 10.weeks).asc(:created_at).map { |e| (e.created_at.to_i - Time.now.to_i + 10.weeks.to_i) / 1.weeks.to_i }
    num = num.group_by { |e| e }
    num.each { |k,v| num[k] = v.length }
    total_num = self.clients.count
    num = (0..9).to_a.map { |e| total_num = total_num - num[9-e].to_i } .reverse
    {
      gender: gender.to_a,
      age: age.to_a,
      num: num
    }
  end

  def course_stats(duration, start_date, end_date)
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

    cps = self.course_participates.where(:created_at.gt => start_time)
                                  .where(:created_at.lt => end_time)
                                  .where(trade_state: "SUCCESS")
                                  .asc(:created_at)
    dp_num = ((end_time - start_time) * 1.0 / interval).ceil
    signup_num = cps.map { |e| CourseInst.cal_idx(start_time, end_time, interval, e.created_at) }
    signup_num = signup_num.group_by { |e| e }
    signup_num.each { |k,v| signup_num[k] = v.length }
    signup_num = (0 .. dp_num - 1).to_a.map { |e| signup_num[e].to_i }
    # signup_num.reverse!

    income = cps.map { |e| [CourseInst.cal_idx(start_time, end_time, interval, e.created_at), e.price_pay] }
    income = income.group_by { |e| e[0] }
    income.each { |k,v| income[k] = v.map { |e| e[1] } .sum }
    income = (0 .. dp_num - 1).to_a.map { |e| income[e].to_i }


    max_num = 5

    income_school_hash = { }
    School.all.each do |s|
      s_income = cps.where(school_id: s.id).map { |e| [CourseInst.cal_idx(start_time, end_time, interval, e.created_at), e.price_pay] }
      s_income = s_income.group_by { |e| e[0] }
      s_income.each { |k,v| s_income[k] = v.map { |e| e[1] } .sum }
      s_income = (0 .. dp_num - 1).to_a.map { |e| s_income[e].to_i }
      # s_income.reverse!
      income_school_hash[s.name] = s_income.sum
    end
    income_school = income_school_hash.to_a
    income_school = income_school.sort { |x, y| -x[1] <=> -y[1] }
    if income_school.length > max_num
      ele = ["其他", income_school[max_num - 1..-1].map { |e| e[1] } .sum]
      income_school = income_school[0..max_num - 2] + [ele]
    end

    {
      signup_time_unit: time_unit,
      signup_num: signup_num,
      total_signup: signup_num.sum,
      total_income: income.sum,
      income_time_unit: time_unit,
      income: income,
      income_school: income_school
    }
  end

  def book_stats(duration, start_date, end_date)
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

    bbs = self.book_borrows.where(:created_at.gt => start_time)
                           .where(:created_at.lt => end_time)
                           .asc(:created_at)
    bb_num = bbs.map { |e| Book.cal_idx(start_time, end_time, interval, e.created_at) }
    bb_num = bb_num.group_by { |e| e }
    bb_num.each { |k,v| bb_num[k] = v.length }
    bb_num = (0 .. dp_num - 1).to_a.map { |e| bb_num[e].to_i }
    # bb_num.reverse!

    cur_stock_num = self.books.all.map { |e| e.stock } .sum
    stock_changes = self.stock_changes.where(:created_at.gt => start_time)
                                      .where(:created_at.lt => end_time)
                                      .asc(:created_at)
    stock_changes = stock_changes.map { |e| [Book.cal_idx(start_time, end_time, interval, e.created_at), e.num] }
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

    cur_off_shelf_num = self.book_borrows.where(retuan_at: nil).length
    borrows = self.book_borrows.where(:borrow_at.gt => start_time.to_i)
                               .where(:borrow_at.lt => end_time.to_i)
    borrows = borrows.map { |e| Book.cal_idx(start_time, end_time, interval, e.created_at) }
    borrows = borrows.group_by { |e| e }
    borrows.each { |k,v| borrows[k] = v.length }
    borrows = (0 .. dp_num - 1).to_a.map { |e| borrows[e].to_i }

    returns = self.book_borrows.where(:return_at.gt => start_time.to_i)
                               .where(:return_at.lt => end_time.to_i)
    returns = returns.map { |e| Book.cal_idx(start_time, end_time, interval, e.created_at) }
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

    {
      total_borrow: bb_num.sum,
      borrow_time_unit: time_unit,
      borrow_num: bb_num,
      stock_time_unit: time_unit,
      stock_num: stock_num,
      off_shelf_num: off_shelf_num
    }
  end

  def course_rank(max_num = 5)
    course_insts = self.course_insts.map do |e|
      reviews = e.reviews
      score = reviews.map { |r| r.score || 0 } .sum * 1.0
      {
        id: e.id.to_s,
        name: e.name,
        cp_num: e.course_participates.where(trade_state: "SUCCESS").length,
        review_score: (reviews.blank? ? 0 : score / reviews.length).round(1)
      }
    end
    {
      review_rank: course_insts.sort { |x, y| -x[:review_score] <=> -y[:review_score] } [0...[max_num, course_insts.length - 1].min],
      cp_rank: course_insts.sort { |x, y| -x[:cp_num] <=> -y[:cp_num] } [0...[max_num, course_insts.length - 1].min],
    }
  end

  def book_rank(max_num = 5)
    books = self.books.map do |e|
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

  def calculate_daily_stats
    date = Date.today - 1.days
    stat_date = Time.mktime(date.year, date.month, date.day).to_i
    # client number
    if self.statistics.where(type: Statistic::CLIENT_NUM, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::CLIENT_NUM, stat_date: stat_date, value: self.clients.count)
    end
    # course signup number, income, and allowance
    signup_num = 0
    income = 0
    allowance = 0
    self.course_insts.each do |e|
      cps = e.course_participates.where(:trade_state => "SUCCESS",
                                        :trade_state_updated_at.gt => stat_date)
      signup_num += cps.length
      cps.each do |cp|
        income += cp.price_pay || 0
        allowance += e.price - e.price_pay
      end
    end
    if self.statistics.where(type: Statistic::COURSE_SIGNUP_NUM, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::COURSE_SIGNUP_NUM, stat_date: stat_date, value: signup_num)
    end
    if self.statistics.where(type: Statistic::INCOME, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::INCOME, stat_date: stat_date, value: income)
    end
    if self.statistics.where(type: Statistic::ALLOWANCE, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::ALLOWANCE, stat_date: stat_date, value: allowance)
    end
    # borrow number, stock, and on shelf
    borrow_num = 0
    stock = 0
    off_shelf = 0
    self.books.each do |b|
      borrow_num += b.book_borrows.where(:borrow_at.gt => stat_date).length
      off_shelf += b.book_borrows.where(status: BookBorrow::NORMAL, return_at: nil).length
      stock += b.stock
    end
    if self.statistics.where(type: Statistic::BORROW_NUM, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::BORROW_NUM, stat_date: stat_date, value: borrow_num)
    end
    if self.statistics.where(type: Statistic::STOCK, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::STOCK, stat_date: stat_date, value: stock)
    end
    if self.statistics.where(type: Statistic::OFF_SHELF, stat_date: stat_date).blank?
      self.statistics.create(type: Statistic::OFF_SHELF, stat_date: stat_date, value: off_shelf)
    end
  end

  def get_code
    cur_year = Time.now.year
    if cur_year != self.year
      self.update_attributes({
        year: cur_year,
        code: 1
      })
    end
    ret_code = self.abbr + self.year.to_s + self.code.to_s.rjust(4, "0")
    self.update_attribute(:code, self.code + 1)
    return ret_code
  end

  def self.migrate
    abbr = {
      "小马厂": "XMC",
      "手帕口": "SPK"
    }

    Center.all.each do |c|
      abbr.each do |k, v|
        if c.name.include?(k.to_s)
          c.update_attribute(:abbr, v)
          break
        end
      end
    end
  end
end
