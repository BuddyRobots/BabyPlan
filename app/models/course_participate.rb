require 'httparty'
class CourseParticipate

  include HTTParty
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  APPID = "wxfe4fd89f6f5f9f57"
  APIKEY = "1juOmajJrHO3f2NFA0a8dIYy2qAamtnK"
  MCH_ID = "1388434302"
  NOTIFY_URL = "http://babyplan.bjfpa.org.cn/welcome/test_pay"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :pay_at, type: Integer
  field :sign_in_time, type: String
  field :paid, type: Boolean, default: false
  field :order_id, type: String

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :course_participates


  def self.create_new(client, course_inst, remote_ip)
    cp = self.create({order_id: Util.random_str(32)})
    cp.course_inst = course_inst
    cp.client = client
    cp.save
    cp.unifiedorder_interface(remote_ip)
  end

  def unifiedorder_interface(remote_ip)
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "body" => self.course_inst.course.name,
      "out_trade_no" => self.order_id,
      "total_fee" => self.course_inst.price_pay * 100,
      "spbill_create_ip" => remote_ip,
      "notify_url" => NOTIFY_URL,
      "trade_type" => "JSAPI",
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature

    response = Weixin.post("/pay/unifiedorder",
      :body => data.to_xml)
    logger.info "AAAAAAAAAAAAAAAA"
    logger.info response.body
    logger.info "AAAAAAAAAAAAAAAA"
    return response.body
  end
end