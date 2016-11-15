class Favorite
	include Mongoid::Document
	include Mongoid::Timestamps
	
	field :enabled, type: Boolean

	belongs_to :user
	belongs_to :course_inst
	belongs_to :book
end