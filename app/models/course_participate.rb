require 'httparty'
class CourseParticipate

  include HTTParty
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  APPID = "wxfe4fd89f6f5f9f57"
  MCH_ID = "1388434302"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :pay_at, type: Integer
  field :sign_in_time, type: String
  field :paid, type: Boolean, default: false
  field :order_id, type: String

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :course_participates


  def self.create_new(client, course_inst)
    cp = self.create({order_id: Util.random_str(32)})
    cp.course_inst = course_inst
    cp.client = client
    cp.save
    cp.unifiedorder_interface
  end

  def unifiedorder_interface
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "sign" => "",
      "body" => self.course.name,
      "out_trade_no" => self.order_id,
      "total_fee" => self.course_inst.price_pay * 100,
      "spbill_create_ip" => 
    }

    response = Weixin.post("/pay/unifiedorder",
      :body => data.to_xml)
    return response.body
  end
end