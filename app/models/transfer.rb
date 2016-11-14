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

  def arrive(book_inst_id)
    book_inst = BookInst.where(id: book_inst_id).first
    return ErrCode::BOOK_NOT_IN_TRANSFER if !self.book_insts.include?(book_inst)
    if !self.arrived_books.include?(book_inst.id.to_s)
      self.arrived_books << book_inst.id.to_s
    end
    self.save
    { name: book_inst.book.name, isbn: book_inst.book.isbn }
  end

  def status_str
    if self.status == PREPARE
      return "准备中"
    end
    if self.status == ONGOING
      return "运输中"
    end
    if self.status == DONE
      return "已完成"
    end
    if self.status == ABNORMAL
      return "绘本有缺失"
    end
  end

  def lost_books_info
    lost_book_insts = []
    self.book_insts.each do |book_inst|
      if !self.arrived_books.include?(book_inst.id.to_s)
        lost_book_insts << book_inst
      end
    end
    lost_books = { }
    lost_book_insts.each do |e|
      book_id = e.book.id.to_s
      lost_books[book_id] ||= 0
      lost_books[book_id] += 1
    end
    lost_books_info = []
    lost_books.each do |book_id, count|
      lost_books_info << {
        name: Book.where(id: book_id).first.name,
        count: count
      }
    end
    return lost_books_info
  end

  def books_info
    books = { }
    self.book_insts.each do |e|
      book_id = e.book.id.to_s
      books[book_id] ||= 0
      books[book_id] += 1
    end
    books_info = []
    books.each do |book_id, count|
      books_info << {
        name: Book.where(id: book_id).first.name,
        count: count
      }
    end
    return books_info
  end

  def confirm_transfer_out
    self.update_attributes({status: ONGOING, out_time: Time.now.to_i})
    # update the book stock of the 
    nil
  end

  def finish(force)
    lost_book_insts = []
    self.book_insts.each do |book_inst|
      if !self.arrived_books.include?(book_inst.id.to_s)
        lost_book_insts << book_inst
      end
    end
    if lost_book_insts.blank?
      self.update_attributes({status: DONE})
      return {finish: true}
    end
    if force
      self.update_attributes({status: DONE})
      return {finish: true}
    else
      return {finish: false}
    end
  end
end