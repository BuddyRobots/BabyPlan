
$ ->
  search = ->
    value = $("#appendedInputButton").val()
    location.href = "/admin/staffs?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()


  