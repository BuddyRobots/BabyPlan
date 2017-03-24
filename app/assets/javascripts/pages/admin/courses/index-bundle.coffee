
$ ->

  search = ->
    value = $("#search-input").val()
    location.href = "/admin/courses?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  if window.profile == "unshelf"
    $('.nav-tabs a[href="#tab2"]').tab('show')

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