$ ->

  if parseInt(window.code) == REQUIRE_SIGNIN
    $.mobile_page_notification("已注册，请直接登录", 3000)


  signin = ->
    mobile = $("#mobile").val()
    password = $("#password").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $(".error-notice").css("visibility","visible")
      $("#mobile").addClass("clicked-box")
      return
    $("#mobile").removeClass("clicked-box")
    $.postJSON(
      '/user_mobile/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          # $(".error-notice").css("visibility","hidden")
          location.href = "/user_mobile/feeds"
        else
          if data.code == NO_CENTER 
            $.page_notification("请通知管理员开通账号", 3000)
          if data.code == USER_NOT_EXIST
            $(".error-notice").text("帐号不存在").css("visibility","visible")
          if data.code == USER_NOT_VERIFIED
            $(".error-notice").text("手机号未验证").css("visibility","visible")
          if data.code == WRONG_PASSWORD
            $(".error-notice").text("密码错误").css("visibility","visible")
      )

  $(".signin").click ->
    signin()
    return false