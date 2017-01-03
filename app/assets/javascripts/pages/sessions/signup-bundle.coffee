$ ->
  uid = ""
  timer = null
  wait = 60

  $("#signup_btn").attr("disabled", true)
  time = (o) ->
    $(o).attr("disabled", true)
    $(o).addClass("clicked")
    $(o).removeClass("verify-code-btn")
    if wait == 0
      $(o).attr("disabled", false)
      $(o).text("获取验证码")
      wait = 60
      $(o).removeClass("clicked")
      $(o).addClass("verify-code-btn")
    else
      $(o).text("重发"　+ wait + "s")
      wait--
      timer = setTimeout (->
        time o
        return
        ), 1000
    return

  $("#verifycode").click ->
    mobile = $("#mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#mobile_notice").text("请输入正确手机号").css("visibility", "visible")
      return false
    $.postJSON(
      "/sessions/signup",
      {
        mobile: mobile
      },
      (data) ->
        if data.success
          $("#mobile_notice").css("visibility", "hidden")
          uid = data.uid
          console.log(uid)
          if timer != null
            clearTimeout(timer)
          time("#verifycode")
        else
          if data.code == USER_EXIST
            $("#mobile_notice").text("该手机号已注册，请直接登录").css("visibility", "visible")
          if data.code == OTHER_TYPE_USER_EXIST
            $("#mobile_notice").text("用户类型错误").css("visibility", "visible")
      )
    return false

  toggle_password_tip = (wrong) ->
    if (wrong)
      $("#password_notice").css("visibility", "visible")
    else
      $("#password_notice").css("visibility", "hidden")

  check_signup_input = ->
    if $("#mobile").val().trim() == "" ||
        $("#mobilecode").val().trim() == "" ||
        $("#password").val().trim() == "" ||
        $("#password_again").val().trim() == "" ||
        uid == ""
      $("#signup_btn").attr("disabled", true)
    else
      $("#signup_btn").attr("disabled", false)
  # check_signup_input()

  $("#mobile").keyup ->
    check_signup_input()
    $("#mobile_notice").css("visibility", "hidden")
  $("#mobilecode").keyup ->
    check_signup_input()
    $("#code_notice").css("visibility", "hidden")
  $("#password").keyup ->
    check_signup_input()
    $("#password_notice").css("visibility", "hidden")
  $("#password_again").keyup ->
    check_signup_input()
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

  signup = ->
    console.log(uid)

    if uid == ""
      return
    if $("#signup_btn").attr("disabled") == true
      return
    verify_code = $("#mobilecode").val()
    password = $("#password").val()
    password_again = $("#password_again").val()
    console.log(verify_code)
    if password != password_again
      toggle_password_tip(true)
      return
    $.postJSON(
      '/sessions/' + uid +　'/verify',
      {
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          $.page_notification("注册完成，请登录", 1000)
          $(".input-div input").val("")
          location.href = "/sessions/signin_page"
        else
          if data.code == WRONG_VERIFY_CODE
            $("#code_notice").text("验证码错误").css("visibility", "visible")
          if data.code == USER_NOT_EXIST
            $("#mobile_notice").text("账号不存在").css("visibility", "visible")
      )

  $("#signup_btn").click ->
    signup()
    return false
  $("#password_again").keydown (event) ->
    code = event.which
    if code == 13
      signup()

  $("#jump_to_signin").click ->
    location.href = "/sessions/signin_page"






