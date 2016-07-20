class CourseInst

  include Mongoid::Document
  include Mongoid::Timestamps

  field :course_number, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :price, type: Integer

  belongs_to :course
  belongs_to :center

end