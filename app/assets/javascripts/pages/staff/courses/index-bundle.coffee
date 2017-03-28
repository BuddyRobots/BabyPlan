
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
      
  $(".details").click ->
    location.href = "/staff/courses/show"

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("link-available")
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
          location.href = "/staff/courses"
          # if current_state == "available"
          #   link.removeClass("link-available")
          #   link.addClass("link-unavailable")
          #   link.text("上架")
          #   link.closest("tr").removeClass("available")
          #   link.closest("tr").addClass("unavailable")
          # else
          #   link.addClass("link-available")
          #   link.removeClass("link-unavailable")
          #   link.text("下架")
          #   link.closest("tr").addClass("available")
          #   link.closest("tr").removeClass("unavailable")
      )
    return false


  $(".add-btn").click ->
    location.href = "/staff/courses/new"

  $(".view-btn").click ->
    location.href = "/staff/courses/coursetable"


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