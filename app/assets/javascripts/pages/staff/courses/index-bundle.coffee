
$ ->
  # search-btn press
  search = ->
    value = $("#appendedInputButton").val()
    location.href = "/staff/courses?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".confirm").click ->
    location.href = "/staff/courses/new"

  $(".cancel").click ->
    $("#course-addModal").modal("hide")

  $(".details").click ->
    location.href = "/staff/courses/show"