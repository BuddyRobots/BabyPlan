class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :unread, type: Boolean, default: true
  field :content, type: String

  belongs_to :client

end