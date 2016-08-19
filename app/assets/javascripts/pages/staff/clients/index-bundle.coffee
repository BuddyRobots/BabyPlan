$ ->

  uid = ""
  timer = null
  wait = 60
  $(".close").click ->
    clearTimeout(timer)
    wait = 60
    $("#mobile-code").text("获取验证码")
    $("#mobile-code").addClass("unclicked")
    $("#mobile-code").removeClass("clicked")
    $("#mobile-code").attr("disabled", false)


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


  # $("#input-search").keydown (event) ->
  #    code = event.which
  #    if code == 13
       # search()  按下事件
  

  perss = ->
    window.location.href = "/staff/clients"




  # mobile verify code
  $("#mobilecode").click ->
    mobile = $("#kid-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    console.log mobile_retval
    if mobile_retval == false
      $("#mobile-notice").css("visibility","visible")
      $("#kid-mobile").addClass("clicked-box")
      return
    $("#kid-mobile").removeClass("clicked-box")
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
          $("#mobile-notice").text("该手机号已添加").css("visibility","visible")     
          console.log $("#mobile-notice").text()
    )
    if timer != null
      clearTimeout(timer)
    time this

  check_add_input = ->
    console.log "check_add_input pressed"
    if $("#kid-name").val().trim() == "" ||
        $("#kid-address").val().trim() == "" ||
        $("#kid-mobile").val().trim() == "" ||
        $("#kid-mobilecode").val().trim() == "" ||
        $("#kid-birthday").val().trim() == "" ||
        $("#kid-parent").val().trim() == "" ||
        $("#kid-sex").val().trim() == "" ||
        uid == ""
      $("#kid-add").addClass("button-disabled")
      $("#kid-add").removeClass("button-enabled")
    else
      $("#kid-add").removeClass("button-disabled")
      $("#kid-add").addClass("button-enabled")

  $("#kid-name").keyup ->
    check_add_input()
  $("#kid-address").keyup ->
    check_add_input()
  $("#kid-mobile").keyup ->
    check_add_input()
  $("#kid-mobilecode").keyup ->
    check_add_input()
    $("#verify-code-notice").css("visibility","hidden")
  $("#kid-birthday").keyup ->
    check_add_input()
  $("#kid-parent").keyup ->
    check_add_input()
  $("#kid-sex").keyup ->
    check_add_input()

  $("#kid-add").click ->
    if uid == ""
      # $.page_notification("欢迎！", 3000)
      return
    if $(this).hasClass("button-enabled") == false
      return
    name = $("#signup-name").val()
    center = $("#signup-address").val()
    password = $("#signup-password").val()
    verify_code = $("#signup-mobilecode").val()
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
        if data.success
          $.page_notification("注册完成，请通知管理员分配儿童中心",3000)
        else
          $("#verify-code-notice").text("验证码错误").css("visibility","visible")
      )
