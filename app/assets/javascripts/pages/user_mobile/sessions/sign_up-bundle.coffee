$ ->
  uid = ""
  timer = null
  wait = 60

  $("#signup_btn").attr("disabled", true)
  time = (o) ->
    $(o).attr("disabled", true)
    if wait == 0
      $(o).attr("disabled", false)
      $(o).text('获取验证码')
      wait = 60
    else
      $(o).text("重发"　+ wait + "s")
      wait--
      timer = setTimeout (->
        time o
        return
      ), 1000
    return

  toggle_mobile_tip = (wrong) ->
    if (wrong)
      $("#mobile_notice").css("visibility", "visible")
    else
      $("#mobile_notice").css("visibility", "hidden")

  check_signup_input = ->
    if $("#mobile").val().trim() == "" ||
        $("#password").val().trim() == "" ||
        $("#password_again").val().trim() == "" ||
        $("#mobilecode").val().trim() == ""
      $("#signup_btn").attr("disabled", true)
    else
      $("#signup_btn").attr("disabled", false)

  $("#mobile").keyup (event) ->
    code = event.which
    if code != 13
      toggle_mobile_tip(false)   
    check_signup_input()

  toggle_password_tip = (wrong) ->
    if (wrong)
      $("#password_notice").css("visibility", "visible")
    else
      $("#password_notice").css("visibility", "hidden")

  $("#password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_password_tip(false)   
    check_signup_input()

  $("#password_again").keyup (event) ->
    code = event.which
    if code != 13
      toggle_password_tip(false)   
    check_signup_input()

  $("#verifycode").click ->
    mobile = $("#mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#mobile_notice").css("visibility", "visible")
      return false
    $.postJSON(
      '/user_mobile/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          $("#mobile_notice").css("visibility", "hidden")
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time("#verifycode")
        else
          if data.code == USER_EXIST
            location.href = "/user_mobile/sessions/signin?code=" + USER_EXIST
          if data.code == OTHER_TYPE_USER_EXIST
            location.href = "/user_mobile/sessions/signin?code=" + OTHER_TYPE_USER_EXIST
    )
    return false

  signup = ->
    if uid == ""
      $.mobile_page_notification("请输入手机号获取验证码", 1000)
      return
    mobile = $("#mobile").val()
    password = $("#password").val()
    verify_code = $("#mobilecode").val()
    password_confirm = $("#password_again").val()
    if mobile == "" || password == "" || verify_code == "" || password_confirm == ""
      $.mobile_page_notification("请补全信息", 1000)
      return
    if password != password_confirm
      $("#password_notice").css("visibility", "visible")
      return
    
    $.postJSON(
      '/user_mobile/sessions/' + uid + '/verify',
      {
        mobile: mobile
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          location.href = "/user_mobile/sessions/signin?code=" + SIGNIN_DONE
        else
          if data.code == WRONG_VERIFY_CODE
            $.mobile_page_notification("验证码错误", 1000)
      )

  $("#signup_btn").click ->
    signup()
    return false

  $("#password_again").keydown (event) ->
    code = event.which
    if code == 13
      signup()

  $("#to_signin").click ->
    location.href = "/user_mobile/sessions/signin"