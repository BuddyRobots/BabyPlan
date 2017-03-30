
$ ->
  $("#sign-in").click ->
    if $("input").val().trim() != ""
      $("#signin").removeClass("button-disabled")
      $("#signin").addClass("button-enabled")

  # 自动补全注册地址
  $("#signup-address").autocomplete(
    source: "/centers"
    appendTo: "#signupModal"
  )
  
  $(".close-signin").click ->
    $("#mobile").val("")
    $("#password").val("")
    $(".error-notice").css("visibility", "hidden")
    $("#signin").addClass("button-disabled")
    $("#signin").removeClass("button-enabled")
    $("#mobile").removeClass("clicked-box")

  $("#signinModal").on "hidden.bs.modal", ->
    $("#mobile").val("")
    $("#password").val("")
    $(".error-notice").css("visibility", "hidden")
    $("#signin").addClass("button-disabled")
    $("#signin").removeClass("button-enabled")
    $("#mobile").removeClass("clicked-box")

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
    if $("#mobile").val().trim() == "" ||
        $("#password").val().trim() == ""
      $("#signin").addClass("button-disabled")
      $("#signin").removeClass("button-enabled")
    else
      $("#signin").removeClass("button-disabled")
      $("#signin").addClass("button-enabled")

  $("#mobile").keyup ->
    check_signin_input()
    $(".error-notice").css("visibility","hidden")
  $("#password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_signin_password_tip(false)
    check_signin_input()

# enter click
  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()


# sign in button
  signin = ->
    if $("#signin").hasClass("button-enabled") == false
      return
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
      '/operator/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          $(".error-notice").css("visibility","hidden")
          location.href = "/operator/books"
        else
          if data.code == ACCOUNT_LOCKED 
            $.page_notification("账号已被管理员锁定，无法登录", 3000)
          if data.code == USER_NOT_EXIST
            $(".error-notice").text("帐号不存在").css("visibility","visible")
          if data.code == WRONG_PASSWORD
            $(".error-notice").text("密码错误").css("visibility","visible")
      )

  $("#signin").click ->
    signin()
    return false









    







  
