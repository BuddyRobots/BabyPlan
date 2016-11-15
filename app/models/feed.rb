class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :course_inst
  belongs_to :book
  belongs_to :announcement

  belongs_to :center


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
      self.course_inst.desc
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
end