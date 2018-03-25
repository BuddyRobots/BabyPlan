$ ->

  if parseInt(window.code) == REQUIRE_SIGNIN
    $.mobile_page_notification("请登录", 1000)
  if parseInt(window.code) == USER_EXIST
    $.mobile_page_notification("已注册，请直接登录", 1000)
  if parseInt(window.code) == OTHER_TYPE_USER_EXIST
    $.mobile_page_notification("手机号已注册为工作人员", 1000)
  if parseInt(window.code) == SIGNIN_DONE
    $.mobile_page_notification("注册完成，请登录", 1000)


  signin = ->
    mobile = $("#mobile").val()
    password = $("#password").val()
    redirect = $("#redirect").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.mobile_page_notification("请正确输入账号", 1000)
      return
    $.postJSON(
      '/user_mobile/sessions',
      {
        mobile: mobile
        password: password
        redirect: redirect
      },
      (data) ->
        if data.success
          if data.user_return_to != null
            location.href = data.user_return_to
          else
            location.href = "/user_mobile/feeds"
        else
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("帐号不存在", 1000)
          if data.code == USER_NOT_VERIFIED
            $.mobile_page_notification("手机号未验证", 1000)
          if data.code == WRONG_PASSWORD
            $.mobile_page_notification("密码错误", 1000)
      )

  $(".signin").click ->
    signin()
    return false

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()

  $(".signup").click ->
    location.href = "/user_mobile/sessions/sign_up" 
