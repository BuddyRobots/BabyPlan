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
end