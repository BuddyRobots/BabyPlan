$ ->

  if parseInt(window.code) == REQUIRE_SIGNIN
    $.mobile_page_notification("请登录", 3000)
  if parseInt(window.code) == USER_EXIST
    $.mobile_page_notification("已注册，请直接登录", 3000)
  if parseInt(window.code) == SIGNIN_DONE
    $.mobile_page_notification("注册完成，请登录", 3000)


  signin = ->
    mobile = $("#mobile").val()
    password = $("#password").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $.mobile_page_notification("帐号不存在", 3000)
      return
    $.postJSON(
      '/user_mobile/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          location.href = "/user_mobile/feeds"
        else
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("帐号不存在", 3000)
          if data.code == USER_NOT_VERIFIED
            $.mobile_page_notification("手机号未验证", 3000)
          if data.code == WRONG_PASSWORD
            $.mobile_page_notification("密码错误", 3000)
      )

  $(".signin").click ->
    signin()
    return false

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()