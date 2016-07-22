class Favorite
	include Mongoid::Document
	include Mongoid::Timestamps
	
	field :favorite_type, type: Integer

	belongs_to :user
	belongs_to :book
	belongs_to :course
	belongs_to :announcement
end