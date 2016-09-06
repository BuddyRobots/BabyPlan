$ ->
  search = ->
    value = $("#appendedInputButton").val()
    window.location.href = "/admin/centers?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()