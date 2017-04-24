class RedPacket
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Integer
  field :mch_billno, type: String
  field :send_listid, type: String
  field :result_code, type: String
  field :status, type: String, default: "SENDING"

  belongs_to :deposit
end