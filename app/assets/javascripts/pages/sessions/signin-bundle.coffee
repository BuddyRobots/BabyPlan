
$ ->
  $("#to_signup").click ->
    $("input").val("")
    location.href = "/sessions/signup_page"
  $("#to_forget_password").click ->
    $("input").val("")
    location.href = "/sessions/forgetpassword_page"
  $("#signin_btn").attr("disabled", true)

  toggle_signin_tip = (wrong) ->
    if (wrong)
      $("#error_notice").css("visibility", "visible")
    else
      $("#error_notice").css("visibility", "hidden")

  check_signin_input = ->
    if $("#mobile").val().trim() == "" ||
        $("#password").val().trim() == ""
      $("#signin_btn").attr("disabled", true)
    else
      $("#signin_btn").attr("disabled", false)

  $("#mobile").keyup (event) ->
    code = event.which
    if code != 13
      toggle_signin_tip(false)   
    check_signin_input()
  $("#password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_signin_tip(false)
    check_signin_input()

  signin = ->
    if $("#signin_btn").attr("disabled") == true
      return
    mobile = $("#mobile").val()
    password = $("#password").val()
    console.log(mobile)
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#error_notice").text("手机号或密码错误").css("visibility", "visible")
      return
    $.postJSON(
      '/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          if data.has_name
            location.href = "/staff/courses"
          else
            location.href = "/staff/accounts"
        else
          if data.code == USER_NOT_EXIST
            $("#error_notice").text("帐号不存在").css("visibility","visible")
          if data.code == USER_NOT_VERIFIED
            $("#error_notice").text("手机号未验证").css("visibility","visible")
          if data.code == WRONG_PASSWORD
            $("#error_notice").text("密码错误").css("visibility","visible")
      )

  $("#signin_btn").click ->
    signin()
    return false

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()
   
