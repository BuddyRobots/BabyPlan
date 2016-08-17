
$ ->
  # forgotpassword
  $(".forget-password").click ->
    $("#signinModal").modal('hide')

  uid = ""

  # verifycode
  wait = 60
  time = (o) ->
    if wait == 0
      o.removeAttribute 'disabled'
      o.value = '获取验证码'
      wait = 60
    else
      o.setAttribute 'disabled', true
      o.value = '重新发送(' + wait + ')'
      o.style.background = "#d4d4d4"
      wait--
      setTimeout (->
        time o
        return
      ), 1000
    return
  $("#mobilecode").click ->
    time this



    mobile = $("#signup-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $("#mobile-notice").css("visibility","visible")
      $("#signup-mobile").css("border","1px solid #d70c19")
      return
    
    $.postJSON(
      '/staff/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          $("#mobile-notice").css("visibility","hidden")
          uid = data.uid
          console.log uid
        #需要修改
        else
          $("#mobile-notice").val("USER_EXIST").css("visibility","visible")     
          console.log $("#mobile-notice").val()
    )

  # register
  $("#signup").click ->
    name = $("#signup-name").val()
    address = $("#signup-address").val()
    mobile = $("#signup-mobile").val()
    mobile_verify_code = $("#signup-mobilecode").val()
    password = $("#signup-password").val()
    password_verify_code = $("#signup-confirm-password").val()
    
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#mobile-notice").css("visibility","visible")
      $("#signup-mobile").css("border","1px solid #d70c19")
      return

    if mobile_verify_code != "111111"
      $("#signup-mobilecode").css("border","1px solid #d70c19")
      $("#verify-code-notice").css("visibility","visible")

    







  
