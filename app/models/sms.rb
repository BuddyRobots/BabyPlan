# encoding: utf-8
require 'redis'
require 'httparty'
class Sms

  include HTTParty
  base_uri "https://sms.yunpian.com/v1/sms/"
  format  :json
  # https://sms.yunpian.com/v1/sms/send.json

  APIKEY = "254cea22c4a16dc39a7b91ae6a968ac1"
  SIGN = "【社区儿童中心】"

  def self.send(mobile, code)
    data = {
      "apikey" => Sms::APIKEY, 
      "mobile" => mobile, 
      "text" => "#{SIGN}您的验证码是#{code}"
    }
    response = Sms.post("/send.json",
      :body => data)
    return response.body
  end
end
