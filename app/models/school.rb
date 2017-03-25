class School
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :manager, type: String
  field :mobile, type: Integer
  field :available, type: Boolean

  has_and_belongs_to_many :course_insts
  has_and_belongs_to_many :centers


  scope :is_available, ->{where(available: true)}

  def self.create_school(school_info)
    if School.where(name: school_info[:name]).present?
      return ErrCode::UNITY_IS_EXIST
    end
    school = School.create({
      name: school_info[:name],
      manager: school_info[:manager],
      mobile: school_info[:mobile],
      available: school_info[:available]
      })
    {school_id: school.id.to_s}
  end

  def school_info
    {
      id: self.id.to_s,
      name: self.name,
      manager: self.manager,
      mobile: self.mobile,
      available: self.available
    }
  end
end