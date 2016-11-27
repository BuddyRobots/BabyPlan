$ ->
  window.cid = null
  link = null
  $(".add-btn").click ->
    location.href = "/admin/centers/new"

  search = ->
    value = $("#search-input").val()
    window.location.href = "/admin/centers?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".set-available").click ->
    link = $(this)
    window.cid = $(this).closest("tr").attr("data-id") 
    if $(this).hasClass("link-unavailable")
      link.removeClass("link-unavailable")
      link.addClass("link-available")
      link.text("关闭")
      link.closest("tr").addClass("available")
      link.closest("tr").removeClass("unavailable")
      $.postJSON(
        '/admin/centers/' + window.cid + '/set_available',
        {
          available: true
        },
        (data) ->
      )
    else
      $("#closeModal").modal("show")

  $("#confirm").click ->
    $("#closeModal").modal("hide")
    $.postJSON(
      '/admin/centers/' + window.cid + '/set_available',
      {
        available: false
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification("操作完成")
          link.text("开放")
          link.closest("tr").removeClass("available")
          link.closest("tr").addClass("unavailable")
          link.addClass("link-unavailable")
          link.removeClass("link-available")
      )
    return false

  $("#cancel").click ->
    $("#closeModal").modal("hide")


  

