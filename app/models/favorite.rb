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
    end
  end

  def end_date
    if self.course_inst.present?
      self.course_inst.end_date
    end
  end

  def status_class
    if self.course_inst.present?
      self.course_inst.status_class
    end
  end

  def status_str
    if self.course_inst.present?
      self.course_inst.status_str
    end
  end

  def speaker
    if self.course_inst.present?
      self.course_inst.speaker
    end
  end

  def address
    if self.course_inst.present?
      self.course_inst.address
    end
  end

  def img_src
    if self.course_inst.present?
      self.course_inst.photo.nil? ? ActionController::Base.helpers.asset_path("banner.png") : self.course_inst.photo.path
    end
  end

  def ele_url
    if self.course_inst.present?
      "/user_mobile/courses/" + self.course_inst.id.to_s
    end
  end
end