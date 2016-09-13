
$ ->
  search = ->
    value = $("#search-input").val()
    location.href = "/admin/staffs?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()


  