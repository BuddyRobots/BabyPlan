class BookInst

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :book
  has_many :book_borrows

  def borrow(client)
    if self.current_borrow.present?
      return ErrCode::BOOK_NOT_RETURNED
    end
    borrow = self.book_borrows.create(borrow_at: Time.now.to_i, client_id: client.id)
    { borrow_id: borrow.id.to_s }
  end

  def current_borrow
    self.book_borrows.where(return_at: nil).first
  end

  def status_str
    if self.current_borrow.present?
      "借出"
    else
      "在架上"
    end
  end

  def borrow_info
    if self.current_borrow.blank?
      ""
    else
      client = self.current_borrow.client
      client.name + "，" + client.mobile
    end
  end
end