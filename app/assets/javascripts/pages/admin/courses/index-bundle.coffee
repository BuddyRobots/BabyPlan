
$ ->
  $(".add-btn").click ->
    location.href = "/admin/courses/new"

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("link-available")
      current_state = "available"
    cid = $(this).closest("tr").attr("data-id")
    link = $(this)
    console.log current_state
    $.postJSON(
      '/admin/courses/' + cid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification("操作完成")
          if current_state == "available"
            link.removeClass("link-available")
            link.addClass("link-unavailable")
            link.text("上架")
            link.closest("tr").removeClass("available")
            link.closest("tr").addClass("unavailable")
          else
            link.addClass("link-available")
            link.removeClass("link-unavailable")
            link.text("下架")
            link.closest("tr").addClass("available")
            link.closest("tr").removeClass("unavailable")
      )
    return false