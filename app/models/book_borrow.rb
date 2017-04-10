class BookBorrow

  include Mongoid::Document
  include Mongoid::Timestamps

  NORMAL = 1
  LOST = 2

  field :status, type: Integer, default: NORMAL
  field :borrow_at, type: Integer
  field :return_at, type: Integer
  field :renew_at, type: Array
  field :latefee, type: Float, default: 0.0
  field :latefee_paid, type: Boolean, default: true

  belongs_to :book_inst
  belongs_to :book
  belongs_to :client, class_name: "User", inverse_of: :book_borrows

  scope :unreturned, ->{ where(status: NORMAL, return_at: nil) }

  def back
  	self.update_attributes({return_at: Time.now.to_i})
    # calculate whether need to pay latefee, and the amount of latefee
    latefee_per_day = BorrowSetting.first.try(:latefee_per_day) || 0.1
    self.latefee = self.expire_days * latefee_per_day
    self.latefee_paid = self.latefee == 0.0
    self.save
    nil
  end

  def lost
    self.update_attributes({return_at: Time.now.to_i, status: LOST})
    # calculate whether need to pay latefee, and the amount of latefee
    latefee_per_day = BorrowSetting.first.try(:latefee_per_day) || 0.1
    self.latefee = self.expire_days * latefee_per_day
    self.latefee_paid = self.latefee == 0.0
    self.save
    # decrease stock by 1
    new_stock = [self.book.stock - 1, 0].max
    self.book.update_attributes({stock: new_stock})
    nil
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

  def self.expired
    borrow_duration = BorrowSetting.first.try(:borrow_duration)
    if borrow_duration.blank?
      return nil
    else
      self.where(return_at: nil, :borrow_at.lt => Time.now.to_i - borrow_duration.days.to_i)
    end
  end

  def return_class
    if self.status == LOST || self.is_expired
      return "overtime"
    end
    if self.return_at.blank?
      return "unreturn"
    end
  end

  def return_status_str
    if self.status == LOST
      return "已丢失"
    end
    if self.is_expired
      return "已逾期，联系电话 " + self.client.mobile
    end
    return self.return_at.present? ? Time.at(self.return_at).strftime("%Y-%m-%d %H:%M") : "暂未归还"
  end

  def status_class
    if self.status == self.is_expired
      return "overtime"
    end
    if self.return_at.blank?
      return "unreturn"
    else
      return "returned"
    end
  end

  def status_str
    if self.is_expired
      return "已逾期"
    end
    return self.return_at.present? ? "已还" : "未还"
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

  def pay_latefee
    self.update_attributes({latefee_paid: true})
  end
end