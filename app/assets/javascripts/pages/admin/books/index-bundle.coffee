$ ->

  if window.profile == "transfers"
    $('.nav-tabs a[href="#tab2"]').tab('show')
    $("#search-input-book").hide()
    $("#search-input-transfer").show()
  else
    $("#search-input-book").show()
    $("#search-input-transfer").hide()

  $('#books-tab').on 'shown.bs.tab', (e) ->
    window.profile = "books"
    $("#search-input-book").show()
    $("#search-input-transfer").hide()

  $('#transfers-tab').on 'shown.bs.tab', (e) ->
    window.profile = "transfers"
    $("#search-input-book").hide()
    $("#search-input-transfer").show()

  search = ->
    book_keyword = $("#search-input-book").val()
    transfer_keyword = $("#search-input-transfer").val()
    window.location.href = "/admin/books?profile=" + window.profile + "&book_keyword=" + book_keyword + "&transfer_keyword=" + transfer_keyword + "&page=1"

  $("#search-btn").click ->
    search()

  
  $("#search-input-book").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $("#search-input-transfer").keydown (event) ->
    code = event.which
    if code == 13
      search()

  check_add_input = ->
    if $("#borrow-num").val().trim() == "" ||
        $("#borrow-time").val().trim() == ""
      $("#confirm").addClass("button-disabled")
      $("#confirm").removeClass("button-enabled")
    else
      $("#confirm").removeClass("button-disabled")
      $("#confirm").addClass("button-enabled")

  $("#borrow-num").keyup ->
    check_add_input()
  $("#borrow-time").keyup ->
    check_add_input()

