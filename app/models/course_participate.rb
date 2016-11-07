require 'httparty'
class CourseParticipate

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

  field :pay_at, type: Integer
  field :sign_in_time, type: String
  field :order_id, type: String
  field :price
  field :signin_info, type: Array, default: []

  field :prepay_id, type: String
  # whether pay process is finished. pay attention that this does not indicate that pay is success
  field :pay_finished, type: Boolean, default: false
  field :wechat_transaction_id, type: String
  field :result_code, type: String
  field :err_code, type: String
  field :err_code_des, type: String
  field :trade_state, type: String
  field :trade_state_desc, type: String
  field :expired_at, type: Integer

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :course_participates


  def self.create_new(client, course_inst)
    cp = self.create({order_id: Util.random_str(32)})
    cp.course_inst = course_inst
    cp.client = client
    cp.save
    expired_at = Time.now + 1.days
    cp.update_attributes({expired_at: expired_at.to_i})
    cp
    # return cp.unifiedorder_interface(remote_ip, openid)
  end

  def renew
    self.update_attributes(
      {
        expired_at: (Time.now + 1.days).to_i,
        order_id: Util.random_str(32),
        prepay_id: ""
      })
  end

  def orderquery()
    if self.order_id.blank?
      return nil
    end
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "out_trade_no" => self.order_id,
      "nonce_str" => nonce_str,
      "sign_type" => "MD5"
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature
    response = CourseParticipate.post("/pay/orderquery",
      :body => Util.hash_to_xml(data))

    doc = Nokogiri::XML(response.body)
    success = doc.search('return_code').children[0].text
    if success != "SUCCESS"
      return nil
    else
      result_code = doc.search('result_code').children[0].text
      self.update_attributes({result_code: result_code})
      if result_code != "SUCCESS"
        err_code = doc.search('err_code').children[0].text
        err_code_des = doc.search('err_code_des').children[0].text
        self.update_attributes({
          err_code: err_code,
          err_code_des: err_code_des
        })
        retval = { success: false, err_code: err_code, err_code_des: err_code_des }
        return retval
      else
        trade_state = doc.search('trade_state').children[0].text
        trade_state_desc = doc.search('trade_state').children[0].text
        wechat_transaction_id = doc.search('transaction_id').children[0].text
        self.update_attributes({
          trade_state: trade_state,
          trade_state_desc: trade_state_desc,
          wechat_transaction_id: wechat_transaction_id
        })
        retval = { success: true, trade_state: trade_state, trade_state_desc: trade_state_desc }
        return retval
      end
    end
  end

  def unifiedorder_interface(remote_ip, openid)
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "body" => self.course_inst.course.name,
      "out_trade_no" => self.order_id,
      # "total_fee" => (self.course_inst.price_pay * 100).to_s,
      "total_fee" => (self.course_inst.price_pay).to_s,
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
    # retval = {
    #   "appId" => APPID,
    #   "timeStamp" => Time.now.to_i.to_s,
    #   "nonceStr" => Util.random_str(32),
    #   "package" => "prepay_id=" + prepay_id,
    #   "signType" => "MD5"
    # }
    # signature = Util.sign(retval, APIKEY)
    # retval["sign"] = signature
    # return retval
  end

  def get_pay_info
    retval = {
      "appId" => APPID,
      "timeStamp" => Time.now.to_i.to_s,
      "nonceStr" => Util.random_str(32),
      "package" => "prepay_id=" + self.prepay_id,
      "signType" => "MD5"
    }
    signature = Util.sign(retval, APIKEY)
    retval["sign"] = signature
    return retval
  end

  def update_order_status(result_code, err_code, err_code_des)
    self.update_attributes({
      result_code: result_code,
      err_code: err_code,
      err_code_des: err_code_des
    })
  end

  def signin(class_num)
    if self.signin_info[class_num].blank?
      self.signin_info[class_num] = Time.now.to_i
    nil
  end

  # status related
  def is_expired
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.trade_state != "SUCCESS" && self.expired_at < Time.now.to_i
  end

  def is_paying
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.pay_finished == true && self.trade_state != "SUCCESS"
  end

  def is_success
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.trade_state == "SUCCESS"
  end
end