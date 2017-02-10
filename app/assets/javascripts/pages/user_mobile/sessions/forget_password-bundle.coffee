$ ->

  uid = ""
  timer = null
  wait = 60

  $("#confirm_btn").attr("disabled", true)

  $("#to_signin").click ->
    location.href = "/user_mobile/sessions/signin"

  time = (o) ->
    $(o).attr("disabled", true)
    if wait == 0
      $(o).attr("disabled", false)
      $(o).text('获取验证码')
      wait = 60
    else
      $(o).text("重发"　+ wait + "s")
      wait--
      timer = setTimeout (->
        time o
        return
      ), 1000
    return

  toggle_mobile_tip = (wrong) ->
    if (wrong)
      $("#mobile_notice").css("visibility", "visible")
    else
      $("#mobile_notice").css("visibility", "hidden")

  check_forget_input = ->
    if $("#mobile").val().trim() == "" ||
        $("#password").val().trim() == "" ||
        $("#password_again").val().trim() == "" ||
        $("#mobilecode").val().trim() == ""
      $("#confirm_btn").attr("disabled", true)
    else
      $("#confirm_btn").attr("disabled", false)

  $("#mobile").keyup (event) ->
    code = event.which
    if code != 13
      toggle_mobile_tip(false)   
    check_forget_input()

  toggle_password_tip = (wrong) ->
    if (wrong)
      $("#password_notice").css("visibility", "visible")
    else
      $("#password_notice").css("visibility", "hidden")

  $("#password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_password_tip(false)   
    check_forget_input()

  $("#password_again").keyup (event) ->
    code = event.which
    if code != 13
      toggle_password_tip(false)   
    check_forget_input()

  $("#verifycode").click ->
    mobile = $("#mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#mobile_notice").css("visibility", "visible")
      return false
    $.postJSON(
      '/user_mobile/sessions/modify_forget_password',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          $("#mobile_notice").css("visibility", "hidden")
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time("#verifycode")
        else
          if data.code == USER_NOT_EXIST
            $.mobile_page_notification("用户不存在", 1000)
    )

  forget = ->
    if uid == ""
      $.mobile_page_notification("请输入手机号获取验证码", 1000)
      return
    mobile = $("#mobile").val()
    password = $("#password").val()
    verify_code = $("#mobilecode").val()
    password_confirm = $("#password_again").val()
    if mobile == "" || password == "" || verify_code == "" || password_confirm == ""
      $.mobile_page_notification("请补全信息", 1000)
      return
    if password != password_confirm
      $("#password_notice").css("visibility", "visible")
      return
    
    $.postJSON(
      '/user_mobile/sessions/' + uid + '/reset_password',
      {
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          $.mobile_page_notification("密码已重置，请登录", 1000)
          $(".input-div input").val("")
          location.href = "/user_mobile/sessions/signin"
        else
          if data.code == WRONG_VERIFY_CODE
            $("#code_notice").css("visibility", "visible")
          if data.code == USER_NOT_EXIST
            $("#mobile_notice").text("账号不存在").css("visibility", "visible")
          if data.code == USER_NOT_VERIFIED
            $("#mobile_notice").text("手机号未验证").css("visibility", "visible")
      )

  $("#confirm_btn").click ->
    forget()
    return false

  $("#password_again").keydown (event) ->
    code = event.which
    if code == 13
      forget()

