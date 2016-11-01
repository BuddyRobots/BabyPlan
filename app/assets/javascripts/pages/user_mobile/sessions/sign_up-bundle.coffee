$ ->
  $(".identifycode").click ->
    mobile = $("#signup-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      # $(".notice-div").show()
      $.mobile_page_notification("请登录管理员系统", 3000)
      # $(".notice").text("请输入正确的手机号")
      return false
    $("#signup-mobile").removeClass("clicked-box")
    $.postJSON(
      '/user_mobile/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          $("#mobile-notice").css("visibility","hidden")
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time("#mobilecode")
        else
          if data.code == USER_EXIST
            $("#mobile-notice").text("该手机号已注册，请直接登录").css("visibility","visible")    
    )
    return false