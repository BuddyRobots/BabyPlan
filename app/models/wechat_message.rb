class WechatMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message_type, type: String
  field :content, type: String
  field :openid, type: String
  field :success, type: Boolean

end
