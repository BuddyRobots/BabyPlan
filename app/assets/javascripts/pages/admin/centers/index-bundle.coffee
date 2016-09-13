$ ->

  $(".add-btn").click ->
    location.href = "/admin/centers/new"

  search = ->
    value = $("#appendedInputButton").val()
    window.location.href = "/admin/centers?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".set-available").each ->
    if $(this).hasClass("link-unavailable")
      $(this).closest("tr").find(".access").hide()


  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("link-available")
      current_state = "available"
    cid = $(this).closest("tr").attr("data-id")
    link = $(this)
    console.log current_state
    $.postJSON(
      '/admin/centers/' + cid + '/set_available',
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
            link.text("打开")
            link.closest("tr").removeClass("available")
            link.closest("tr").addClass("unavailable")
            link.closest("tr").find(".access").hide()
          else
            link.addClass("link-available")
            link.removeClass("link-unavailable")
            link.text("关闭")
            link.closest("tr").addClass("available")
            link.closest("tr").removeClass("unavailable")
            link.closest("tr").find(".access").show()
      )
    return false
