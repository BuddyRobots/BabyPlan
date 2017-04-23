$ ->

  search = ->
    keyword = $("#search-input").val()
    window.location.href = "/operator/books?keyword=" + keyword + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".bookadd-btn").click ->
    location.href = "/operator/books/new"

  if window.user == "User"
    $(".bookadd-btn").attr("disabled", true)