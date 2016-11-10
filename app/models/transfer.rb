class Transfer

  include Mongoid::Document
  include Mongoid::Timestamps

  PREPARE = 1
  ONGOING = 2
  DONE = 4
  ABNORMAL = 8

  field :out_time, type: Time
  field :in_time, type: Time
  field :status, type: Integer, default: PREPARE
  field :arrived_books, type: Array, default: []

  belongs_to :out_center, class_name: "Center", inverse_of: :out_transfers
  belongs_to :in_center, class_name: "Center", inverse_of: :in_transfers
  has_and_belongs_to_many :book_insts

  def self.create_new(out_transfer_id, in_transfer_id)
    out_center = Center.where(id: out_transfer_id).first
    in_center = Center.where(id: in_transfer_id).first
    if out_center.nil? or in_center.nil?
      return ErrCode::CENTER_NOT_EXIST
    end
    transfer = self.create
    transfer.out_center = out_center
    transfer.in_center = in_center
    transfer.save
    { transfer_id: transfer.id.to_s }
  end

  def add(center_id, book_inst_id)
    book_inst = BookInst.where(id: book_inst_id).first
    return ErrCode::BOOK_NOT_EXIST if book_inst.nil?
    return ErrCode::BOOK_NOT_EXIST if book_inst.book.center.id.to_s != center_id
    return ErrCode::BOOK_NOT_RETURNED if book_inst.current_borrow.present?
    return ErrCode::BOOK_IN_TRANSFER if book_inst.current_transfer.present?

    self.book_insts << book_inst
    { name: book_inst.book.name, isbn: book_inst.book.isbn }
  end
end