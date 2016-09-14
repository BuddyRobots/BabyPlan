
$ ->
  # forgotpassword
  $(".rucaptcha-image").click ->
    $(this).attr('src', /rucaptcha/ + '?' + (new Date()).getTime())

  $(".forget-password").click ->
    $("#signinModal").modal('hide')

  uid = ""
  timer = null
  wait = 60
  $(".close").click ->
    clearTimeout(timer)
    wait = 60
    $("#mobilecode").text("获取验证码")
    $("#mobilecode").addClass("unclicked")
    $("#mobilecode").removeClass("clicked")
    $("#mobilecode").attr("disabled", false)

    $("#forget-mobile-code").text("获取验证码")
    $("#forget-mobile-code").addClass("unclicked")
    $("#forget-mobile-code").removeClass("clicked")
    $("#forget-mobile-code").attr("disabled", false)

    $("input").val("")
    $("input").removeClass("clicked-box")
    $(".notice").css("visibility", "hidden")
    $("button").removeClass("button-enabled")

  # verifycode 60 sec reverse 
  time = (o) ->
    console.log wait
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
      return false
    $("#signup-mobile").removeClass("clicked-box")
    captcha = $("#forget-captcha-input").val()
    if captcha == ""
      $("#forget-captcha-notice").text("请输入图形验证码").css("visibility", "visible") 
      return false
    $.postJSON(
      '/admin/sessions/signup',
      {
        mobile: mobile
        captcha: captcha
      },
      (data) ->
        console.log data
        if data.success
          $("#mobile-notice").css("visibility","hidden")
          uid = data.uid
          console.log uid
          if timer != null
            clearTimeout(timer)
          time("#mobilecode")
        #需要修改
        else
          if data.code == WRONG_CAPTCHA
            $("#signup-captcha-notice").text("图形验证码错误").css("visibility", "visible") 
          if data.code == USER_NOT_EXIST
            $("#forget-mobile-notice").text("该手机号未注册").css("visibility","visible")
          console.log $("#mobile-notice").text()
    )
    return false

  # forgetpassword user mobile verify
  $("#forget-mobile-code").click ->
    mobile = $("#forget-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $("#forget-mobile-notice").css("visibility","visible")
      $("#forget-mobile").addClass("clicked-box")
      return false
    captcha = $("#forget-captcha-input").val()
    if captcha == ""
      $("#forget-captcha-notice").text("请输入图形验证码").css("visibility", "visible") 
      return false
    $("#forget-mobile").removeClass("clicked-box")
    $.postJSON(
      '/admin/sessions/forget_password',
      {
        mobile: mobile
        captcha: captcha
      },
      (data) ->
        console.log data
        if data.success
          $("#forget-mobile-notice").css("visibility","hidden")
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time("#forget-mobile-code")
        else
          if data.code == WRONG_CAPTCHA
            $("#signup-captcha-notice").text("图形验证码错误").css("visibility", "visible") 
          if data.code == USER_NOT_EXIST
            $("#forget-mobile-notice").text("该手机号未注册").css("visibility","visible")
      )
    return false

  toggle_forget_password_tip = (wrong) ->
    if (wrong)
      $("#forget-password").addClass("clicked-box")
      $("#forget-confirm-password").addClass("clicked-box")
      $("#forget-password-notice").css("visibility","visible")
    else
      $("#forget-password").removeClass("clicked-box")
      $("#forget-confirm-password").removeClass("clicked-box")
      $("#forget-password-notice").css("visibility","hidden")

  check_forget_input = ->
    console.log "check_signup_input pressed"
    if $("#forget-mobile").val().trim() == "" ||
        $("#forget-mobilecode").val().trim() == "" ||
        $("#forget-password").val().trim() == "" ||
        $("#forget-confirm-password").val().trim() == "" ||
        uid == ""
      $("#forget").addClass("button-disabled")
      $("#forget").removeClass("button-enabled")
    else
      $("#forget").removeClass("button-disabled")
      $("#forget").addClass("button-enabled")

  $("#forget-mobile").keyup ->
    check_forget_input()
    $("#forget-mobile-notice").css("visibility","hidden")
  $("#forget-mobilecode").keyup ->
    check_forget_input()
    $("#forget-verify-code-notice").css("visibility","hidden")
  $("#forget-captcha-input").keyup ->
    check_forget_input()
    $("#forget-captcha-notice").css("visibility","hidden")
  $("#forget-password").keyup ->
    toggle_forget_password_tip(false)
    check_forget_input()
  $("#forget-confirm-password").keyup ->
    toggle_forget_password_tip(false)
    check_forget_input()

  # reset password
  forget = ->
    if uid == ""
      # $.page_notification("欢迎！", 3000)
      return
    if $("#forget").hasClass("button-enabled") == false
      return
    password = $("#forget-password").val()
    verify_code = $("#forget-mobilecode").val()
    password_verify_code = $("#forget-confirm-password").val()

    if password != password_verify_code
      toggle_forget_password_tip(true)
      return

    $.postJSON(
      '/admin/sessions/' + uid + '/reset_password',
      {
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          $("#forgetModal").modal('hide')
          $("#signinModal").modal('show')
          $.page_notification("密码已重置，请登录", 3000)
        else
          $("#forget-verify-code-notice").text("验证码错误").css("visibility","visible")
      )
  $("#forget").click ->
    forget()
    return false
  $("#forget-confirm-password").keydown (event) ->
    code = event.which
    if code == 13
      forget()


  $("#forget-register").click ->
    $("#forgetModal").modal('hide')
    $("#signinModal").modal('show')


  toggle_signin_password_tip = (wrong) ->
    if (wrong)
      $("#mobile").addClass("clicked-box")
      $("#password").addClass("clicked-box")
      $(".error-notice").css("visibility","visible")
    else
      $("#mobile").removeClass("clicked-box")
      $("#password").removeClass("clicked-box")
      $(".error-notice").css("visibility","hidden")

  check_signin_input = ->
    console.log "check_signin_input pressed"
    if $("#mobile").val().trim() == "" ||
        $("#password").val().trim() == ""
      $(".signin").addClass("button-disabled")
      $(".signin").removeClass("button-enabled")
    else
      $(".signin").removeClass("button-disabled")
      $(".signin").addClass("button-enabled")

  $("#mobile").keyup ->
    check_signin_input()
    $(".error-notice").css("visibility", "hidden")
    $("input").removeClass("clicked-box")
  $("#password").keyup ->
    toggle_signin_password_tip(false)
    check_signin_input()

# enter click
  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()


# sign in button
  signin = ->
    if $(".signin").hasClass("button-enabled") == false
      return
    mobile = $("#mobile").val()
    password = $("#password").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $(".error-notice").css("visibility","visible")
      $("#mobile").addClass("clicked-box")
      return false
    $("#mobile").removeClass("clicked-box")
    $.postJSON(
      '/admin/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          $(".error-notice").css("visibility","hidden")
          location.href = "/admin/staffs"
        else
          $(".error-notice").css("visibility","visible")
          $(".signin").addClass("button-disabled")
      )

  $(".signin").click ->
    signin()
    return false

