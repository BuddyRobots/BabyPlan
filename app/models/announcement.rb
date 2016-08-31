class Announcement
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :content, type: String
  field :is_published, type: Boolean

  belongs_to :center
  belongs_to :staff, class_name:"User", inverse_of: :announcement

  has_many :favorites
  has_many :staff_logs

  def self.create_announcement
    
  end
end