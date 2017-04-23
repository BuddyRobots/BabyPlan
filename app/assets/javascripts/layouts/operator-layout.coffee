$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录图书录入员信息系统", 3000)
    $("#signinModal").modal("show")

  if parseInt(window.code) == DONE
    $.page_notification("操作完成", 3000)

  $(".modify_password").click ->
    $("#modify_passwordModal").modal("show")
    $("#modify_passwordModal input").val("")

  $("#modify_passwordModal .close-btn").click ->
    $("#modify_passwordModal input").val("")
    $("#modify_passwordModal input").removeClass("clicked-box")
    $("#modify_passwordModal button").removeClass("button-enabled")

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
      $("#confirm").addClass("button-disabled").attr("disabled", true)
      $("#confirm").removeClass("button-enabled")
    else
      $("#confirm").removeClass("button-disabled")
      $("#confirm").addClass("button-enabled").attr("disabled", false)

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
      '/operator/sessions/change_password',
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

  $("#confirm").click ->
    confirm()
    return false

  $("#confirm-password").keydown (event) ->
    code = event.which
    if code == 13
      confirm()

  $("#jump_to_books").click ->
    location.href = "/operator/books"

