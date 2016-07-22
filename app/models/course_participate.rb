class CourseParticipate

  include Mongoid::Document
  include Mongoid::Timestamps

  field :sign_up_time, type: Integer
  field :sign_in_time, type: String
  field :paid, type: Boolean

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :course_participates

end