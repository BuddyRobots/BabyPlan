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
      user_name: self.client.name_or_parent,
      created_at: self.created_at,
      avatar_path: self.client.avatar.try(:path)
    }
  end

  def self.public_and_mine(client)
    r1 = self.where(status: PUBLIC)
    r2 = self.where(client_id: client.id)
    r1.concat(r2).uniq
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
end