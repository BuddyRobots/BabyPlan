class Operator
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :company, type: String
  field :mobile, type: String
  field :password, type: String
  field :available, type: Boolean

  has_many :books  

  def self.create_operator(operator_info)
    if Operator.where(mobile: operator_info[:mobile]).present?
      return ErrCode::OPERATOR_IS_EXIST
    end
    operator = Operator.create({
      name: operator_info[:name],
      company: operator_info[:company],
      mobile: operator_info[:mobile],
      password: operator_info[:password],
      available: operator_info[:available]
      })
    {operator_id: operator.id.to_s}
  end

  def operator_info
    {
      id: self.id.to_s,
      mobile: self.mobile,
      name: self.name,
      company: self.company,
      password: self.password,
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
        password: operator_info[:password]
      }
    )
    nil
  end
end