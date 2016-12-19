$ ->
  # calender set
  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+0'
      })
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )
   
  uid = ""
  timer = null
  wait = 60
  $(".close").click ->
    clearTimeout(timer)
    wait = 60
    $("#mobilecode").text("获取验证码")
    $("#mobilecode").addClass("unclicked")
    $("#mobilecode").removeClass("clicked")
    $("#kid-mobile").removeClass("clicked-box")
    $("#mobilecode").attr("disabled", false)
    $("input").val("")
    $(".notice").css("visibility", "hidden")

  time = (o) ->
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

  # mobile verify code
  $("#mobilecode").click ->
    mobile = $("#kid-mobile").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $("#mobile-notice").css("visibility","visible")
      $("#kid-mobile").addClass("clicked-box")
      return false
    $("#kid-mobile").removeClass("clicked-box")
    $.postJSON(
      '/staff/clients',
      {
        mobile: mobile
      },
      (data) ->
        if data.success
          $("#mobile-notice").css("visibility","hidden")
          uid = data.uid
          if timer != null
            clearTimeout(timer)
          time("#mobilecode")
        #需要修改
        else
          $("#mobile-notice").text("帐号已存在").css("visibility","visible") 
    )
    return false
    

  check_add_input = ->
    if $("#kid-name").val().trim() == "" ||
        $("#kid-address").val().trim() == "" ||
        $("#kid-mobile").val().trim() == "" ||
        $("#kid-mobilecode").val().trim() == "" ||
        $("#kid-parent").val().trim() == "" ||
        $("#kid-password").val().trim() == "" ||
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
    $("#mobile-notice").css("visibility","hidden")
  $("#kid-mobilecode").keyup ->
    check_add_input()
    $("#verify-code-notice").css("visibility","hidden")
  $("#kid-parent").keyup ->
    check_add_input()
  $("#kid-password").keyup ->
    check_add_input()


# add button press
  kidAdd = ->
    if uid == ""
      # $.page_notification("欢迎！", 3000)
      return
    if $("#kid-add").hasClass("button-enabled") == false
      return
    name = $("#kid-name").val()
    gender = $("#kid-gender").val()
    birthday = $("#datepicker").val()
    address = $("#kid-address").val()
    parent = $("#kid-parent").val()
    verify_code = $("#kid-mobilecode").val()
    password = $("#kid-password").val()
    
    $.postJSON(
      '/staff/clients/' + uid + '/verify',
      {
        name: name
        gender: gender
        birthday: birthday
        password: password
        address: address
        parent: parent
        verify_code: verify_code
      },
      (data) ->
        if !data.success
          if data.code == USER_NOT_EXIST
            $("#mobile-notice").text("账号不存在").css("visibility", "visible")
          if data.code == WRONG_VERIFY_CODE
            $("#verify-code-notice").text("验证码错误").css("visibility", "visible")
        else
          $("#kidsaddModal").modal('hide')
          location.href = "/staff/clients"
      )
  $("#kid-add").click ->
    kidAdd()
    return false

  $("#kid-mobilecode").keydown (event) ->
    code = event.which
    if code == 13
      kidAdd()

# search-btn press
  search = ->
    value = $("#search-input").val()
    location.href = "/staff/clients?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()


