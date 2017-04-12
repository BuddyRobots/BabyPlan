class BookInst

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :book
  has_many :book_borrows
  has_and_belongs_to_many :transfers

  def borrow(client)
    if self.book.available == false
      return ErrCode::BOOK_NOT_AVAILABLE
    end
    if self.current_borrow.present?
      return ErrCode::BOOK_NOT_RETURNED
    end
    on_shelf = self.book.stock - self.book_borrows.where(status: BookBorrow::NORMAL, return_at: nil).length
    if on_shelf <= 0
      return ErrCode::BOOK_ALL_OFF_SHELF
    end
    if self.current_transfer.present?
      return ErrCode::BOOK_IN_TRANSFER
    end
    if client.has_expired_book
      return ErrCode::HAS_EXPIRED_BOOK
    end
    if !client.deposit_paid
      return ErrCode::DEPOSIT_NOT_PAID
    end
    if client.latefee_not_paid
      return ErrCode::LATEFEE_NOT_PAID
    end
    if client.reach_max_borrow
      return ErrCode::REACH_MAX_BORROW
    end
    borrow = self.book_borrows.create(borrow_at: Time.now.to_i, client_id: client.id)
    borrow.book = self.book
    borrow.save
    { borrow_id: borrow.id.to_s }
  end

  def current_borrow
    self.book_borrows.where(return_at: nil).first
  end

  def current_transfer
    self.transfers.any_of({status: Transfer::PREPARE}, {status: Transfer::ONGOING}) .first
  end

  def status_str
    if self.current_borrow.present?
      "借出"
    elsif self.book.available == false
      "已下架"
    else
      "在架上"
    end
  end

  def borrow_info
    if self.current_borrow.blank?
      ""
    else
      client = self.current_borrow.client
      client.name_or_parent + "，" + client.mobile
    end
  end
end