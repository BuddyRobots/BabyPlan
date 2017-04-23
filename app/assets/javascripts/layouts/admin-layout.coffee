$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录管理员系统", 3000)
    $("#signinModal").modal("show")

  $(".modify_password").click ->
    $("#modify_passwordModal").modal("show")
    $("#modify_passwordModal input").val("")
    $("#confirm-modify-pwd").addClass("button-disabled")
    $("#confirm-modify-pwd").removeClass("button-enabled")


  $(".close-btn").click ->
    $("input").val("")
    $("input").removeClass("clicked-box")
    $("#confirm-modify-pwd").removeClass("button-enabled")

  toggle_password_tip = (wrong) ->
    if (wrong)
      $("#password").addClass("clicked-box")
    else
      $("#password").removeClass("clicked-box")
  toggle_confirm_password_tip = (wrong) ->
    if (wrong)
      $("#new-password").addClass("clicked-box")
      $("#confirm-password").addClass("clicked-box")
    else
      $("#new-password").removeClass("clicked-box")
      $("#confirm-password").removeClass("clicked-box")

  check_modify_password_input = ->
    if $("#password").val().trim() == "" ||
        $("#new-password").val().trim() == "" ||
        $("#confirm-password").val().trim() == ""
      $("#confirm-modify-pwd").addClass("button-disabled")
      $("#confirm-modify-pwd").removeClass("button-enabled")
    else
      $("#confirm-modify-pwd").addClass("button-enabled")
      $("#confirm-modify-pwd").removeClass("button-disabled")

  $("#password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_password_tip(false)
    check_modify_password_input()
  $("#new-password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_confirm_password_tip(false)
    check_modify_password_input()
  $("#confirm-password").keyup (event) ->
    code = event.which
    if code != 13
      toggle_confirm_password_tip(false)
    check_modify_password_input()

  confirm = ->
    password = $("#password").val()
    new_password = $("#new-password").val()
    confirm_password = $("#confirm-password").val()
    if new_password != confirm_password
      toggle_confirm_password_tip(true)
      $.page_notification("两次密码输入不一致", 3000)
      return
    $.postJSON(
      '/admin/sessions/change_password',
      {
        password: password
        new_password: new_password
      },
      (data) ->
        if data.success
          $.page_notification("修改密码已完成", 3000)
          $("#modify_passwordModal").modal("hide")
        else
          $.page_notification("原始密码输入错误", 3000)
          toggle_password_tip(true)
    )

  $("#confirm-modify-pwd").click ->
    confirm()
    return false

  $("#confirm-password").keydown (event) ->
    code = event.which
    if code == 13
      confirm()


