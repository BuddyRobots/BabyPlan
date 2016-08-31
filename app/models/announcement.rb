class Announcement
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :content, type: String
  field :is_published, type: Boolean
  field :plain_text, type: String
  field :image_path, type: String

  belongs_to :center
  belongs_to :staff, class_name:"User", inverse_of: :announcement

  has_many :favorites
  has_many :staff_logs

  def self.create_announcement(staff, announcement_info, scope)
    html = Nokogiri::HTML(announcement_info[:content])
    info = {
      title: announcement_info[:title],
      content: announcement_info[:content],
      is_published: announcement_info[:is_published],
      plain_text: html.text,
      image_path: html.css("img").blank? ? "" : html.css("img")[0].attr("src")
    }
    announcement = scope == "local" ? staff.staff_center.announcements.create(info) : Announcement.create(info)

    { announcement_id: announcement.id.to_s }
  end
end