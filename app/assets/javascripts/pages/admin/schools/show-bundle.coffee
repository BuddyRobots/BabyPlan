$ ->
  $(".close-school-btn").click ->
    $("#schoolModal").modal("show")

  $("#confirm-close").click ->
    $("#schoolModal").modal("hide")
    $.postJSON(
      '/admin/schools/' + window.sid + '/set_available',
      {
        available: false
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification("操作完成")
          location.href = "/admin/schools"
      )
    return false

  $("#cancel").click ->
    $("#schoolModal").modal("hide")


