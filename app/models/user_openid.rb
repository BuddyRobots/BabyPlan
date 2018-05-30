class UserOpenid

  include Mongoid::Document
  include Mongoid::Timestamps

  field :openid, type: String
  field :user_id, type: String

end
