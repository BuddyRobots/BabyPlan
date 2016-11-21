
$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录工作人员后台", 3000)
    $("#signinModal").modal("show")

  $(".modify_password").click ->
    $("#modify_passwordModal").modal("show")
    $("#modify_passwordModal input").val("")

  $(".close-btn").click ->
    $("input").val("")
    $("input").removeClass("clicked-box")
    $("button").removeClass("button-enabled")

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
      $("#confirm").addClass("button-disabled")
      $("#confirm").removeClass("button-enabled")
    else
      $("#confirm").removeClass("button-disabled")
      $("#confirm").addClass("button-enabled")

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
      '/staff/sessions/change_password',
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

  window.show_review = (rid, ele) ->
    $.postJSON(
      '/staff/reviews/' + rid + '/show_review',
      { },
      (data) ->
        if data.success
          $.page_notification("设置完成")
          ele.removeClass("show-review").addClass("hide-review")
          ele.text("隐藏")
        else
          $.page_notification("服务器出错")
      )

  window.hide_review = (rid, ele) ->
    $.postJSON(
      '/staff/reviews/' + rid + '/hide_review',
      { },
      (data) ->
        if data.success
          $.page_notification("设置完成")
          ele.removeClass("hide-review").addClass("show-review")
          ele.text("公开")
        else
          $.page_notification("服务器出错")
      )
