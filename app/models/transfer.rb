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
    self.arrived_books << book_inst.id.to_s
    self.save
    { name: book_inst.book.name, isbn: book_inst.book.isbn }
  end

  def status_class
    return "prepare" if self.status == PREPARE
    return "transit" if self.status == ONGOING
    return "end" if self.status == DONE or self.status == ABNORMAL
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
      self.after_finish
      return {finish: true}
    end
    if force
      self.update_attributes({status: DONE})
      self.after_finish
      return {finish: true}
    else
      return {finish: false}
    end
  end

  def after_finish
    # 1. change the stock of the books in the out center
    books = { }
    self.book_insts.each do |e|
      book_id = e.book.id.to_s
      books[book_id] ||= 0
      books[book_id] += 1
    end
    books.each do |book_id, out_count|
      book = Book.where(id: book_id).first
      stock = [book.stock - out_count, 0].max
      book.update_attributes({stock: stock})
    end
    # 2. create new books in the in center
    books = { }
    uniq_arrived_books = self.arrived_books.uniq
    uniq_arrived_books.each do |e|
      book_inst = BookInst.where(id: e).first
      book_id = book_inst.book.id.to_s
      books[book_id] ||= { }
      books[book_id]["in_count"] ||= 0
      books[book_id]["in_count"] += 1
      books[book_id]["book_inst"] ||= []
      books[book_id]["book_inst"] << book_inst
    end
    books.each do |book_id, info|
      book = Book.where(id: book_id).first
      cover = book.cover
      back = book.back
      new_book = book.clone
      new_book.center = self.in_center
      if cover.present?
        new_cover = cover.clone
        new_cover.save
        new_cover.cover_book = new_book
        new_cover.save
      end
      if back.present?
        new_back = back.clone
        new_back.save
        new_back.back_book = new_book
        new_back.save
      end
      new_book.stock = info["in_count"]
      new_book.save
      books[book_id]["book_inst"].each do |book_inst|
        book_inst.book = new_book
        book_inst.save
      end
    end
  end

  def transfer_info
    {
      id: self.id.to_s,
      out_center: self.out_center.name,
      in_center: self.in_center.name,
      out_time: self.out_time,
      in_time: self.in_time,
      status: self.status,
      status_str: self.status_str,
      status_class: self.status_class,
      count: self.book_insts.count
    }
  end
end
