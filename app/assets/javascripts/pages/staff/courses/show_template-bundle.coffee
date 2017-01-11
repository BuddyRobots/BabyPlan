$ ->

  $("#create-btn").click ->
    location.href = "/staff/courses/" + window.course_id + "/edit"
  $("#back").click ->
    location.href = "/staff/courses?profile=template"
  $("#series-course").click ->
    $("#delete-btn").hide()
    $("#create-btn").hide()
  $("#template-desc").click ->
    $("#delete-btn").show()
    $("#create-btn").show()
  $("#delete-btn").click ->
    $.deleteJSON(
      "/staff/courses/" + window.course_id,
      {},
      (data) ->
        console.log(data)
        if data.success
          location.href = "/staff/courses"
      )