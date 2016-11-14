$ ->
  if window.profile == "in"
    $('.nav-tabs a[href="#tab2"]').tab('show')


  search = ->
    keyword = $("#search-input").val()
    window.location.href = "/staff/transfers?profile=" + window.profile + "&keyword=" + keyword + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()