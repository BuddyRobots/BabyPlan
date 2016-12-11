class Center

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :lat, type: String
  field :lng, type: String
  field :desc, type: String
  field :available, type: Boolean

  has_one :photo, class_name: "Material", inverse_of: :center_photo
  has_many :course_insts
  has_many :books
  has_many :announcements
  has_many :staffs, class_name: "User", inverse_of: :staff_center

  has_many :out_transfers, class_name: "Transfer", inverse_of: "out_center"
  has_many :in_transfers, class_name: "Transfer", inverse_of: "in_center"

  has_many :feeds
  has_many :statistics
  has_many :bills

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
      lng: center_info[:lng]
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
        lng: center_info["lng"]
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
    num = self.statistics.where(type: Statistic::CLIENT_NUM).
                          where(:stat_date.gt => (Time.now - 10.weeks).to_i).
                          asc(:stat_date).map { |e| e.value || 0 }
    num = num.each_with_index.map { |e, i| i % 7 == 0 ? e : nil } .select { |e| e }
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
    signup_num = self.statistics.where(type: Statistic::COURSE_SIGNUP_NUM).
                                 where(:stat_date.gt => start_time).
                                 where(:stat_date.lt => end_time).
                                 desc(:stat_date).map { |e| e.value || 0 }
    signup_num = signup_num.each_slice(day).map { |a| a }
    signup_num = signup_num.blank? ? 0 : signup_num.map { |e| e.sum } .reverse
    allowance = self.statistics.where(type: Statistic::ALLOWANCE).
                                where(:stat_date.gt => start_time).
                                where(:stat_date.lt => end_time).
                                desc(:stat_date).map { |e| e.value || 0 }
    allowance = allowance.each_slice(day).map { |a| a }
    allowance = allowance.map { |e| e.sum } .reverse
    income = self.statistics.where(type: Statistic::INCOME).
                             where(:stat_date.gt => start_time).
                             where(:stat_date.lt => end_time).
                             desc(:stat_date).map { |e| e.value || 0 }
    income = income.each_slice(day).map { |a| a }
    income = income.map { |e| e.sum } .reverse
    {
      signup_time_unit: time_unit,
      signup_num: signup_num,
      total_signup: signup_num.sum,
      total_income: income.sum,
      total_allowance: allowance.sum,
      income_time_unit: time_unit,
      allowance: allowance,
      income:income,
      total_money: allowance.sum + income.sum
    }
  end

  def book_stats(duration, start_date, end_date)
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
    borrow_num = self.statistics.where(type: Statistic::BORROW_NUM).
                                 where(:stat_date.gt => start_time).
                                 where(:stat_date.lt => end_time).
                                 desc(:stat_date).map { |e| e.value || 0 }
    borrow_num = borrow_num.each_slice(day).map { |a| a }
    borrow_num = borrow_num.blank? ? 0 : borrow_num.map { |e| e.sum } .reverse
    stock_num = self.statistics.where(type: Statistic::STOCK).
                                where(:stat_date.gt => start_time).
                                where(:stat_date.lt => end_time).
                                desc(:stat_date).map { |e| e.value || 0 }
    stock_num = stock_num.each_slice(day).map { |a| a }
    stock_num = stock_num.map { |e| e.sum } .reverse
    off_shelf_num = self.statistics.where(type: Statistic::OFF_SHELF).
                                    where(:stat_date.gt => start_time).
                                    where(:stat_date.lt => end_time).
                                    desc(:stat_date).map { |e| e.value || 0 }
    off_shelf_num = off_shelf_num.each_slice(day).map { |a| a }
    off_shelf_num = off_shelf_num.map { |e| e.sum } .reverse
    {
      total_borrow: borrow_num.sum,
      borrow_time_unit: time_unit,
      borrow_num: borrow_num,
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
end