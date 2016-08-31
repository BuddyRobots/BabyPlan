class User

  include Mongoid::Document
  include Mongoid::Timestamps

  CLIENT = 1
  STAFF = 2
  ADMIN = 4

  BOY = 1
  GIRL = 2

  field :email, type: String
  field :mobile, type: String
  field :password, type: String
  field :name, type: String
  field :user_type, type: Integer, default: CLIENT
  field :email_verified, type: Boolean, default: false
  field :email_verify_code, type: String
  field :mobile_verified, type: Boolean, default: false
  field :mobile_verify_code, type: String
  field :password_verify_code, type: String
  field :auth_key, type: String

  # for staff
  NEW = 1
  NORMAL = 2
  LOCKED = 4
  field :center, type: String
  field :status, type: Integer

  # for client
  field :gender, type: Integer  # 0 for male, 1 for female
  field :birthday, type: Date
  field :parent, type: String
  field :address, type: String
  field :created_by_staff, type: Boolean, default: false

  # relationships specific for clients
  belongs_to :client_center
  has_many :course_participates, class_name: "CourseParticipate", inverse_of: :client
  has_many :book_borrows, class_name: "BookBorrow", inverse_of: :client
  has_many :feed_backs
  has_many :favorites

  # relationships specific for staff
  belongs_to :staff_center, class_name: "Center", inverse_of: :staffs
  has_many :announcements
  has_many :staff_logs

  scope :client, ->{ where(user_type: CLIENT) }
  scope :staff, ->{ where(user_type: STAFF) }
  scope :admin, ->{ where(user_type: ADMIN) }


  def self.create_user(user_type, mobile, created_by_staff = false)
    # 1. check whether user exists?
    u = User.where(mobile: mobile).first
    if u.present? && u.mobile_verified
      return ErrCode::USER_EXIST
    elsif u.blank?
      u = User.create(user_type: user_type, mobile: mobile)
    end

    if user_type == CLIENT
      u.update_attribute(:created_by_staff, created_by_staff)
    end

    # 2. generate random code and save
    code = "111111"
    u.update_attribute(:mobile_verify_code, code)

    # 3. send message
    
    # 4. return user id
    { uid: u.id.to_s }
  end

  def self.find_by_auth_key(auth_key)
    User.where(auth_key: auth_key).first
  end

  def self.signin_staff(mobile, password)
    user = User.staff.where(mobile: mobile).first || User.admin.where(mobile: mobile).first
    return ErrCode::USER_NOT_EXIST if user.nil?
    return ErrCode::USER_NOT_VERIFIED if user.mobile_verified == false
    return ErrCode::WRONG_PASSWORD if Encryption.encrypt_password(password) != user.password
    return ErrCode::NO_CENTER if user.staff_center.blank?
    auth_key = user.generate_auth_key
    user.update_attribute(:auth_key, auth_key)
    return { auth_key: auth_key }
  end

  def self.signin_admin(mobile, password)
    user = User.admin.where(mobile: mobile).first
    return ErrCode::USER_NOT_EXIST if user.nil?
    return ErrCode::USER_NOT_VERIFIED if user.mobile_verified == false
    return ErrCode::WRONG_PASSWORD if Encryption.encrypt_password(password) != user.password
    return ErrCode::NO_CENTER if user.staff_center.blank?
    auth_key = user.generate_auth_key
    user.update_attribute(:auth_key, auth_key)
    return { auth_key: auth_key }
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end

  def verify_staff(name, center_name, password, verify_code)
    if mobile_verify_code != verify_code
      return ErrCode::WRONG_VERIFY_CODE
    end
    center = Center.where(name: center_name).first
    if center.nil?
      return ErrCode::CENTER_NOT_EXIST
    end
    self.update_attributes(name: name, mobile_verified: true, status: NEW, password: Encryption.encrypt_password(password))
    self.staff_center = center
    self.save
    nil
  end

  def verify_client(name, gender, birthday, parent, address, verify_code)
    if mobile_verify_code != verify_code
      return ErrCode::WRONG_VERIFY_CODE
    end
    ary = birthday.split('-').map { |e| e.to_i }
    self.update_attributes(name: name, mobile_verified: true, gender: gender.to_i, birthday: Date.new(ary[0], ary[1], ary[2]), parent: parent, address: address)
    # todo: send password message
    nil
  end

  def forget_password
    if self.mobile_verified == false
      return ErrCode::USER_NOT_VERIFIED
    end

    # generate random code and save
    code = "111111"
    self.update_attribute(:password_verify_code, code)

    # todo: send message

    { uid: self.id.to_s }
  end

  def reset_password(password, verify_code)
    if self.mobile_verified == false
      return ErrCode::USER_NOT_VERIFIED
    end

    if self.password_verify_code != verify_code
      return ErrCode::WRONG_VERIFY_CODE
    end
    self.update_attributes(password: Encryption.encrypt_password(password))
    nil
  end

  def is_staff
    return self.user_type == User::STAFF
  end

  def is_admin
    return self.user_type == User::ADMIN
  end

  def client_info
    {
      id: self.id.to_s,
      name: self.name,
      gender: self.gender,
      age: self.birthday.present? ? Date.today.year - self.birthday.year : nil,
      parent: self.parent,
      mobile: self.mobile,
      address: self.address
    }
  end

  def staff_info
    status_hash = {
      NEW: "新创建",
      LOCKED: "锁定中",
      NORMAL: "正常"
    }
    {
      id: self.id.to_s,
      name: self.name,
      center: self.staff_center.try(:name),
      status: status_hash[self.status]
    }
  end
end
