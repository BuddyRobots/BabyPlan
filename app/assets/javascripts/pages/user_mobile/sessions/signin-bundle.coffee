
$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.mobile_page_notification("请登录", 1000)
  if parseInt(window.code) == USER_EXIST
    $.mobile_page_notification("已注册，请直接登录", 1000)
  if parseInt(window.code) == OTHER_TYPE_USER_EXIST
    $.mobile_page_notification("手机号已注册为工作人员", 1000)
  if parseInt(window.code) == SIGNIN_DONE
    $.mobile_page_notification("注册完成，请登录", 1000)

  $("#to_signup").click ->
    $("input").val("")
    location.href = "/user_mobile/sessions/sign_up"
  $("#to_forget_password").click ->
    $("input").val("")
    location.href = "/user_mobile/sessions/forget_password"

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
      $("#error_notice").text("手机号错误").css("visibility", "visible")
      return
    $.postJSON(
      '/user_mobile/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          if data.user_return_to != null
            location.href = data.user_return_to
          else
            location.href = "/user_mobile/courses/list"
        else
          console.log data.code
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("帐号不存在", 1000)
          if data.code == USER_NOT_VERIFIED
            $.mobile_page_notification("手机号未验证", 1000)
          if data.code == WRONG_PASSWORD
            $.mobile_page_notification("密码错误", 1000)
      )

  $("#signin_btn").click ->
    signin()
    return false

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()

