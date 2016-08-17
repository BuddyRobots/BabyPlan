
$ ->
  # forgotpassword
  $(".forget-password").click ->
    $("#signinModal").modal('hide')

  uid = ""

  # verifycode 60 sec reverse
  wait = 60
  time = (o) ->
    console.log o
    $(o).attr("disabled", true)
    $(o).addClass("clicked")
    $(o).removeClass("unclicked")
    if wait == 0
      $(o).attr("disabled", false)
      $(o).text('获取验证码')
      wait = 60
      $(o).removeClass("clicked")
      $(o).addClass("unclicked")
    else
      $(o).text('重发(' + wait + ')')
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
      $("#signup-mobile").addClass("clicked-box")
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
          $("#mobile-notice").text("USER_EXIST").css("visibility","visible")     
          console.log $("#mobile-notice").text()
    )

  # register
  $("#signup").click ->
    name = $("#signup-name").val()
    center = $("#signup-address").val()
    password = $("#signup-password").val()
    verify_code = $("#mobilecode").val()
    password_verify_code = $("#signup-confirm-password").val()
    

    if password != password_verify_code
      $("#signup-password").addClass("clicked-pass")
      $("#signup-confirm-password").addClass("clicked-box")
      $("#password-notice").css("visibility","visible")
      return
    
    $.postJSON(
      '/staff/sessions/' + uid + '/verify',
      {
        uid: uid
        name: name
        center: center
        password: password
        verify_code: verify_code
      },
      (data) ->
        if !data.success
          $("#verify-code-notice").text("WRONG_VERIFY_CODE").css("visibility","visible")
      )

    







  
