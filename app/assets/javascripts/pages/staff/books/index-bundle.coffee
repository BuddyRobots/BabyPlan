#= require wangEditor.min

$ ->
	# $("#signup-signin").click ->
	# location.href = "/staff/books/" + data.book_id


  $(".bookadd-btn").click ->
    location.href = "/staff/books/new"

  $(".merge-book").click ->
    location.href = "/staff/books/merge"

  $(".return").click ->
    client_name = $(this).closest('tr').attr('data-clientname')
    name = $(this).closest('tr').attr('data-name')
    id = $(this).closest('tr').attr('data-id')
    $("#returnModal").modal("show")
    $("#returnModal .client-name").text(client_name)
    $("#returnModal .book-name").text("《" + name + "》")
    $("#returnModal").attr("data-id", id)

  $("#return-cancel").click ->
    $("#returnModal").modal("hide")

  $("#return-confirm").click ->
    id = $("#returnModal").attr("data-id")
    $.postJSON(
      '/staff/books/' + id + '/back',
      { },
      (data) ->
        if data.success
          window.location.href = "/staff/books?code=" + DONE + "&profile=borrows"
      )

  $(".lost").click ->
    client_name = $(this).closest('tr').attr('data-clientname')
    name = $(this).closest('tr').attr('data-name')
    id = $(this).closest('tr').attr('data-id')
    $("#lostModal").modal("show")
    $("#lostModal .client-name").text(client_name)
    $("#lostModal .book-name").text("《" + name + "》")
    $("#lostModal").attr("data-id", id)

  $("#lost-cancel").click ->
    $("#lostModal").modal("hide")

  $("#lost-confirm").click ->
    id = $("#lostModal").attr("data-id")
    $.postJSON(
      '/staff/books/' + id + '/lost',
      { },
      (data) ->
        if data.success
          window.location.href = "/staff/books?code=" + DONE + "&profile=borrows"
      )

# search-btn press
  search = ->
    value = $("#search-input").val()
    location.href = "/staff/books?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("link-available")
      current_state = "available"
    bid = $(this).closest("tr").attr("data-id")
    link = $(this)
    console.log current_state
    $.postJSON(
      '/staff/books/' + bid + '/set_available',
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

  if window.profile == "borrows"
    $("#timeover").trigger("click")
