# encoding: utf-8
require 'redis'
require 'httparty'
class Weixin

  include HTTParty
  pkcs12 File.read('public/cert/apiclient_cert.p12'), Rails.configuration.wechat_mch_id
  base_uri "https://api.weixin.qq.com"
  format  :json

  # APPID = "wx69353371388b899b"
  APPID = Rails.configuration.wechat_app_id
  PAY_APPID = Rails.configuration.wechat_pay_app_id
  PAY_APIKEY = Rails.configuration.wechat_pay_api_key
  # SECRET = "ac87a676aed464f1069f1b71e158ef68"
  SECRET = Rails.configuration.wechat_app_key
  MCH_ID = Rails.configuration.wechat_mch_id

  def self.get_access_token
    @@redis ||= Redis.new
    expires_at = @@redis.get("weixin_access_token_expires_at").to_i
    if expires_at > Time.now.to_i
      @@redis.get("weixin_access_token")
    else
      self.refresh_access_token
    end
  end

  def self.refresh_access_token
    @@redis ||= Redis.new
    url = "/cgi-bin/token?grant_type=client_credential&appid=#{APPID}&secret=#{SECRET}"
    response = Weixin.get(url)
    if response["errcode"].blank?
      @@redis.set("weixin_access_token", response["access_token"])
      @@redis.set("weixin_access_token_expires_at", Time.now.to_i + response["expires_in"] - 100)
    end
    response["access_token"]
  end

  def self.get_jsapi_ticket
    @@redis ||= Redis.new
    expires_at = @@redis.get("weixin_jsapi_ticket_expires_at").to_i
    if expires_at > Time.now.to_i
      @@redis.get("weixin_jsapi_ticket")
    else
      self.refresh_jsapi_ticket
    end
  end

  def self.refresh_jsapi_ticket
    @@redis ||= Redis.new
    url = "/cgi-bin/ticket/getticket?access_token=#{self.get_access_token}&type=jsapi"
    response = Weixin.get(url)
    if response["errcode"].blank? || response["errcode"].to_s == "0"
      @@redis.set("weixin_jsapi_ticket", response["ticket"])
      @@redis.set("weixin_jsapi_ticket_expires_at", Time.now.to_i + response["expires_in"] - 100)
    end
    response["ticket"]
  end

  def self.generate_authorize_link(callback_url, with_info = false)
    scope = with_info ? "snsapi_userinfo" : "snsapi_base"
    encode_url = CGI.escape(callback_url)
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{APPID}&redirect_uri=#{encode_url}&response_type=code&scope=#{scope}#wechat_redirect"
    url
  end

  def self.get_oauth_open_id(code, pay=true)
    if pay == true
      url = "/sns/oauth2/access_token?appid=#{CourseParticipate::APPID}&secret=#{CourseParticipate::SECRET}&code=#{code}&grant_type=authorization_code"
    else
      url = "/sns/oauth2/access_token?appid=#{APPID}&secret=#{SECRET}&code=#{code}&grant_type=authorization_code"
    end
    response = Weixin.get(url)
    response["openid"]
  end

  def self.get_oauth_open_id_and_user_info(code)
    url = "/sns/oauth2/access_token?appid=#{APPID}&secret=#{SECRET}&code=#{code}&grant_type=authorization_code"
    response = Weixin.get(url)
    open_id = response["openid"]

    url = "/sns/userinfo?access_token=#{response["access_token"]}&openid=#{response["openid"]}&lang=zh_CN"
    response = Weixin.get(url)
    {
      open_id: open_id,
      nickname: response["nickname"]
    }
  end

  def self.update_menu
    data = {
      "button" => [
        {
          "name": "服务",
          "sub_button": [
            {
              "type": "view", 
              "name": "课程", 
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/courses"
            },
            {
              "type": "view", 
              "name": "绘本", 
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/books"
            }
          ]
        },
        {
          "type": "view", 
          "name": "公告", 
          "url": "http://babyplan.bjfpa.org.cn/user_mobile/announcements"
        },
        {
         "name": "我",
         "sub_button": [
            {  
              "type": "view",
              "name": "收藏",
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/settings/favorite"
            },
            {
              "type": "view",
              "name": "课程",
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/settings/course"
            },
            {
              "type": "view",
              "name": "绘本",
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/settings/book"
            },
            {
              "type": "scancode_push",
              "name": "签到",
              "key": "signin_key"
            },
            {
              "type": "view",
              "name": "中心设置",
              "url": "http://babyplan.bjfpa.org.cn/user_mobile/centers/new"
            }
          ]
        }
      ]
    }

    response = Weixin.post("/cgi-bin/menu/create?access_token=#{self.get_access_token}",
      :body => data.to_json)
    return response.body
  end

  def self.course_notice(cp, content, course_name)
    body = {
      "touser": cp,
      "template_id": "XaIM2TKa7w78F8J2qB2bTtcVf_PlDq2F_wao3dznJTE",
      "data": {
        "first": {
          "value": "尊敬的用户您好，您报名参加的课程有变动!",
          "color": "#173177"
        },
        "keyword1": {
          "value": course_name,
          "color": "#173177"
        },
        "keyword2": {
          "value": content,
          "color": "#173177"
        },
        "remark": {
          "value": "北京市社区儿童中心祝您上课愉快!",
          "color": "#173177"
        }
      }
    }
    
    url = "/cgi-bin/message/template/send?access_token=#{Weixin.get_access_token}"
    response = Weixin.post(url, :body => body.to_json)
    retval = JSON.parse(response.body)
    if retval["errcode"] == 0
      return true
    else
      return false
    end   
  end

  def self.course_start_notice(openid, course_name, user_name)
    body = {
      "touser": openid,
      "template_id": "nP01oidKj_p4cLFGuZws3yPWVAIt7IXi0P_tGPn45VU",
      "data": {
        "first": {
          "value": "尊敬的用户您好，您报名参加的课程将于明天开始上课!",
          "color": "#173177"
        },
        "keyword1": {
          "value": course_name,
          "color": "#173177"
        },
        "keyword2": {
          "value": user_name,
          "color": "#173177"
        },
        "remark": {
          "value": "若无法参加课程请及时联系中心客服!",
          "color": "#173177"
        }
      }
    }
    
    url = "/cgi-bin/message/template/send?access_token=#{Weixin.get_access_token}"
    response = Weixin.post(url, :body => body.to_json)
    retval = JSON.parse(response.body)
    if retval["errcode"] == 0
      return true
    else
      return false
    end   
  end

  def self.book_return_notice(openid, book_name, return_time)
    body = {
      "touser": openid,
      "template_id": "2S4VVtCGxJsVpEeqJsmBBLOTjgBMiQFhX8k49jxZuSg",
      "data": {
        "first": {
          "value": "尊敬的用户您好，您借阅的书籍!",
          "color": "#173177"
        },
        "keyword1": {
          "value": book_name,
          "color": "#173177"
        },
        "keyword2": {
          "value": return_time,
          "color": "#173177"
        },
        "remark": {
          "value": "请及时归还，超时将会产生滞纳金！",
          "color": "#173177"
        }
      }
    }
    
    url = "/cgi-bin/message/template/send?access_token=#{Weixin.get_access_token}"
    response = Weixin.post(url, :body => body.to_json)
    retval = JSON.parse(response.body)
    if retval["errcode"] == 0
      return true
    else
      return false
    end   
  end

  def self.red_packet(user_id, total_amount, wishing, open_id)
    user = User.find(user_id)
    # openid = user.user_openid
    nonce_str = Util.random_str(32)
    mch_billno = Util.billno_random_str
    data = {
      "nonce_str" => nonce_str,
      "mch_billno" => mch_billno,
      "mch_id" => MCH_ID,
      "wxappid" => PAY_APPID,
      "send_name" => "绘本押金退款",
      "re_openid" => open_id,
      "total_amount" => total_amount.to_i * 100,
      "total_num" => 1.to_i,
      "wishing" => wishing,
      "client_ip" => "101.200.35.126",
      "act_name" => "退还押金",
      "remark" => "儿童中心退款"
    }
    signature = Util.sign(data, PAY_APIKEY)
    data["sign"] = signature
    self.base_uri "https://api.mch.weixin.qq.com"
    self.format :xml
    url = "/mmpaymkttransfers/sendredpack"
    response = Weixin.post(url, :body => Util.hash_to_xml(data))
    Rails.logger.info "^^^^^^^^^^^^^^^^^^"
    Rails.logger.info response.inspect
    Rails.logger.info "^^^^^^^^^^^^^^^^^^"
    self.base_uri "https://api.weixin.qq.com"
    self.format :json

    doc = Nokogiri::XML(response.body)
    success = doc.search('result_code').children[0].text
    send_listid = doc.search('send_listid').children[0].text
    user.deposit.red_packets.create({amount: total_amount, mch_billno: mch_billno, send_listid: send_listid, status: status, result_code: success})

    if success == "SUCCESS"
      return "ok"
    else
      errcode = doc.search('err_code').children[0].text
      return errcode
    end
  end

  def self.query_redpacket_status(red_packet)
    mch_billno = red_packet.mch_billno
    nonce_str = Util.random_str(32)
    data = {
      "nonce_str" => nonce_str,
      "mch_billno" => mch_billno,
      "mch_id" => MCH_ID,
      "appid" => PAY_APPID,
      "billtype" => "MCHT"
    }
    signature = Util.sign(data, PAY_APIKEY)
    data["sign"] = signature
    self.base_uri "https://api.mch.weixin.qq.com"
    self.format :xml
    url = "/mmpaymkttransfers/gethbinfo"
    response = Weixin.post(url, :body => Util.hash_to_xml(data))
    self.base_uri "https://api.weixin.qq.com"
    self.format :json
    doc = Nokogiri::XML(response.body)
    return_code = doc.search('return_code').children[0].text
    if return_code == "SUCCESS"
      result_code = doc.search('result_code').children[0].text
      if result_code == "SUCCESS"
        status = doc.search('status').children[0].text
        red_packet.update_attribute(:status, status)
        return "ok"
      else
        errcode = doc.search('err_code').children[0].text
        return errcode
      end
    end
  end

end
