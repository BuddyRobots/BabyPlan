$ ->
  # calender set
  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true
      });
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] );
  $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" );
   

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
      '/staff/clients',
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
          $("#mobile-notice").text("帐号已存在").css("visibility","visible")     
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
        $("#kid-parent").val().trim() == "" ||
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
  $("#kid-parent").keyup ->
    check_add_input()

  $("#kid-add").click ->
    if uid == ""
      # $.page_notification("欢迎！", 3000)
      return
    if $(this).hasClass("button-enabled") == false
      return
    name = $("#kid-name").val()
    gender = $("#kid-gender").val()
    birthday = $("datepicker").val()
    address = $("#kid-address").val()
    parent = $("#kid-parent").val()
    verify_code = $("#kid-mobilecode").val()
    
    $.postJSON(
      '/staff/clients/' + uid + '/verify',
      {
        name: name
        center: center
        password: password
        verify_code: verify_code
      },
      (data) ->
        if !data.success
          if data.code = USER_NOT_EXIST
            $("#mobile-notice").text("帐号不存在").css("visibility","visible")
          if data.code = WRONG_VERIFY_CODE
            $("#verify-code-notice").text("验证码错误").css("visibility","visible")
      )
