class StaffLog
	field :operation_type, type: Integer

	belongs_to :staff, class_name:"User", inverse_of: :staff_log
	belongs_to :user
	belongs_to :book
	belongs_to :course
	belongs_to :announcement
end