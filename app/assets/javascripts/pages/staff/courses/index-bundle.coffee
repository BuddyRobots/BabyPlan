
$ ->
  # search-btn press
  search = ->
    value = $("#search-input").val()
    location.href = "/staff/courses?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $("#confirm-btn").click ->
    course_name = $("#coursename").val()
    $.getJSON "/staff/courses/get_id_by_name?course_name=" + course_name, (data) ->
      if data.success
        location.href = "/staff/courses/new?course_id=" + data.id
      else
        $.page_notification "课程不存在"

  $(".cancel").click ->
    $("#course-addModal").modal("hide")

  $(".details").click ->
    location.href = "/staff/courses/show"


  $("#coursename").autocomplete(
    source: "/courses"
    appendTo: "#course-addModal"
  )