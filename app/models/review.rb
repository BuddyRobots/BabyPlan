class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  PUBLIC=1
  PRIVATE=2
  
  field :score, type: Integer
  field :content, type: String
  field :status, type: Integer, default: PRIVATE

  belongs_to :course_inst
  belongs_to :book
  belongs_to :course
  belongs_to :client, class_name: "User", inverse_of: :reviews
  belongs_to :staff, class_name: "User", inverse_of: :audit_reviews

  def review_info
    {
      score: self.score,
      content: self.content,
      user_name: self.client.name,
      created_at: self.created_at,
      avatar_path: self.client.avatar.try(:path)
    }
  end

  def self.public_and_mine(client)
    r1 = self.where(status: PUBLIC)
    r2 = self.where(client_id: client.id)
    r1.merge(r2)
  end

  def is_private
    return self.status == PRIVATE
  end

  def show
    self.update_attributes({status: PUBLIC})
    nil
  end

  def hide
    self.update_attributes({status: PRIVATE})
    nil
  end

  def more_info
    {
      ele_name: self.client.name,
      ele_photo: self.client.avatar.nil? ? ActionController::Base.helpers.asset_path("wap/avatar.png") : self.client.avatar.path,
      ele_content: ActionController::Base.helpers.truncate(self.content.strip, length: 50),
      ele_score: self.score.to_s,
      ele_created_at: self.created_at.strftime("%Y-%m-%d %H:%M"),
      ele_star1: ActionController::Base.helpers.asset_path("wap/star1.png"),
      ele_star2: ActionController::Base.helpers.asset_path("wap/star2.png")
    }
  end

end