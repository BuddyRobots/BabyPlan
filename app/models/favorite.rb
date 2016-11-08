class Favorite
	include Mongoid::Document
	include Mongoid::Timestamps
	
	field :enabled, type: Integer

	belongs_to :user
	belongs_to :course_inst
end