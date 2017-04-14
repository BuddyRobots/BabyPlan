class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :available, type: Boolean

  belongs_to :course_inst
  belongs_to :book
  belongs_to :announcement

  belongs_to :center

  scope :is_available, ->{ where(available: true) }

  def update_available
    if self.announcement.present?
      self.available = self.announcement.is_published
    elsif self.book.present?
      self.available = self.book.available
    elsif self.course_inst.present?
      self.available = self.course_inst.available
    end
  end

  def center_str
    if self.announcement.present? && self.center.blank?
      return "所有儿童中心"
    end
    if self.center.present?
      return self.center.name
    else
      return ""
    end
  end

  def desc
    if self.course_inst.present?
      self.course_inst.course.desc
    elsif self.book.present?
      self.book.desc
    elsif self.announcement.present?
      self.announcement.content
    else
      ""
    end
  end

  def path
    if self.course_inst.present?
      "/courses/#{self.course_inst.id.to_s}"
    elsif self.book.present?
      "/books/#{self.book.id.to_s}"
    elsif self.announcement.present?
      "/announcements/#{self.announcement.id.to_s}"
    else
      ""
    end
  end

  def feed_icon
    if self.course_inst.present?
      "ke"
    elsif self.book.present?
      "hui"
    else
      "gao"
    end
  end

  def img_src
    if self.course_inst.present?
      self.course_inst.photo.nil? ? ActionController::Base.helpers.asset_path("web/course.png") : self.course_inst.photo.path
    elsif self.book.present?
      self.book.cover.nil? ? ActionController::Base.helpers.asset_path("web/book.png") : self.book.cover.path
    else
      self.announcement.try(:photo).nil? ? ActionController::Base.helpers.asset_path("web/announcement.png") : self.announcement.try(:photo).path
    end
  end

  def more_info
    {
      ele_name: self.name,
      ele_path: self.path,
      ele_photo: self.img_src,
      ele_content: ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.desc).strip(), length: 50),
      ele_icon: self.feed_icon,
      ele_center: self.center_str,
      ele_course: self.course_inst.present?,
      ele_age: self.course_inst.present? ? self.course_inst.min_age.present? ? self.course_inst.min_age.to_s + "~" + self.course_inst.max_age.to_s + "岁" : "无" : "",
      ele_price: self.course_inst.present? ? self.course_inst.judge_price : "",
      ele_date: self.course_inst.present? ? ActionController::Base.helpers.truncate(self.course_inst.date.strip(), length: 25) : "",
      ele_status_class: self.course_inst.present? ? self.course_inst.status_class : ""
    }
  end
end