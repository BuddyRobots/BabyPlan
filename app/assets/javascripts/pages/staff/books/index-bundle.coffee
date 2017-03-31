#= require wangEditor.min

$ ->
	# $("#signup-signin").click ->
	# location.href = "/staff/books/" + data.book_id

  $(".download-code").click ->
    location.href = "/staff/books/code_list"

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


  $(".isbn-search-btn").click ->
    isbn = $(".isbn-input").val()
    $.postJSON(
      '/staff/books/isbn_search',
      {
        isbn: isbn
        },
      (data) ->
        console.log(data)
        if !data.success
          if data.code == BOOK_NOT_EXIST
            $(".isbn-notice").text("未找到对应图书").css({color:"#d70c19", visibility:"visible"})
          if data.code == BOOK_IN_CENTER
            $(".isbn-notice").text("本中心藏有该书，请修改藏书数量").css({color:"#d70c19", visibility:"visible"})
        else
          $(".isbn-notice").text("书名:" + data.name).css({color:"#10c078", visibility:"visible"})
    )

  $(".close").click ->
    $(".isbn-input").val("")
    $(".isbn-input-num").val("")
    $(".isbn-notice").css("visibility", "hidden")
    $(".isbn-confirm-btn").addClass("button-disabled")
    $(".isbn-confirm-btn").removeClass("button-enabled")

  $('#isbnModal').on 'hidden.bs.modal', ->
    $(".isbn-input").val("")
    $(".isbn-input-num").val("")
    $(".isbn-notice").css("visibility", "hidden")
    $(".isbn-confirm-btn").addClass("button-disabled")
    $(".isbn-confirm-btn").removeClass("button-enabled")

  check_input = ->
    if $(".isbn-input").val().trim() == "" || $(".isbn-input-num").val().trim() == "" || $(".isbn-notice").text() == "未找到对应图书"
      $(".isbn-confirm-btn").addClass("button-disabled")
      $(".isbn-confirm-btn").removeClass("button-enabled")
    else
      $(".isbn-confirm-btn").addClass("button-enabled")
      $(".isbn-confirm-btn").removeClass("button-disabled")

  $(".isbn-input").keyup ->
    check_input()
    $(".isbn-notice").css("visibility", "hidden")
  $(".isbn-input-num").keyup ->
    check_input()

  $(".isbn-confirm-btn").click ->
    isbn = $(".isbn-input").val()
    num = $(".isbn-input-num").val()
    available = true
    $.postJSON(
      '/staff/books/isbn_add_book',
      {
        isbn: isbn
        num: num
        available: available
      },
      (data) ->
        if data.success
          location.href = "/staff/books"
      )


