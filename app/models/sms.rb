# encoding: utf-8
require 'redis'
require 'httparty'
class Sms

  include HTTParty
  base_uri "https://sms.yunpian.com/v2/sms/"
  format  :json
  # https://sms.yunpian.com/v1/sms/send.json

  APIKEY = "254cea22c4a16dc39a7b91ae6a968ac1"
  SIGN = "【少儿创客】"

  def self.send(mobile, code)
    data = {
      "apikey" => Sms::APIKEY, 
      "mobile" => mobile, 
      "text" => "#{SIGN}您的验证码是#{code}"
    }
    response = Sms.post("/single_send.json",
      :body => data)
    return response.body
  end
end
