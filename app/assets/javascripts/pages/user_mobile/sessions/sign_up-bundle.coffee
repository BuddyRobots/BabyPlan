$ ->
  uid = ""
  $(".identifycode").click ->
    mobile = $("#mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.mobile_page_notification("请输入正确的手机号", 3000)
      return false
    $.postJSON(
      '/user_mobile/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          uid = data.uid
        else
          if data.code == USER_EXIST
            location.href = "/user_mobile/sessions/new?code=" + USER_EIXST
    )
    return false

  signup = ->
    if uid == ""
      return
    name = $("#name").val()
    password = $("#password").val()
    verify_code = $("#code").val()
    password_confirm = $("#password-confirm").val()
    
    if password != password_confirm
      $.mobile_page_notification("两次输入密码不一致", 2000)
      return
    
    $.postJSON(
      '/user_mobile/sessions/' + uid + '/verify',
      {
        name: name
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          location.href = "/user_mobile/sessions/new?code=" + SIGNIN_DONE
        else
          if data.code == WRONG_VERIFY_CODE
            $.mobile_page_notification("验证码错误", 2000)
      )

  $(".signup").click ->
    signup()
    return false
