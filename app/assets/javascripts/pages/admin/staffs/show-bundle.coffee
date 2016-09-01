$ ->
  $("#center_id").change ->
    console.log $(this).val()
    center_id = $(this).val()
    $.putJSON(
      '/admin/staffs/' + window.sid + "/change_center",
      {
        center_id: center_id
      },
      (data) ->
        if data.success
          $.page_notification("岗位调整成功")
    )

  $(".status-btn").click ->
    if $(this).hasClass("lock-btn")
      admin_action = "lock"
      msg = "账户已锁定"
      btn_text = "解锁"
      status_text = "账号锁定中，暂时无法使用"
    if $(this).hasClass("unlock-btn")
      admin_action = "unlock"
      msg = "账户已解锁"
      btn_text = "锁定"
      status_text = ""
    if $(this).hasClass("open-btn")
      admin_action = "open"
      msg = "账户已开通"
      btn_text = "锁定"
      status_text = ""
    btn = $(this)
    $.putJSON(
      '/admin/staffs/' + window.sid + "/change_status",
      {
        admin_action: admin_action
      },
      (data) ->
        if data.success
          $.page_notification(msg)
          btn.text(btn_text)
          if admin_action == "lock"
            btn.removeClass("lock-btn").addClass("unlock-btn")
            $(".staff-status").removeClass("normal-staff").addClass("locked-staff").text(status_text)
          if admin_action == "unlock"
            btn.removeClass("unlock-btn").addClass("lock-btn")
            $(".staff-status").removeClass("locked-staff").addClass("normal-staff").text(status_text)
          if admin_action == "open"
            btn.removeClass("open-btn").addClass("lock-btn")
            $(".staff-status").removeClass("new-staff").addClass("normal-staff").text(status_text)
    )
