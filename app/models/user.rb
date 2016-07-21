class User

  include Mongoid::Document
  include Mongoid::Timestamps

  CLIENT = 1
  STAFF = 2
  ADMIN = 4

  field :email, type: String
  field :mobile, type: String
  field :password, type: String
  field :name, type: String
  field :user_type, type: Integer, default: CLIENT
  field :email_verified, type: Boolean, default: false
  field :email_verify_code, type: String
  field :mobile_verified, type: Boolean, default: false
  field :mobile_verify_code, type: String

  # relationships specific for clients
  belongs_to :client_center
  has_many :course_participates, class_name: "CourseParticipate", inverse_of: :client
  has_many :book_borrows, class_name: "BookBorrow", inverse_of: :client
  has_many :feedbacks
  has_many :favorites

  # relationships specific for staff
  belongs_to :staff_center
  has_many :announcements
  has_many :staff_logs

  scope :client, ->{ where(user_type: CLIENT) }
  scope :staff, ->{ where(user_type: STAFF) }
  scope :admin, ->{ where(user_type: ADMIN) }

  def self.create_client(mobile)
    # 1. check whether user exists?
    u = User.where(mobile: mobile).first
    if u.present?
      return -1
    else
      u = User.create(user_type: CLIENT, mobile: mobile)
    end

    # 2. generate random code and save
    code = "111111"
    u.update_attribute(:mobile_verify_code, code)

    # 3. send message
    
    # 4. return user id
    u.id.to_s
  end

  def self.create_staff(email, password)
    # 1. create the user in the database, with password encrypted

    # 2. generate a verify code for the new staff user

    # 3. send email

    # 4. return the new user instance
  end

end
