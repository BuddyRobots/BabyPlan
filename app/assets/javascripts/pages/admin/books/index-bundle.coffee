$ ->
  search = ->
    value = $("#appendedInputButton").val()
    window.location.href = "/admin/books?keyword=" + value

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()