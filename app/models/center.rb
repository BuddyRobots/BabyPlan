class Center

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :location, type: String
  field :desc, type: String
  field :available, type: Boolean

  has_many :course_insts
  has_many :books
  has_many :announcements
  has_many :staffs, class_name: "User", inverse_of: :staff_center


  def self.centers_for_select
    hash = { }
    Center.all.each do |c|
      hash[c.name] = c.id.to_s
    end
    hash 
  end

  def staffs_desc
    if self.staffs.length == 0
      "无"
    elsif self.staffs.length == 1
      self.staffs.first.name
    else
      self.staffs.first.name + "等" + self.staffs.length.to_s + "人"
    end
  end

  def books_desc
    total_stock = 0
    self.books.each { |e| total_stock = total_stock + e.stock }
    self.books.length.to_s + "类/" + total_stock.to_s + "本"
  end

  def courses_desc
    self.course_insts.length.to_s + "门"
  end

  def center_info
    {
      id: self.id.to_s,
      name: self.name,
      address: self.address,
      staffs_desc: self.staffs_desc,
      books_desc: self.books_desc,
      courses_desc: self.courses_desc,
      available: self.available
    }
  end
end