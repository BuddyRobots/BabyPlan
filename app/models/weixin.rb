# encoding: utf-8
require 'redis'
require 'httparty'
class Weixin

  include HTTParty
  pkcs12 File.read('public/cert/apiclient_cert.p12'), "1445887202"
  base_uri "https://api.weixin.qq.com"
  format  :json


  APPID = "wx0bad9193f1246547"
  SECRET = "68b29adfa28e31c6107d7a627373e74f"
  MCH_ID = "1445887202"
  APIKEY = "bBdnzYarb9DQntl42QWxtC502K6r4l1G"


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

  def self.get_oauth_open_id(code)
    url = "/sns/oauth2/access_token?appid=#{CourseParticipate::APPID}&secret=#{CourseParticipate::SECRET}&code=#{code}&grant_type=authorization_code"
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

  def self.send_kaike_msg(cp)
    user = cp.client.name,
    desc = cp.course_inst.name + ",上课地址为:" + cp.course_inst.address + ",",
    date = cp.course_inst.start_date
    body = {
      "touser": cp.client.user_openid,
      "template_id": "OCNHKZfEjK0FTayFeGZTfWTzeElKtqNQ7m09HuebKk4",
      "data": {
        "userName": {
          "value": user,
          "color": "#173177"
        },
        "courseName": {
          "value": desc,
          "color": "#173177"
        },
        "date": {
          "value": date,
          "color": "#173177"
        }
      }
    }
    
    url = "/cgi-bin/message/template/send?access_token=#{Weixin.get_access_token}"
    response = Weixin.post(url, :body => body.to_json)
    if response.body["errcode"] == 0
      return true
    else
      return false
    end   
  end

  def self.red_packet(user, total_amount, wishing)
    openid = user.user_openid
    nonce_str = Util.random_str(32)
    mch_billno = Util.billno_random_str
    data = {
      "nonce_str" => nonce_str,
      "mch_billno" => mch_billno,
      "mch_id" => MCH_ID,
      "wxappid" => APPID,
      "send_name" => "少儿创客",
      "re_openid" => openid,
      "total_amount" => total_amount,
      "total_num" => 1.to_i,
      "wishing" => wishing,
      "client_ip" => "101.200.35.126",
      "act_name" => "退还押金",
      "remark" => "少儿创客退款"
    }
    signature = Util.sign(data, APIKEY)
    data["sign"] = signature
    self.base_uri "https://api.mch.weixin.qq.com"
    self.format :xml
    url = "/mmpaymkttransfers/sendredpack"
    response = Weixin.post(url, :body => Util.hash_to_xml(data))
    self.base_uri "https://api.weixin.qq.com"
    self.format :json

    doc = Nokogiri::XML(response.body)
    success = doc.search('result_code').children[0].text
    if success == "SUCCESS"
      return 1
    else
      errcode = doc.search('err_code').children[0].text
      return errcode
    end
  end

end
