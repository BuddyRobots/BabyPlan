require 'httparty'
class CourseParticipate

  include HTTParty
  # pkcs12 File.read('public/cert/applient_cert.p12'), "1388434302"
  pkcs12 File.read('public/cert/apiclient_cert.p12'), Rails.configuration.wechat_mch_id
  base_uri "https://api.mch.weixin.qq.com"
  format  :xml

  # APPID = "wxfe4fd89f6f5f9f57"
  APPID = Rails.configuration.wechat_pay_app_id
  # SECRET = "01265a8ba50284999508d680f7387664"
  SECRET = Rails.configuration.wechat_pay_app_key
  # APIKEY = "1juOmajJrHO3f2NFA0a8dIYy2qAamtnK"
  APIKEY = Rails.configuration.wechat_pay_api_key
  MCH_ID = Rails.configuration.wechat_mch_id
  NOTIFY_URL = "http://#{Rails.configuration.domain}/user_mobile/courses/notify"

  include Mongoid::Document
  include Mongoid::Timestamps

  field :sign_in_time, type: String
  field :order_id, type: String
  field :price_pay, type: Float
  field :signin_info, type: Array, default: []

  field :prepay_id, type: String, default: ""
  field :wechat_transaction_id, type: String
  field :result_code, type: String
  field :err_code, type: String
  field :err_code_des, type: String
  field :trade_state_desc, type: String

  # refund related
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
  field :refund_finished, type: Boolean, default: false
  field :refund_status, type: String
  # it has occurred that the client has paid but the pay_finished is not updated as true.
  # the reason might be that there is something wrong with js (or browser), and the request of updating pay_finished is not received by the server
  # to fix this, we append a new field "renew_status", and use it as follow:
  # 1. when the client clicks "go to pay" on the user_mobile::course#show page, it links to the wechat to authorize
  #    and then redirect to user_mobile::course#new action, in which the unifiedorder_interface is called. in the
  #    new action we update the renew_status to true
  # 2. each time when we check whether need to order the wechat query, previously the condition is:
  #    'self.pay_finished == true && self.trade_state != "SUCCESS"', and we change it to:
  #    '(self.pay_finished == true && self.trade_state != "SUCCESS") || self.renew_status == true'.
  #    each time the order is queried, we update the renew_status to false (in the orderquery method)
  # the above process promises that each time the client go to the pay page, next time when the paying status is
  # needed, it is queried and updated from wechat
  field :renew_status, type: Boolean

  field :closed_at, type: Integer
  field :close_result, type: Boolean
  field :close_err_code, type: String

  belongs_to :course_inst
  belongs_to :school
  belongs_to :course
  belongs_to :center
  belongs_to :client, class_name: "User", inverse_of: :course_participates

  has_many :bills

  scope :paid, ->{ where(trade_state: "SUCCESS") }

  def status_str
    if self.need_order_query
      self.orderquery()
    end
    if is_expired
      return "已过期"
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
    # cp = self.create(order_id: Util.random_str(32),
    #                  price_pay: course_inst.price_pay)
    cp = self.create({
      course_inst_id: course_inst.id,
      school_id: course_inst.school_id,
      client_id: client.id,
      center_id: course_inst.center.id,
      prepay_id: ""
      })
    # cp.course_inst = course_inst
    # cp.client = client
    # cp.course = course_inst.course
    # cp.save
    # cp.update_attributes({expired_at: (Time.now + 10.minutes).to_i})
    # CourseOrderExpiredWorker.perform_in((600 + 10).seconds, cp.id.to_s)
    # cp
    # return cp.unifiedorder_interface(remote_ip, openid)
  end

  def create_order(remote_ip, openid)
    self.clear_refund
    self.update_attributes(
      {
        expired_at: (Time.now + 10.minutes).to_i,
        # order_id: Util.random_str(32),
        price_pay: course_inst.price_pay,
        renew_status: true,
        prepay_id: ""
      })
    order_id = Util.random_str(32)
    if self.price_pay == 0
      self.update_attributes({prepay_id: "free", order_id: order_id})
    else
      self.unifiedorder_interface(remote_ip, openid, order_id)
      CourseOrderExpiredWorker.perform_in(600.seconds, self.id.to_s)
    end
    
  end

  # def renew
  #   # if self.course_inst.price_pay > 0
  #   self.update_attributes(
  #     {
  #       expired_at: (Time.now + 10.minutes).to_i,
  #       order_id: Util.random_str(32),
  #       price_pay: self.course_inst.price_pay,
  #       prepay_id: self.course_inst.price_pay == 0 ? "free" : ""
  #     })
  #   if self.course_inst.price_pay > 0
  #     CourseOrderExpiredWorker.perform_in((600 + 10).seconds, self.id.to_s)
  #   end
  #   # end
  # end

  def self.notify_callback(content)
    doc = Nokogiri::XML(content)
    order_id = doc.search('out_trade_no').children[0].text


    bill = Bill.where(order_id: order_id).first
    if bill.blank?
      logger.info "ERROR!!!!!!!!!!!!!!"
      logger.info "order is finished, but corresponding bill cannot be found"
      logger.info "ERROR!!!!!!!!!!!!!!"
      return
    end

    cp = bill.course_participate
    if cp.nil?
      logger.info "ERROR!!!!!!!!!!!!!!"
      logger.info "order is finished, but corresponding course_participate cannot be found"
      logger.info "ERROR!!!!!!!!!!!!!!"
      return
    end
    success = doc.search('return_code').children[0].text
    logger.info "!!!!!!!!!!!!!!!!!!!"
    logger.info success
    if success != "SUCCESS"
      return nil
    else
      result_code = doc.search('result_code').children[0].text
      logger.info "!!!!!!!!!!!!!!!!!!!"
      logger.info result_code
      if result_code != "SUCCESS"
        err_code = doc.search('err_code').children[0].text
        err_code_des = doc.search('err_code_des').children[0].text
        cp.update_attributes({
          trade_state: result_code,
          err_code: err_code,
          err_code_des: err_code_des
        })
      else
        wechat_transaction_id = doc.search('transaction_id').children[0].try(:text)
        logger.info "!!!!!!!!!!!!!!!!!!!"
        logger.info wechat_transaction_id
        cp.update_attributes({
          trade_state: "SUCCESS",
          trade_state_desc: "",
          trade_state_updated_at: Time.now.to_i,
          wechat_transaction_id: wechat_transaction_id,
          pay_finished: true,
          expired_at: -1
        })
        # Bill.confirm_course_participate_item(cp)
        bill.confirm_course_participate_item
      end
    end
  end

  def orderquery
    self.update_attributes({renew_status: false})
    if self.order_id.blank? || self.prepay_id == "free"
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
        wechat_transaction_id = doc.search('transaction_id').children[0].try(:text)
        self.update_attributes({
          trade_state: trade_state,
          trade_state_updated_at: Time.now.to_i,
          trade_state_desc: trade_state_desc,
          wechat_transaction_id: wechat_transaction_id
        })
        if trade_state == "SUCCESS"
          self.update_attributes({pay_finished: true, expired_at: -1})
          bill = Bill.where(order_id: self.order_id).first
          bill.confirm_course_participate_item
        end
        retval = { success: true, trade_state: trade_state, trade_state_desc: trade_state_desc }
        return retval
      end
    end
  end

  def closeorder_interface
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "out_trade_no" => self.order_id
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature

    response = CourseParticipate.post("/pay/closeorder",
      body: Util.hash_to_xml(data))

    doc = Nokogiri::XML(response.body)
    success = doc.search('return_code').children[0].text
    if success != "SUCCESS"
      self.update_attributes({
        closed_at: Time.now.to_i,
        close_result: false
      })
    else
      result_code = doc.search('result_code').children[0].text
      if result_code == "SUCCESS"
        self.update_attributes({
          closed_at: Time.now.to_i,
          close_result: true
        })
      else
        err_code = doc.search('err_code').children[0].text
        self.update_attributes({
          closed_at: Time.now.to_i,
          close_result: false,
          close_err_code: err_code
        })
      end
    end
  end

  def unifiedorder_interface(remote_ip, openid, order_id)
    nonce_str = Util.random_str(32)
    data = {
      "appid" => APPID,
      "mch_id" => MCH_ID,
      "nonce_str" => nonce_str,
      "body" => self.course_inst.name,
      "out_trade_no" => order_id,
      "total_fee" => Rails.env == "production" ? (self.price_pay * 100).round.to_s : 1.to_s,
      "spbill_create_ip" => remote_ip,
      "notify_url" => NOTIFY_URL,
      "trade_type" => "JSAPI",
      "openid" => openid,
      "time_expire" => Time.at(self.expired_at).strftime("%Y%m%d%H%M%S")
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature


    response = CourseParticipate.post("/pay/unifiedorder",
      :body => Util.hash_to_xml(data))

    # todo: handle error messages

    doc = Nokogiri::XML(response.body)
    prepay_id = doc.search('prepay_id').children[0].text
    self.update_attributes({prepay_id: prepay_id, order_id: order_id})
    Bill.create_course_participate_item(self, prepay_id, order_id)
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

  def remain_time
    n = (self.expired_at - Time.now.to_i) / 60
    if n < 1
      remain_time = "订单即将过期，请尽快"
    else
      remain_time = "订单还有" + n.to_s + "分钟过期，请尽快"
    end
    remain_time + (self.price_pay == 0 ? "确认" : "支付")
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
  def need_order_query()
    return self.renew_status || (self.pay_finished == true && self.trade_state != "SUCCESS")
  end

  def is_effective
    if self.need_order_query
      self.orderquery()
    end
    self.trade_state == "SUCCESS" || (self.expired_at > Time.now.to_i && self.expired_at != -1)
  end

  def is_expired
    if self.expired_at == -1
      return false
    end
    if self.need_order_query
      self.orderquery()
    end
    self.trade_state != "SUCCESS" && self.trade_state != "USERPAYING" && self.expired_at < Time.now.to_i
  end

  def is_paying
    if self.price_pay == 0
      return false
    end
    # if self.pay_finished == true && self.trade_state != "SUCCESS"
    if self.need_order_query
      self.orderquery()
    end
    # self.pay_finished == true && self.trade_state != "SUCCESS"
    self.trade_state == "USERPAYING"
  end

  def is_success
    if self.price_pay == 0
      return self.pay_finished
    end
    if need_order_query
      self.orderquery()
    end
    self.trade_state == "SUCCESS"
  end

  def refund_allowed
    return self.is_success && Date.parse(self.course_inst.start_date).prev_day.at_beginning_of_day.future? && self.refund_finished == false
  end

  def review
    self.course_inst.reviews.where(client_id: self.client.id).first
  end

  def refund
    if !Date.parse(self.course_inst.start_date).prev_day.at_beginning_of_day.future?
      # refund now allowed
      return ErrCode::REFUND_TIME_FAIL
    end

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
      "total_fee" => Rails.env == "production" ? (self.price_pay * 100).round.to_s : 1.to_s,
      "refund_fee" => Rails.env == "production" ? (self.price_pay * 100).round.to_s : 1.to_s,
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
      if refund_result_code != "SUCCESS"
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
        self.clear_pay
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
      if refund_result_code != "SUCCESS"
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
        end
        return retval
      end
    end
  end

  def refund_status_str
    if self.refund_finished == true && !%w[SUCCESS, FAIL, CHANGE].include?(self.refund_status)
      self.refundquery
    end
    if self.refund_finished == false
      ""
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
    self.update_attributes({
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

  def course_participate_info
    {
      id: self.course_inst.id.to_s,
      name: self.course_inst.name || self.course.name,
      content: self.course_inst.desc,
      center: self.course_inst.center.name,
      photo: self.course_inst.photo,
      min_age: self.course_inst.min_age,
      max_age: self.course_inst.max_age,
      judge_price: self.course_inst.judge_price,
      date: self.course_inst.date,
      status_class: self.course_inst.status_class
    }
  end

  def more_info
    {
      ele_name: self.course_inst.name || self.course.name,
      ele_id: self.course_inst.id.to_s,
      ele_photo: self.course_inst.photo.nil? ? ActionController::Base.helpers.asset_path("web/course.png") : self.course_inst.photo.path,
      ele_content: ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.course_inst.desc).strip(), length: 50),
      ele_center: self.course_inst.center.name,
      ele_age: self.course_inst.min_age.present? ? self.course_inst.min_age.to_s + "~" + self.course_inst.max_age.to_s + "岁" : "无",
      ele_price: self.course_inst.judge_price,
      ele_date:  ActionController::Base.helpers.truncate(self.course_inst.date.strip(), length: 25),
      ele_status: self.course_inst.status_class
    }
  end

  def self.migrate
    CourseParticipate.all.each do |e|
      e.update_attribute(:center_id, e.course_inst.center.id)
    end
  end

  def self.migrate_school_id
    CourseParticipate.all.each do |e|
      if e.course_inst.school_id.present?
        e.school_id = e.course_inst.school_id
        e.save
      end
    end
  end

  def self.send_course_remind
    @cis = CourseInst.where(:start_course.gt => Time.now.end_of_day).where(:start_course.lt => Time.now.end_of_day + 1.day)
    ci_id = @cis.map {|c| c.id}
    ci_id.each do |c|
      ci = CourseInst.where(id: c).first
      course_name = ci.name
      openid = ci.course_participates.where(trade_state: "SUCCESS").map { |cp| cp.client.user_openid }
      openid.each do |u|
        user_name = User.where(user_openid: u).first.name_or_parent
        Weixin.course_start_notice(u, course_name, user_name)
      end
    end
  end

end
