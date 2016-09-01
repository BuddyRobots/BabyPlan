class Center

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :location, type: String
  field :desc, type: String

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
end