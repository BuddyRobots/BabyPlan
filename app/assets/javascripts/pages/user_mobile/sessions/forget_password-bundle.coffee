$ ->

  uid = ""
  timer = null
  wait = 60

  time = (o) ->
    $(o).attr("disabled", true)
    if wait == 0
      $(o).attr("disabled", false)
      $(o).text('验证码')
      wait = 60
    else
      $(o).text('重发(' + wait + ')')
      wait--
      timer = setTimeout (->
        time o
        return
      ), 1000
    return

  $(".identifycode").click ->
    mobile = $("#mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.mobile_page_notification("请输入正确的手机号", 3000)
      return false
    $.postJSON(
      '/user_mobile/sessions/forget_password_submit_mobile',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time(".identifycode")
        else
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("用户不存在", 3000)
    )

  $(".next").click ->
    if uid == ""
      $.mobile_page_notification("验证码不正确", 3000)
      return
    code = $("#code").val()
    $.postJSON(
      '/user_mobile/sessions/forget_password_submit_code',
      {
        uid: uid
        code: code
      },
      (data) ->
        console.log data
        if data.success
          location.href = "/user_mobile/sessions/set_password?uid=" + uid
        else
          if data.code == WRONG_VERIFY_CODE
            $.mobile_page_notification("验证码不正确", 3000)
    )
