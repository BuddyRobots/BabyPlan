$ ->
  search = ->
    value = $("#search-input").val()
    window.location.href = "/admin/books?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  
  $("#search-input").keydown (event) ->
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

