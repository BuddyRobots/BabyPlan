$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录工作人员后台", 3000)
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

  show_refund_modal = (begin) ->
    # $("#importantModal").modal("hide")
    $.getJSON "/staff/courses/next_refund_request/", (data) ->
      if data.success
        $('#importantModal #refund-course-name').attr("href", "/staff/courses/" + data.course_id)
        $('#importantModal #refund-course-name').text(data.course_name)
        $('#importantModal #refund-client-name').attr("href", "/staff/clients/" + data.course_id)
        $('#importantModal #refund-client-name').text(data.client_name)
        $('#importantModal #reason').val("")
        $('#importantModal').attr("data-id", data.id)
        $("#importantModal").modal("show")
        if begin == false
          $.page_notification("操作完成，显示下一条")
      else
        if data.code == BLANK_DATA
          $("#important-item").hide()
          $.page_notification("所有退款申请处理完毕")
        else
          $.page_notification("服务器出错")

  $("#important-modal").click ->
    show_refund_modal(true)

  $(".close").click ->
    $("#importantModal #reason").val("")

  $("#reject").click ->
    cp_id = $("#importantModal").attr("data-id")
    feedback = $("#importantModal input").val()
    $.postJSON(
      '/staff/courses/' + cp_id + '/reject_refund',
      {
        feedback: feedback
      },
      (data) ->
        if data.success
          show_refund_modal(false)
        else
          $.page_notification("服务器出错")
      )

  $("#agree-refund").click ->
    cp_id = $("#importantModal").attr("data-id")
    feedback = $("#importantModal input").val()
    $.postJSON(
      '/staff/courses/' + cp_id + '/approve_refund',
      {
        feedback: feedback
      },
      (data) ->
        if data.success
          show_refund_modal(false)
        else
          $.page_notification("服务器出错")
      )

