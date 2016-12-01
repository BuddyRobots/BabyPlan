require 'httparty'
class Deposit

  include HTTParty
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  APPID = "wxfe4fd89f6f5f9f57"
  SECRET = "01265a8ba50284999508d680f7387664"
  APIKEY = "1juOmajJrHO3f2NFA0a8dIYy2qAamtnK"
  MCH_ID = "1388434302"
  NOTIFY_URL = "http://babyplan.bjfpa.org.cn/user_mobile/courses/notify"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Integer, default: 100

  field :order_id, type: String

  field :prepay_id, type: String
  field :wechat_transaction_id, type: String
  field :result_code, type: String
  field :err_code, type: String
  field :err_code_des, type: String
  field :trade_state_desc, type: String

  # status related attributes
  # deposit can have following status:
  # 1. not paid: course participate not created, or deposit created but pay_finished is false
  # 3. paying: pay_finished is true, but trade_state is not "SUCCESS"
  # 4. paid: trade_state is "SUCCESS"
  # whether pay process is finished. pay attention that this does not indicate that pay is success
  field :pay_finished, type: Boolean, default: false
  field :trade_state, type: String
  field :trade_state_updated_at, type: Integer
  field :expired_at, type: Integer, default: -1
  field :refunded, type: Boolean, default: false

  belongs_to :user

  def self.create_new(client)
    deposit_amount = BorrowSetting.first.try(:deposit) || 100
    deposit = self.create(order_id: Util.random_str(32),
                          amount: deposit_amount)
    deposit.client = client
    deposit.save
    expired_at = Time.now + 1.days
    deposit.update_attributes({expired_at: expired_at.to_i})
    deposit
    # return cp.unifiedorder_interface(remote_ip, openid)
  end

  def paid
    return false if self.deposit.trade_state != "SUCCESS"
    return false if self.deposit.trade_state == "SUCCESS" && self.refunded == true
    return true
  end

  def unifiedorder_interface(remote_ip, openid)
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "body" => self.course_inst.course.name,
      "out_trade_no" => self.order_id,
      # "total_fee" => (self.amount * 100).to_s,
      "total_fee" => 1.to_s,
      "spbill_create_ip" => remote_ip,
      "notify_url" => NOTIFY_URL,
      "trade_type" => "JSAPI",
      "openid" => openid,
      "time_expire" => Time.at(self.expired_at + 600).strftime("%Y%m%d%H%M%S")
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature

    response = CourseParticipate.post("/pay/unifiedorder",
      :body => Util.hash_to_xml(data))

    # todo: handle error messages

    doc = Nokogiri::XML(response.body)
    prepay_id = doc.search('prepay_id').children[0].text
    self.update_attributes({prepay_id: prepay_id})
  end

  def renew
    self.update_attributes(
      {
        expired_at: (Time.now + 1.days).to_i,
        order_id: Util.random_str(32),
        prepay_id: ""
      })
  end
end