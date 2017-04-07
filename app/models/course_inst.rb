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
  field :school, type: String
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

  belongs_to :school
  scope :is_available, ->{ where(available: true) }
  default_scope { where(:deleted.ne => true) }


  def self.create_course_inst(staff, center, course_inst_info)
    if course_inst_info["length"].to_i != course_inst_info["date_in_calendar"].length
      return ErrCode::COURSE_DATE_UNMATCH
    end

    # course = Course.where(id: course_inst_info[:course_id]).first
    # code = course.code + "-" + course_inst_info[:code]
    course_inst = CourseInst.where(code: course_inst_info[:code]).first
    if course_inst.present?
      return ErrCode::COURSE_INST_EXIST
    end
    course_inst = center.course_insts.create({
      name: course_inst_info[:name],
      available: course_inst_info[:available],
      # code: code,
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
      school: course_inst_info[:school],
      start_course: course_inst_info[:start_course],
      desc: course_inst_info[:desc]
    })
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
      amount: self.bills.sum("amount")
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
        school: course_inst_info["school"],
        start_course: course_inst_info["start_course"],
        desc: course_inst_info["desc"]
      }
    )
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
    if Date.parse(self.start_time).future?
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
          start_course: DateTime.parse(ci.start_time).to_time,
          code: c.get_code 
          })
      end
    end
  end

end
  