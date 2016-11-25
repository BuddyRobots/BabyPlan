class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :enabled, type: Boolean

  belongs_to :user
  belongs_to :course_inst
  belongs_to :book

  def name
    if self.course_inst.present?
      self.course_inst.name || self.course_inst.course.name
    else
      self.book.name
    end
  end

  def desc
    if self.course_inst.present?
      self.course_inst.course.desc
    else
      self.book.desc
    end
  end

  def center_str
    if self.course_inst.present?
      self.course_inst.center.name
    else
      self.book.center.name
    end
  end

  def fav_icon
    if self.course_inst.present?
      "ke"
    else
      "hui"
    end
  end

  def img_src
    if self.course_inst.present?
      self.course_inst.photo.nil? ? ActionController::Base.helpers.asset_path("banner.png") : self.course_inst.photo.path
    else
      self.book.cover.nil? ? ActionController::Base.helpers.asset_path("banner.png") : self.book.cover.path
    end
  end

  def ele_url
    if self.course_inst.present?
      "/user_mobile/courses/" + self.course_inst.id.to_s
    else
      "/user_mobile/books/" + self.book.id.to_s
    end
  end
end