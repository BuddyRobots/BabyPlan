class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # field :feedback_type, type: Integer
  field :score, type: Integer
  field :content, type: String
  field :status, type: Integer

  belongs_to :course_inst
  belongs_to :announcement
  belongs_to :book
  belongs_to :client, class_name: "User", inverse_of: :feedbacks
  belongs_to :staff, class_name: "User", inverse_of: :audit_feedbacks

end