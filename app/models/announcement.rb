class Announcement
  field :text, type: String

  belongs_to :center
  belongs_to :staff, class_name:"User", inverse_of: :announcement

  has_many :favorites
  has_many :staff_logs
end