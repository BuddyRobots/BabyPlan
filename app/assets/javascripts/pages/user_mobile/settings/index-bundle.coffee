$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  sign_in = ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        $.postJSON(
          '/user_mobile/courses/signin',
          {
            signin_info: result
          },
          (data) ->
            if data.success
              # redirect to the signin info page
              location.href = "/user_mobile/settings/sign?success=true&course_id=" + data.course_id + "&class_num=" + data.class_num
            else
              if data.code == COURSE_INST_NOT_EXIST
                location.href = "/user_mobile/settings/sign?err=course_inst_not_exist&success=false"
              else if data.code == NOT_PAID
                location.href = "/user_mobile/settings/sign?err=not_paid&success=false"
              else
                $.mobile_page_notification("服务器出错", 3000)
        )

  $("#signin-course").click ->
    sign_in()

  if window.signin == "true"
    setTimeout (->
      sign_in()
      return
    ), 1000
    # sign_in()
