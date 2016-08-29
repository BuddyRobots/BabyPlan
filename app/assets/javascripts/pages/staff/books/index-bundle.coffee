

$ ->
	# $("#signup-signin").click ->
	# location.href = "/staff/books/" + data.book_id


  $(".bookadd-btn").click ->
    location.href = "/staff/books/new"

# search-btn press
  search = ->
    value = $("#appendedInputButton").val()
    location.href = "/staff/books?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("available")
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
            link.removeClass("available")
            link.addClass("unavailable")
            link.text("上架")
            link.closest("tr").removeClass("available")
            link.closest("tr").addClass("unavailable")
          else
            link.addClass("available")
            link.removeClass("unavailable")
            link.text("下架")
            link.closest("tr").addClass("available")
            link.closest("tr").removeClass("unavailable")
      )
    return false

  $(".book-record").click ->
    $(".book-record").removeClass("clicked")
    $(this).addClass("clicked")

