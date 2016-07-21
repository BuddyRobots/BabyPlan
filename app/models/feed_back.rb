class FeedBack
	field :feedback_type, type: Integer
	field :score, type: Integer
	field :text, type: String
	field :status, type: Integer

	belongs_to :user
	belongs_to :book
	belongs_to :course_inst

end