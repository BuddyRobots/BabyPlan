class Center

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :lat, type: String
  field :lng, type: String
  field :desc, type: String
  field :available, type: Boolean

  has_one :photo, class_name: "Material", inverse_of: :center_photo
  has_many :course_insts
  has_many :books
  has_many :announcements
  has_many :staffs, class_name: "User", inverse_of: :staff_center

  has_many :out_transfers, class_name: "Transfer", inverse_of: "out_center"
  has_many :in_transfers, class_name: "Transfer", inverse_of: "in_center"

  has_many :feeds

  has_and_belongs_to_many :clients, class_name: "User", inverse_of: :client_centers

  def self.create_center(center_info)
    center = Center.create(
      name: center_info[:name],
      address: center_info[:address],
      desc: center_info[:desc],
      available: center_info[:available],
      lat: center_info[:lat],
      lng: center_info[:lng]
    )
    { center_id: center.id.to_s }
  end

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
    self.books.length.to_s + "种/" + total_stock.to_s + "本"
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

  def set_available(available)
    self.update_attribute(:available, available == true)
    nil
  end

  def update_info(center_info)
    self.update_attributes(
      {
        name: center_info["name"],
        address: center_info["address"],
        desc: center_info["desc"],
        lat: center_info["lat"],
        lng: center_info["lng"]
      }
    )
    nil
  end

end