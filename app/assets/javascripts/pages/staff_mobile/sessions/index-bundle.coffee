$ ->
  sign_in = ->
    mobile = $("#mobile").val()
    password = $("#password").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.mobile_page_notification("帐号不存在", 3000)
      return
    $.postJSON(
      '/staff_mobile/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          location.href = "/staff_mobile/books"
        else
          if data.code == NO_CENTER 
            $.mobile_page_notification("请通知管理员开通账号", 3000)
          if data.code == ACCOUNT_LOCKED 
            $.mobile_page_notification("账号已被管理员锁定，无法登录", 3000)
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("帐号不存在", 3000)
          if data.code == USER_NOT_VERIFIED
            $.mobile_page_notification("手机号未验证", 3000)
          if data.code == WRONG_PASSWORD
            $.mobile_page_notification("密码错误", 3000)
      )

  $("#sign-in-btn").click ->
    sign_in()

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      sign_in()

