$ ->
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
          if timer != null
            clearTimeout(timer)
          time(".identifycode")
        else
          if data.code == USER_EXIST
            location.href = "/user_mobile/sessions/new?code=" + USER_EIXST
    )
    return false