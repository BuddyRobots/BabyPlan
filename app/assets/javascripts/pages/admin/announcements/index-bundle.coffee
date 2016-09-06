$ ->
  if window.profile == "local"
    $('.nav-tabs a[href="#tab2"]').tab('show')

  $(".add-btn").click ->
    location.href = "/admin/announcements/new"

  search = ->
    value = $("#appendedInputButton").val()
    location.href = "/admin/announcements?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()
