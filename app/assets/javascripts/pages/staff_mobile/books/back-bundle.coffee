$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $("#clicked").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        location.href="/staff_mobile/books/" + result + "/back"
