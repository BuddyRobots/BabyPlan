class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :course_inst
  belongs_to :book
  belongs_to :announcement

  belongs_to :center


  def center_str
  	
  end
end