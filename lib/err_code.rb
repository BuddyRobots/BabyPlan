# encoding: utf-8
module ErrCode

  USER_NOT_EXIST = -1
  WRONG_PASSWORD = -2
  USER_EXIST = -3
  WRONG_VERIFY_CODE = -4
  USER_NOT_VERIFIED = -5

  def self.ret_false(code)
    msg = self.message(code)
    return nil if msg.nil?
    retval = { success: false }
    retval.merge({code: code, message: self.message(code)})
  end

  def self.message(code)
    case code
    when USER_NOT_EXIST
      "帐号不存在"
    when WRONG_PASSWORD
      "密码错误"
    when USER_EXIST
      "帐号已存在"
    when BLANK_EMAIL_MOBILE
      "帐号不能为空"
    when WRONG_VERIFY_CODE
      "验证码错误"
    when WRONG_TOKEN
      "token错误"
    when EXPIRED
      "token过期"
    when USER_NOT_VERIFIED
      "手机号未验证"
    when REQUIRE_SIGNIN
      "未登录"
    else
      nil
    end
  end
end
