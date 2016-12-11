require 'httparty'
class CourseParticipate

  include HTTParty
  # pkcs12 File.read('public/cert/applient_cert.p12'), "1388434302"
  pkcs12 File.read('public/cert/apiclient_cert.p12'), "1388434302"
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  APPID = "wxfe4fd89f6f5f9f57"
  SECRET = "01265a8ba50284999508d680f7387664"
  APIKEY = "1juOmajJrHO3f2NFA0a8dIYy2qAamtnK"
  MCH_ID = "1388434302"
  NOTIFY_URL = "http://babyplan.bjfpa.org.cn/user_mobile/courses/notify"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :sign_in_time, type: String
  field :order_id, type: String
  field :price_pay, type: Float
  field :signin_info, type: Array, default: []

  field :prepay_id, type: String
  field :wechat_transaction_id, type: String
  field :result_code, type: String
  field :err_code, type: String
  field :err_code_des, type: String
  field :trade_state_desc, type: String

  # refund related
  field :refund_feedback, type: String, default: ""
  field :refund_result_code, type: String
  field :refund_err_code, type: String
  field :refund_err_code_des, type: String
  field :wechat_refund_id, type: String
  field :wechat_refund_channel, type: String
  field :wechat_refund_fee, type: Integer

  # status related attributes
  # course participate can have following status:
  # 1. not signed up: course participate not created
  # 2. signed up but not paied: course participate created, pay_finished is false
  # 3. paying: pay_finished is true, but trade_state is not "SUCCESS"
  # 4. paid: trade_state is "SUCCESS"
  # whether pay process is finished. pay attention that this does not indicate that pay is success
  field :pay_finished, type: Boolean, default: false
  field :trade_state, type: String
  field :trade_state_updated_at, type: Integer
  field :expired_at, type: Integer, default: -1
  field :refund_requested, type: Boolean, default: false
  field :refund_request_handled, type: Boolean, default: false
  field :refund_approved, type: Boolean, default: false
  field :refund_finished, type: Boolean, default: false
  field :refund_status, type: String

  belongs_to :course_inst
  belongs_to :course
  belongs_to :client, class_name: "User", inverse_of: :course_participates

  scope :paid, ->{ where(trade_state: "SUCCESS") }

  def status_str
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    if pay_finished != true
      return "未付款"
    end
    if trade_state == "SUCCESS"
      return "已付款"
    end
    if pay_finished == true && trade_state != "SUCCESS"
      return "付款中"
    end
    return ""
  end

  def self.create_new(client, course_inst)
    cp = self.create(order_id: Util.random_str(32),
                     price_pay: course_inst.price_pay)
    cp.course_inst = course_inst
    cp.client = client
    cp.course = course_inst.course
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

  def orderquery
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
          trade_state_updated_at: Time.now.to_i,
          trade_state_desc: trade_state_desc,
          wechat_transaction_id: wechat_transaction_id
        })
        if trade_state == "SUCCESS"
          Bill.create_course_participate_item(self)
        end
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
      "total_fee" => (self.price_pay * 100).round.to_s,
      # "total_fee" => 1.to_s,
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
    if self.is_success == false
      return ErrCode::NOT_PAID
    end
    class_num = class_num.to_i
    if self.signin_info[class_num].blank?
      self.signin_info[class_num] = Time.now.to_i
      self.save
    end
    # the class_num returned is used to show info in the page, thus convert to 1-based
    { class_num: (class_num + 1).to_s, course_id: self.course_inst.id.to_s }
  end

  # status related
  def is_expired
    if self.price_pay == 0
      return false
    end
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.trade_state != "SUCCESS" && self.expired_at < Time.now.to_i
  end

  def is_paying
    if self.price_pay == 0
      return false
    end
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.pay_finished == true && self.trade_state != "SUCCESS"
  end

  def is_success
    if self.price_pay == 0
      return self.pay_finished
    end
    if self.pay_finished == true && self.trade_state != "SUCCESS"
      self.orderquery()
    end
    self.trade_state == "SUCCESS"
  end

  def refund_allowed
    return self.is_success && self.course_inst.status == CourseInst::NOT_BEGIN && self.refund_requested == false
  end

  def request_refund
    if self.refund_allowed
      self.update_attributes({refund_requested: true})
      nil
    elsif self.refund_requested == true
      ErrCode::REFUND_REQUESTED
    else
      ErrCode::REFUND_NOT_ALLOWED
    end
  end

  def review
    self.course_inst.reviews.where(client_id: self.client.id).first
  end

  def self.waiting_for_refund(center)
    course_insts = center.course_insts
    CourseParticipate.any_in(course_inst_id: course_insts.map { |e| e.id.to_s}).where(refund_requested: true, refund_request_handled: false).first
  end

  def reject_refund(feedback)
    self.update_attributes({
      refund_request_handled: true,
      refund_approved: false,
      refund_feedback: feedback
    })
    nil
  end

  def approve_refund(feedback)
    self.refund
    self.update_attributes({
      refund_request_handled: true,
      refund_approved: true,
      refund_feedback: feedback
    })
    nil
  end

  def refund
    if self.price_pay == 0
      self.update_attributes({
        refund_status: "SUCCESS",
        refund_finished: true
      })
      self.clear_pay
      return { success: true }
    end
    if self.order_id.blank?
      return nil
    end
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "op_user_id" => MCH_ID,
      "out_trade_no" => self.order_id,
      "out_refund_no" => self.order_id,
      "total_fee" => (self.price_pay * 100).round.to_s,
      # "total_fee" => 1.to_s,
      "refund_fee" => 1.to_s,
      "nonce_str" => nonce_str,
      "sign_type" => "MD5"
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature
    response = CourseParticipate.post("/secapi/pay/refund",
      :body => Util.hash_to_xml(data))

    doc = Nokogiri::XML(response.body)
    success = doc.search('return_code').children[0].text
    if success != "SUCCESS"
      return nil
    else
      refund_result_code = doc.search('result_code').children[0].text
      self.update_attributes({refund_result_code: refund_result_code})
      if result_code != "SUCCESS"
        err_code = doc.search('err_code').children[0].text
        err_code_des = doc.search('err_code_des').children[0].text
        self.update_attributes({
          refund_err_code: err_code,
          refund_err_code_des: err_code_des
        })
        retval = { success: false, err_code: err_code, err_code_des: err_code_des }
        return retval
      else
        wechat_refund_id = doc.search('refund_id').children[0].text
        wechat_refund_channel = doc.search('refund_channel').children[0].text
        wechat_refund_fee = doc.search('refund_fee').children[0].text
        self.update_attributes({
          wechat_refund_id: wechat_refund_id,
          wechat_refund_channel: wechat_refund_channel,
          wechat_refund_fee: wechat_refund_fee,
          refund_finished: true
        })
        Bill.create_course_refund_item(self)
        retval = { success: true, wechat_refund_id: wechat_refund_id, wechat_refund_channel: wechat_refund_channel }
        return retval
      end
    end
  end

  def refundquery
    if self.refund_finished != true || self.price_pay == 0
      return
    end
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "op_user_id" => MCH_ID,
      "out_trade_no" => self.order_id,
      "nonce_str" => nonce_str,
      "sign_type" => "MD5"
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature
    response = CourseParticipate.post("/pay/refundquery",
      :body => Util.hash_to_xml(data))

    print(response.body)
    doc = Nokogiri::XML(response.body)
    success = doc.search('return_code').children[0].text
    if success != "SUCCESS"
      return
    else
      refund_result_code = doc.search('result_code').children[0].text
      self.update_attributes({refund_result_code: refund_result_code})
      if result_code != "SUCCESS"
        err_code = doc.search('err_code').children[0].text
        err_code_des = doc.search('err_code_des').children[0].text
        self.update_attributes({
          refund_err_code: err_code,
          refund_err_code_des: err_code_des
        })
        retval = { success: false, err_code: err_code, err_code_des: err_code_des }
        return retval
      else
        refund_status = doc.search('refund_status_0').children[0].text
        self.update_attributes({ refund_status: refund_status })
        retval = { success: true, refund_status: refund_status }
        if refund_status == "SUCCESS"
          Bill.confirm_course_refund_item(self)
          self.clear_pay
        end
        return retval
      end
    end
  end

  def refund_status_str
    if self.refund_finished == true && !%w[SUCCESS, FAIL, CHANGE].include?(self.refund_status)
      self.refundquery
    end
    if self.refund_requested == false
      ""
    elsif self.refund_request_handled == false
      "已申请退款"
    elsif self.refund_approved == false
      "退款申请被拒绝"
    elsif self.refund_finished == false
      "退款失败"
    elsif self.refund_status == "PROCESSING"
      "退款处理中"
    elsif self.refund_status == 'FAIL' || self.refund_status == 'CHANGE'
      "退款失败"
    elsif self.refund_status == 'SUCCESS'
      "退款已完成"
    else
      ""
    end
  end

  def clear_refund
    return if self.refund_requested = false
    self.update_attributes({
      refund_requested: false,
      refund_request_handled: false,
      refund_approved: false,
      refund_finished: false,
      refund_status: ""
    })
  end

  def clear_pay
    self.update_attributes({
      order_id: "",
      prepay_id: "",
      wechat_transaction_id: "",
      result_code: "",
      err_code: "",
      err_code_des: "",
      trade_state_desc: "",
      pay_finished: false,
      trade_state: "",
      trade_state_updated_at: nil,
      expired_at: -1
    })
  end
end