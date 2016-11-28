class BookBorrow

  include Mongoid::Document
  include Mongoid::Timestamps

  NORMAL = 1
  LOST = 2

  field :status, type: Integer, default: NORMAL
  field :borrow_at, type: Integer
  field :return_at, type: Integer
  field :renew_at, type: Array

  belongs_to :book_inst
  belongs_to :book
  belongs_to :client, class_name: "User", inverse_of: :book_borrows

  scope :unreturned, ->{ where(status: NORMAL, return_at: nil) }

  def back
  	self.update_attributes({return_at: Time.now.to_i})
  end

  def review
    self.client.reviews.where(book_id: self.book.id).first
  end

  def is_expired
    borrow_duration = BorrowSetting.first.try(:borrow_duration)
    if borrow_duration.blank?
      return false
    else
      return self.return_at.blank? && Time.now.to_i - borrow_duration.days.to_i > self.borrow_at
    end
  end

  def return_class
    if self.is_expired
      return "overtime"
    end
    if self.return_at.blank?
      return "unreturn"
    end
  end

  def return_status_str
    if self.is_expired
      return "已逾期，联系电话 " + self.client.mobile
    end
    return self.return_at.present? ? Time.at(self.return_at).strftime("%Y-%m-%d %H:%M") : "暂未归还"
  end

  def expire_days
    borrow_duration = BorrowSetting.first.try(:borrow_duration)
    if borrow_duration.blank?
      return false
    else
      expire_time = ( self.return_at || Time.now.to_i ) - borrow_duration.days.to_i - self.borrow_at
      if expire_time <= 0
        expire_time = 0
      end
      return (expire_time * 1.0 / 1.days.to_i).ceil
    end
  end

  def expire_days_str
    day = self.expire_days
    if day == 0
      return "未逾期"
    else
      return "逾期" + day.to_s + "天"
    end
  end
end