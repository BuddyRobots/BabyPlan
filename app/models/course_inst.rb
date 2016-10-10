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
  belongs_to :course
  belongs_to :center

  #relationships specific for course_participate
  has_many :course_participates

  has_many :feedbacks


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
    { course_inst_id: course_inst.id.to_s }
  end

  def course_inst_info
    {
      id: self.id.to_s,
      name: self.course.name,
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
end
