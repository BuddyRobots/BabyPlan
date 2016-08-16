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
  field :password_verify_code, type: String
  field :auth_key

  # relationships specific for clients
  belongs_to :client_center
  has_many :course_participates, class_name: "CourseParticipate", inverse_of: :client
  has_many :book_borrows, class_name: "BookBorrow", inverse_of: :client
  has_many :feed_backs
  has_many :favorites

  # relationships specific for staff
  belongs_to :staff_center
  has_many :announcements
  has_many :staff_logs

  scope :client, ->{ where(user_type: CLIENT) }
  scope :staff, ->{ where(user_type: STAFF) }
  scope :admin, ->{ where(user_type: ADMIN) }


  def self.create_user(user_type, mobile)
    # 1. check whether user exists?
    u = User.where(mobile: mobile).first
    if u.present? && u.mobile_verified
      return ErrCode::USER_EXIST
    elsif u.blank?
      u = User.create(user_type: user_type, mobile: mobile)
    end

    # 2. generate random code and save
    code = "111111"
    u.update_attribute(:mobile_verify_code, code)

    # 3. send message
    
    # 4. return user id
    { uid: u.id.to_s }
  end

  def self.find_by_auth_key(auth_key)
    info = Encryption.decrypt_auth_key(auth_key)
    user_id = info.split(',')[0]
    User.where(id: user_id).first
  end

  def self.signin(mobile, password)
    user = User.where(mobile: mobile).first
    return ErrCode::USER_NOT_EXIST if user.nil?
    return ErrCode::USER_NOT_VERIFIED if user.mobile_verified == false
    return ErrCode::WRONG_PASSWORD if Encryption.encrypt_password(password) != user.password
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end

  def verify_staff(name, center, password, verify_code)
    if mobile_verify_code != verify_code
      return ErrCode::WRONG_VERIFY_CODE
    end
    self.update_attributes(name: name, mobile_verified: true, center: center, password: Encryption.encrypt_password(password))
  end

  def forget_password
    if u.mobile_verified == false
      return ErrCode::USER_NOT_VERIFIED
    end

    # generate random code and save
    code = "111111"
    u.update_attribute(:password_verify_code, code)

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
    self.update_attributes(password: Encryption.encrypt_password(password), password_verify_code: "111111")
  end

end
