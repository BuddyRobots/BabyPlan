class Topic

	include Mongoid::Document
	include Mongoid::Timestamps

	has_many :votes, dependent: :destroy
end