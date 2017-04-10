class Operator
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :company, type: String
  field :mobile, type: String
  field :password, type: String
  field :available, type: Boolean
  field :auth_key, type: String

  has_many :book_templates  

  def self.create_operator(operator_info)
    if Operator.where(mobile: operator_info[:mobile]).present?
      return ErrCode::OPERATOR_IS_EXIST
    end
    operator = Operator.create({
      name: operator_info[:name],
      company: operator_info[:company],
      mobile: operator_info[:mobile],
      password: Encryption.encrypt_password(operator_info[:password]),
      available: operator_info[:available]
      })
    {operator_id: operator.id.to_s}
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end

  def self.find_by_auth_key(auth_key)
    info = Encryption.decrypt_auth_key(auth_key)
    uid = info.split(',')[0]
    Operator.where(id: uid).first
  end

  def self.signin(mobile, password)
    user = Operator.where(mobile: mobile).first || User.where(user_type: User::ADMIN, mobile: mobile).first
    return ErrCode::USER_NOT_EXIST if !user.present?
    return ErrCode::WRONG_PASSWORD if user.password != Encryption.encrypt_password(password)
    return ErrCode::ACCOUNT_LOCKED if user.class == Operator && user.available == false
    auth_key = user.generate_auth_key
    user.update_attribute(:auth_key, auth_key)
    return { auth_key: auth_key }
  end

  def operator_info
    {
      id: self.id.to_s,
      mobile: self.mobile,
      name: self.name,
      company: self.company,
      password: Encryption.decrypt_password(self.password),
      count: self.book_templates.count,
      available: self.available
    }
  end

  def update_info(operator_info)
    operator = Operator.where(mobile: operator_info[:mobile]).first
    if !operator.present?
      return ErrCode::OPERATOR_NOT_EXIST
    end
    self.update_attributes(
      {
        name: operator_info[:name],
        company: operator_info[:company],
        mobile: operator_info[:mobile],
        password: Encryption.encrypt_password(operator_info[:password]) 
      }
    )
    nil
  end

  def change_password(old_password, new_password)
    return ErrCode::WRONG_PASSWORD if Encryption.encrypt_password(old_password.to_s) != self.password
    self.update_attributes(password: Encryption.encrypt_password(new_password.to_s))
    nil
  end
end