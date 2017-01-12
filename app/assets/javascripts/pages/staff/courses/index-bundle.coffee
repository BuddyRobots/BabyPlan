
$ ->
  if window.profile == "template"
    $('.nav-tabs a[href="#tab2"]').tab('show')
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

  $("#new-template").click ->
    location.href = "/staff/courses/new"

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("font-color-red")
      current_state = "available"
    cid = $(this).closest("tr").attr("data-id")
    link = $(this)
    console.log current_state
    $.postJSON(
      '/staff/courses/' + cid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification("操作完成")
          if current_state == "available"
            link.removeClass("font-color-red")
            link.addClass("font-color-green")
            link.text("上架")
          else
            link.addClass("font-color-red")
            link.removeClass("font-color-green")
            link.text("下架")
      )
    return false


  # $("#confirm-btn").click ->
  #   course_name = $("#coursename").val()
  #   $.getJSON "/staff/courses/get_id_by_name?course_name=" + course_name, (data) ->
  #     if data.success
  #       location.href = "/staff/courses/new?course_id=" + data.id
  #     else
  #       $.page_notification "课程不存在"

  # $("#cancel").click ->
  #   $("#course-addModal").modal("hide")
  # $("#coursename").autocomplete(
  #   source: "/courses"
  #   appendTo: "#course-addModal"
  # )