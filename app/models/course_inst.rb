class CourseInst

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :available, type: Boolean
  field :code, type: String
  field :inst_code, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :price, type: Integer
  field :price_pay, type: Integer
  field :speaker, type: String
  field :date, type: String
  field :date_in_calendar, type: Array, default: [ ]

  has_one :photo, class_name: "Material", inverse_of: :course_inst_photo
  has_one :feed
  belongs_to :course
  belongs_to :center

  #relationships specific for course_participate
  has_many :course_participates

  has_many :reviews
  has_many :favorites


  def self.create_course_inst(staff, center, course_inst_info)
    course = Course.where(id: course_inst_info[:course_id]).first
    code = course.code + "-" + course_inst_info[:code]
    course_inst = CourseInst.where(code: code).first
    if course_inst.present?
      return ErrCode::COURSE_INST_EXIST
    end
    course_inst = course.course_insts.create({
      name: course.name,
      available: course_inst_info[:available],
      code: code,
      inst_code: course_inst_info[:code],
      length: course_inst_info[:length],
      address: course_inst_info[:address],
      capacity: course_inst_info[:capacity],
      price: course_inst_info[:price],
      price_pay: course_inst_info[:price_pay],
      date: course_inst_info[:date],
      speaker: course_inst_info[:speaker],
      date_in_calendar: course_inst_info[:date_in_calendar]
    })
    course_inst.center = center
    course_inst.save
    Feed.create(course_inst_id: course_inst.id, name: course.name, center_id: center.id)
    { course_inst_id: course_inst.id.to_s }
  end

  def course_inst_info
    {
      id: self.id.to_s,
      name: self.name || self.course.name,
      available: self.available,
      speaker: self.speaker,
      price: self.price,
      price_pay: self.price_pay,
      address: self.address,
      date: self.date
    }
  end

  def update_info(course_inst_info)
    self.update_attributes(
      {
        code: self.course.code + "-" + course_inst_info["code"],
        inst_code: course_inst_info["code"],
        price: course_inst_info["price"],
        price_pay: course_inst_info["price_pay"],
        length: course_inst_info["length"],
        date: course_inst_info["date"],
        speaker: course_inst_info["speaker"],
        address: course_inst_info["address"],
        date_in_calendar: course_inst_info["date_in_calendar"]
      }
    )
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
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

  def signin_info(class_num)
    retval = [ ]
    cur_group = [ ]
    group_size = 6
    cur_num = 0
    self.course_participates.each do |e|
      next if e.is_success == false
      info = {mobile: e.client.mobile, name: e.client.name, signin: e.signin_info[class_num]}
      if cur_num == group_size
        cur_num = 0
        retval << cur_group
        cur_group = [ ]
      end
      cur_group << info
      cur_num = cur_num + 1
    end
    return retval
  end

  def is_class_pass?(class_num)
    class_day = self.date_in_calendar[class_num]
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
end
