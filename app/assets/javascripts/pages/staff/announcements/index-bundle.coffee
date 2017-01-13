$ ->

  $("#announce-add").click ->
    location.href = "/staff/announcements/new"

  search = ->
    value = $("#search-input").val()
    location.href = "/staff/announcements?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()
