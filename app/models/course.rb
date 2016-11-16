class Course

  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String, default: ""
  field :name, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :time, type: String
  field :desc, type: String
  field :target, type: String
  field :price, type: Integer
  field :price_pay, type: Integer
  field :speaker, type: String
  field :available, type: Boolean

  has_one :photo, class_name: "Material", inverse_of: :course_photo
  has_many :course_insts

  has_many :staff_logs


  def self.create_course(course_info)
    course = Course.create(
      name: course_info[:name],
      length: course_info[:length].to_i,
      desc: course_info[:desc],
      price: course_info[:price],
      price_pay: course_info[:price_pay],
      speaker: course_info[:speaker],
      code: course_info[:code],
      available: course_info[:available]
    )
    { course_id: course.id.to_s }
  end

  def course_info
    {
      id: self.id.to_s,
      name: self.name,
      code: self.code,
      speaker: self.speaker,
      price: self.price,
      available: self.available
    }
  end

  def update_info(course_info)
    self.update_attributes(
      {
        name: course_info["name"],
        price: course_info["price"],
        price_pay: course_info["price_pay"],
        desc: course_info["desc"],
        code: course_info["code"],
        length: course_info["length"],
        speaker: course_info["speaker"]
      }
    )
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
    nil
  end
end