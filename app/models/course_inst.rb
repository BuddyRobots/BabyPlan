class CourseInst

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :available, type: Boolean
  field :code, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :price, type: Integer
  field :price_pay, type: Integer
  field :speaker, type: String
  field :date, type: String
  field :date_in_calendar, type: Array, default: [ ]
  field :min_age, type: Integer
  field :max_age, type: Integer
  # field :school_id, type: String
  field :start_course, type: Integer
  field :desc, type: String
  field :deleted, type: Boolean, default: false

  has_one :photo, class_name: "Material", inverse_of: :course_inst_photo
  has_one :feed
  belongs_to :course
  belongs_to :center

  #relationships specific for course_participate
  has_many :course_participates

  has_many :reviews
  has_many :favorites
  has_many :bills

  has_many :messages

  belongs_to :school
  scope :is_available, ->{ where(available: true) }
  default_scope { where(:deleted.ne => true) }

  def self.check_upper(center, course_inst_info)
    if center.price_upper.present?
      if course_inst_info[:price_pay].to_i > center.price_upper
        return ErrCode::PRICE_UPPER
      end
    end
    if center.classtime_upper.present?
      course_date = Time.parse(course_inst_info[:start_course])
      week_start = course_date.beginning_of_week
      week_end = course_date.end_of_week
      course_insts = center.course_insts.where(:start_course.gt => week_start.to_i).where(:start_course.lt => week_end.to_i)
      total_time = 0
      course_insts.each do |ci|
        course_date = ci.date_in_calendar[0].split(',')
        course_start = Time.parse(course_date[0])
        course_end = Time.parse(course_date[1])
        class_time = (course_end - course_start).to_i
        total_time += class_time
      end
      new_course_date = course_inst_info[:date_in_calendar]
      course_date_arr = new_course_date[0].split(',') 
      n_course_start = Time.parse(course_date_arr[0])
      n_course_end = Time.parse(course_date_arr[1])
      n_course_duration = (n_course_end - n_course_start).to_i
      total_time = total_time + n_course_duration
      if total_time > center.classtime_upper * 3600
        return ErrCode::COURSE_TIME_UPPER
      end
    end
    return nil
  end

  def self.create_course_inst(staff, center, course_inst_info)
    if course_inst_info["length"].to_i != course_inst_info["date_in_calendar"].length
      return ErrCode::COURSE_DATE_UNMATCH
    end
    retval = self.check_upper(center, course_inst_info)
    if retval.present?
      return retval
    end
    course_inst = CourseInst.where(code: course_inst_info[:code]).first
    if course_inst.present?
      return ErrCode::COURSE_INST_EXIST
    end
    course_inst = center.course_insts.create({
      name: course_inst_info[:name],
      available: course_inst_info[:available],
      code: course_inst_info[:code],
      length: course_inst_info[:length],
      address: course_inst_info[:address],
      capacity: course_inst_info[:capacity],
      price: course_inst_info[:price],
      price_pay: course_inst_info[:price_pay],
      date: course_inst_info[:date],
      speaker: course_inst_info[:speaker],
      date_in_calendar: course_inst_info[:date_in_calendar],
      min_age: course_inst_info[:min_age],
      max_age: course_inst_info[:max_age],
      school_id: course_inst_info[:school_id],
      start_course: Time.parse(course_inst_info[:start_course]),
      desc: course_inst_info[:desc]
    })
    if course_inst_info[:path].present?
      m = Material.create(path: course_inst_info[:path])
      course_inst.photo = m
    end
    course_inst.center = center
    course_inst.save
    Feed.create(course_inst_id: course_inst.id, name: course_inst.name, center_id: center.id, available: course_inst_info[:available])
    { course_inst_id: course_inst.id.to_s }
  end

  def course_inst_info
    {
      id: self.id.to_s,
      name: self.name || self.course.name,
      available: self.available,
      speaker: self.speaker,
      school: self.school.try(:name),
      center: self.center.name,
      price: self.price,
      price_pay: self.price_pay,
      address: self.address,
      date: self.date,
      course_participates: self.course_participates.size,
      amount: self.bills.sum("amount").to_i
    }
  end

  def update_info(course_inst_info)
    course_inst = CourseInst.where(code: course_inst_info["code"]).first
    if course_inst.present? && course_inst.id != self.id
      return ErrCode::COURSE_INST_EXIST
    end
    if course_inst_info["length"].to_i != course_inst_info["date_in_calendar"].length
      return ErrCode::COURSE_DATE_UNMATCH
    end

    retval = CourseInst.check_upper(self.center, course_inst_info)
    if retval.present?
      return retval
    end

    self.update_attributes(
      {
        code: course_inst_info["code"],
        # inst_code: course_inst_info["code"],
        price: course_inst_info["price"],
        price_pay: course_inst_info["price_pay"],
        length: course_inst_info["length"],
        capacity: course_inst_info["capacity"],
        date: course_inst_info["date"],
        speaker: course_inst_info["speaker"],
        address: course_inst_info["address"],
        date_in_calendar: course_inst_info["date_in_calendar"],
        min_age: course_inst_info["min_age"],
        max_age: course_inst_info["max_age"],
        school_id: course_inst_info["school_id"],
        start_course: Time.parse(course_inst_info["start_course"]),
        name: course_inst_info["name"],
        desc: course_inst_info["desc"]
      }
    )
    self.feed.update_attribute(:name, course_inst_info["name"])
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
    self.feed.update_attributes({available: available == true}) if self.feed.present?
    nil
  end

  def date_in_calendar_str
    (self.date_in_calendar || []).join(';')
  end

  def start_time
    first_day = self.date_in_calendar[0]
    return nil if first_day.blank?
    start_time = first_day.split(',')[0]
    date = start_time.split('T')[0]
    time = start_time.split('T')[1]
    time = time[0..-4]
    return date + " " + time
  end

  def duration
    first_day = (self.date_in_calendar || [])[0]
    last_day = (self.date_in_calendar || [])[-1]
    return nil if first_day.blank? || last_day.blank?
    start_time = first_day.split(',')[0]
    start_date = start_time.split('T')[0]
    end_time = last_day.split(',')[0]
    end_date = end_time.split('T')[0]
    return start_date + "-" + end_date
  end

  def start_date
    first_day = self.date_in_calendar[0]
    return nil if first_day.blank?
    start_time = first_day.split(',')[0]
    start_date = start_time.split('T')[0]
    return start_date
  end

  def signin_info(class_num)
    retval = [ ]
    cur_group = [ ]
    group_size = 5
    cur_num = 0
    self.course_participates.each do |e|
      next if e.is_success == false
      info = {mobile: e.client.mobile, name: e.client.name_or_parent, signin: e.signin_info[class_num.to_i].present?.to_s}
      if cur_num == group_size
        cur_num = 0
        retval << {line: cur_group}
        cur_group = [ ]
      end
      cur_group << info
      cur_num = cur_num + 1
    end
    if cur_group.present?
      retval << {line: cur_group}
    end
    return {signin_info: retval}
  end

  def is_class_pass?(class_num)
    class_day = (self.date_in_calendar || [])[class_num]
    return false if class_day.blank?
    start_time = class_day.split(',')[0]
    date_str = start_time.split('T')[0]
    date_ary = date_str.split('-').map { |e| e.to_i }
    date = Time.mktime(date_ary[0], date_ary[1], date_ary[2])
    return Time.now - 1.days > date
  end

  # -1 for unknown
  # 1 for not begin
  # 2 for ongoing
  # 4 for end
  UNKNOWN = -1
  NOT_BEGIN = 1
  ONGOING = 2
  OVER = 4
  def status
    if self.date_in_calendar.blank?
      return UNKNOWN
    end
    sort_date = self.date_in_calendar.sort.map { |e| e.split('T')[0] }
    start_day = Time.mktime(*sort_date[0].split('-'))
    end_day = Time.mktime(*sort_date[-1].split('-'))
    if Time.now < start_day
      return NOT_BEGIN
    elsif Time.now < end_day + 1.days
      return ONGOING
    else
      return OVER
    end
  end

  def more_info
    {
      ele_name: self.name || self.course.name,
      ele_id: self.id.to_s,
      ele_photo: self.photo.nil? ? ActionController::Base.helpers.asset_path("web/course.png") : self.photo.path,
      ele_content: ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.course.desc).strip(), length: 50),
      ele_center: self.center.name,
      ele_age: self.min_age.present? ? self.min_age.to_s + "~" + self.max_age.to_s + "岁" : "无",
      ele_price: self.judge_price,
      ele_date:  ActionController::Base.helpers.truncate(self.date.strip(), length: 25),
      ele_status: self.status_class
    }
  end

  def judge_price
    if self.price_pay.to_i == 0
      return "免费"
    else
      return self.price_pay.to_s + "元"
    end
  end

  def effective_signup_num
    # self.course_participates.where(trade_state: "SUCCESS").length
    self.course_participates.select { |e| e.is_effective } .length
  end


  def self.course_stats(duration, start_date, end_date)
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
    interval = day.days.to_i

    cps = CourseParticipate.where(:created_at.gt => start_time)
                                  .where(:created_at.lt => end_time)
                                  .where(trade_state: "SUCCESS")
                                  .asc(:created_at)
    dp_num = (end_time - start_time) / interval
    signup_num = cps.map { |e| (e.created_at.to_i - (start_time.to_i)) / interval }
    signup_num = signup_num.group_by { |e| e }
    signup_num.each { |k,v| signup_num[k] = v.length }
    signup_num = (0 .. dp_num - 1).to_a.map { |e| signup_num[e].to_i }
    # signup_num.reverse!

    income = cps.map { |e| [(e.created_at.to_i - start_time.to_i) / interval, e.price_pay] }
    income = income.group_by { |e| e[0] }
    income.each { |k,v| income[k] = v.map { |e| e[1] } .sum }
    income = (0 .. dp_num - 1).to_a.map { |e| income[e].to_i }
    # income.reverse!


    max_num = 5

    income_center_hash = { }
    Center.all.each do |c|
      c_income = cps.where(center_id: c.id).map { |e| [(e.created_at.to_i - start_time.to_i) / interval, e.price_pay] }
      c_income = c_income.group_by { |e| e[0] }
      c_income.each { |k,v| c_income[k] = v.map { |e| e[1] } .sum }
      c_income = (0 .. dp_num - 1).to_a.map { |e| c_income[e].to_i }
      # c_income.reverse!
      income_center_hash[c.name] = c_income.sum
    end
    income_center = income_center_hash.to_a
    income_center = income_center.sort { |x, y| -x[1] <=> -y[1] }
    if income_center.length > max_num
      ele = ["其他", income_center[max_num - 1..-1].map { |e| e[1] } .sum]
      income_center = income_center[0..max_num - 2] + [ele]
    end

    income_school_hash = { }
    School.all.each do |s|
      s_income = cps.where(school_id: s.id).map { |e| [(e.created_at.to_i - start_time.to_i) / interval, e.price_pay] }
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
      # total_allowance: allowance.sum,
      income_time_unit: time_unit,
      # allowance: allowance,
      income:income,
      # total_money: income.sum,
      income_center: income_center,
      income_school: income_school
    }
  end

  def self.course_rank(max_num = 5)
    courses = CourseInst.all.map do |e|
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
      review_rank: courses.sort { |x, y| -x[:review_score] <=> -y[:review_score] } [0...[max_num, courses.length - 1].min],
      cp_rank: courses.sort { |x, y| -x[:cp_num] <=> -y[:cp_num] } [0...[max_num, courses.length - 1].min],
    }
  end

  def income_stat
    stat = {
      all: 0,
      personal: 0,
      allowance: 0
    }
    self.course_participates.paid.each do |e|
      stat[:personal] += (e.price_pay || self.price_pay)
      stat[:allowance] += (self.price - self.price_pay)
      stat[:all] += (e.price_pay || self.price_pay + self.price - self.price_pay)
    end
    stat
  end

  def get_stat
    cps = self.course_participates.paid
    gender = {'男生' => 0, '女生' => 0, '不详' => 0}
    age = {'0-3岁' => 0, '3-6岁' => 0, '6-9岁' => 0, '9-12岁' => 0, '12-15岁' => 0, "其他及不详" => 0}
    signin = [0] * self.length
    cps.each do |e|
      if e.client.gender == 0
        gender['男生'] += 1
      elsif e.client.gender == 1
        gender['女生'] += 1
      else
        gender['不详'] += 1
      end
      if e.client.birthday.blank?
        age["其他及不详"] += 1
      else
        birth_at = Time.mktime(e.client.birthday.year, e.client.birthday.month, e.client.birthday.day)
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
        self.length.times do |ee|
          if e.signin_info[ee].present?
            signin[ee] += 1
          end
        end
      end
    end
    signin.map! { |e| (e * 1.0 / self.effective_signup_num * 100).round(1) }
    num = []
    signup_time_ary = cps.map { |e| e.created_at.to_i } .sort
    signup_time_ary.each do |e|
      week_idx = (e - signup_time_ary[0]) / 1.weeks.to_i
      num[week_idx] ||= 0
      num[week_idx] += 1
    end
    num.each_with_index { |e, i| num[i] ||= 0 }
    {
      gender: gender.to_a,
      age: age.to_a,
      num: num,
      signin: signin,
      signup_start_str: signup_time_ary.present? ? Time.at(signup_time_ary[0]).strftime('%Y-%m-%d') : nil
    }
  end

  def status_class
    if Time.zone.parse(self.start_time).future?
      if self.capacity <= self.effective_signup_num
        return "greyribbon"
      elsif self.capacity - self.effective_signup_num <= 5 && self.capacity - self.effective_signup_num > 0
        return "redribbon"
      else
        return "greenribbon"
      end
    else
      return "endribbon"
    end
  end

  def self.price_for_select
    hash = { "选择价格区间" => 0, "免费" => 1, "0~20元" => 2, "20~40元" => 3, "40元以上" => 4 }
  end

  def self.migrate
    Center.all.map do |c|
      c.update_attributes({
        year: 2017,
        code: 1
        })
      c.course_insts.all.map do |ci|
        ci.update_attributes({
          name: ci.name.blank? ? ci.course.name : ci.name,
          capacity: ci.capacity.blank? ? ci.course.capacity : ci.capacity,
          price: ci.price.blank? ? ci.course.price : ci.price,
          price_pay: ci.price_pay.blank? ? ci.course.price_pay : ci.price_pay,
          length: ci.length.blank? ? ci.course.length : ci.length,
          desc: ci.desc.blank? ? ci.course.desc : ci.desc,
          start_course: Time.zone.parse(ci.start_time).to_time,
          code: c.get_code 
          })
      end
    end
  end

end
  