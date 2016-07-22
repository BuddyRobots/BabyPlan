class Course

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :time, type: String
  field :desc, type: String
  field :target, type: String
  field :price, type: Integer

  has_one :image, class_name: "Material", inverse_of: :course
  has_many :course_insts
  has_many :favorites
  has_many :staff_logs

end