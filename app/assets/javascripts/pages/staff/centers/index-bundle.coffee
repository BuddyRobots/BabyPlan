$ ->

  text = $("#search-input").val()
  if text == ""
    $("#search-btn").addClass("search")
    $("#search-btn").removeClass("delete")
  else
    $("#search-btn").addClass("delete")
    $("#search-btn").removeClass("search")

  search = ->
    value = $("#search-input").val()
    location.href = "/staff/centers?keyword=" + value + "&page=1"

  back = ->
    location.href = "/staff/centers"

  $("#search-btn").click ->
    if $("#search-btn").hasClass("search")
      search()
      $("#search-btn").addClass("delete")
      $("#search-btn").removeClass("search")
    else
      back()
      $("#search-btn").addClass("search")
      $("#search-btn").removeClass("delete")


  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()
      $("#search-btn").addClass("delete")
      $("#search-btn").removeClass("search")
    else
      $("#search-btn").addClass("search")
      $("#search-btn").removeClass("delete")

  $("#add-center").click ->
    location.href = "/staff/centers/new"

