$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  sign_in = ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        window.location.href = result

  $("#signin-course").click ->
    sign_in()

  if window.signin == "true"
    setTimeout (->
      sign_in()
      return
    ), 1000
    # sign_in()
