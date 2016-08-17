
$ ->
  # forgotpassword
  $(".forget-password").click ->
    $("#signinModal").modal('hide')


  $(".close").click ->
    clearTimeout(timer)
    wait = 60
    $("#mobilecode").text("获取验证码")
    $("#mobilecode").addClass("unclicked")
    $("#mobilecode").removeClass("clicked")
    $("#mobilecode").attr("disabled", false)

    $("#mobile-code").text("获取验证码")
    $("#mobile-code").addClass("unclicked")
    $("#mobile-code").removeClass("clicked")
    $("#mobile-code").attr("disabled", false)

  uid = ""
  timer = null
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
      timer = setTimeout (->
        time o
        return
      ), 1000
    return

  $("#mobilecode").click ->
    mobile = $("#signup-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $("#mobile-notice").css("visibility","visible")
      $("#signup-mobile").addClass("clicked-box")
      return
    $("#signup-mobile").removeClass("clicked-box")
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
    if timer != null
      clearTimeout(timer)
    time this

  check_signup_input = ->
    console.log "check_signup_input pressed"
    if $("#signup-name").val().trim() == "" ||
        $("#signup-address").val().trim() == "" ||
        $("#signup-mobile").val().trim() == "" ||
        $("#signup-mobilecode").val().trim() == "" ||
        $("#signup-password").val().trim() == "" ||
        $("#signup-confirm-password").val().trim() == ""
      $("#signup").addClass("button-disabled")
      $("#signup").removeClass("button-enabled")
    else
      $("#signup").removeClass("button-disabled")
      $("#signup").addClass("button-enabled")

  toggle_password_tip = (wrong) ->
    if (wrong)
      $("#signup-password").addClass("clicked-box")
      $("#signup-confirm-password").addClass("clicked-box")
      $("#password-notice").css("visibility","visible")
    else
      $("#signup-password").removeClass("clicked-box")
      $("#signup-confirm-password").removeClass("clicked-box")
      $("#password-notice").css("visibility","hidden")

  $("#signup-name").keyup ->
    check_signup_input()
  $("#signup-address").keyup ->
    check_signup_input()
  $("#signup-mobile").keyup ->
    check_signup_input()
  $("#signup-mobilecode").keyup ->
    check_signup_input()
  $("#signup-password").keyup ->
    toggle_password_tip(false)
    check_signup_input()
  $("#signup-confirm-password").keyup ->
    toggle_password_tip(false)
    check_signup_input()


  # register
  $("#signup").click ->
    if uid == ""
      # $.page_notification("欢迎！", 3000)
      return
    if $(this).hasClass("button-enabled") == false
      return
    name = $("#signup-name").val()
    center = $("#signup-address").val()
    password = $("#signup-password").val()
    verify_code = $("#mobilecode").val()
    password_verify_code = $("#signup-confirm-password").val()
    
    if password != password_verify_code
      toggle_password_tip(true)
      return
    
    $.postJSON(
      '/staff/sessions/' + uid + '/verify',
      {
        name: name
        center: center
        password: password
        verify_code: verify_code
      },
      (data) ->
        if !data.success
          $("#verify-code-notice").text("WRONG_VERIFY_CODE").css("visibility","visible")
      )




  $("#mobile-code").click ->

    mobile = $("#forget-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $("#forget-mobile-notice").css("visibility","visible")
      $("#forget-mobile").addClass("clicked-box")
      return
    $("#forget-mobile").removeClass("clicked-box")
    $.postJSON(
      '/staff/sessions/forget_password',
      {
        mobile: mobile
      },
      (data) ->
        if data.success
          $("#forget-mobile-notice").css("visibility","hidden")
          uid = data.uid
        else
          $("#forget-verify-code-notice").text("WRONG_VERIFY_CODE").css("visibility","visible")
          $("#forget-mobile-notice").text("USER_EXIST").css("visibility","visible")     

      )
    time1 this






    







  
