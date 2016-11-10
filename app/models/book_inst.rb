class BookInst

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :book
  has_many :book_borrows

  def borrow(client)
  	if self.book_borrows.where(returned_at: nil).present?
  		return ErrCode::BOOK_NOT_RETURNED
  	end
  	borrow = self.book_borrows.create(borrow_at: Time.now.to_i, client_id: client.id)
  	{ borrow_id: borrow.id.to_s }
  end
end