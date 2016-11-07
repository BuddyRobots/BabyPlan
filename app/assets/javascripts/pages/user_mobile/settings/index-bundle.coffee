$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $("#signin-course").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        alert(result)
        $.postJSON(
          '/user_mobile/courses/signin',
          {
            signin_info: result
          },
          (data) ->
            if data.success
              # redirect to the signin info page
              location.href = "/user_mobile/settings"
            else
              $.mobile_page_notification("服务器出错", 3000)
        )
