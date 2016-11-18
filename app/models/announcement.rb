class Announcement
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :content, type: String
  field :is_published, type: Boolean
  field :plain_text, type: String
  # field :image_path, type: String

  belongs_to :center
  belongs_to :staff, class_name:"User", inverse_of: :announcement

  has_one :photo, class_name: "Material", inverse_of: :announcement_photo
  has_many :favorites
  has_many :staff_logs
  has_one :feed

  scope :is_available, ->{ where(is_published: true) }

  def self.create_announcement(staff, center, announcement_info, scope)
    html = Nokogiri::HTML(announcement_info[:content])
    info = {
      title: announcement_info[:title],
      content: announcement_info[:content],
      is_published: announcement_info[:is_published],
      plain_text: html.text
      # image_path: html.css("img").blank? ? "" : html.css("img")[0].attr("src")
    }
    announcement = scope == "local" ? center.announcements.create(info) : Announcement.create(info)

    feed = Feed.create(announcement_id: announcement.id, name: announcement.title, available: announcement_info[:is_published])
    if scope == "local"
      feed.center = center
      feed.save
    end

    { announcement_id: announcement.id.to_s }
  end

  def update_announcement(announcement_info)
    html = Nokogiri::HTML(announcement_info[:content])
    info = {
      title: announcement_info[:title],
      content: announcement_info[:content],
      plain_text: html.text
      # image_path: html.css("img").blank? ? "" : html.css("img")[0].attr("src")
    }
    self.update_attributes(info)
    { announcement_id: self.id.to_s }
  end

  def set_publish(publish)
    self.update_attribute(:is_published, publish == true)
    self.feed.update_attributes({available: publish == true})
    nil
  end

  def status_str
    self.is_published ? "已公布" : "未公布"
  end

  def more_info
    {
      ele_name: self.title,
      ele_id: self.id.to_s,
      ele_photo: self.photo.nil? ? "/assets/banner.png" : self.photo.path,
      ele_content: ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.content).strip(), length: 50),
      ele_center: self.center.present? ? self.center.name : "所有儿童中心"
    }
  end
end