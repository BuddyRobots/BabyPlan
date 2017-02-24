#= require "./_templates/course_item"
$ ->
	$("#operation").click ->
		$("#menuModal").modal("show")

	$("#exit").click ->
    $("#confirmModal").modal("show")

  $("#logoff").click ->
    location.href = "/user_mobile/sessions/signout"

  $("#profile").click ->
    location.href = "/user_mobile/settings/profile"

  $("#message").click ->
    location.href = "/user_mobile/settings/message"

  $("#favorite").click ->
    location.href = "/user_mobile/settings/favorite"

  $("#course").click ->
    location.href = "/user_mobile/settings/course"

  $("#announcement").click ->
    location.href = "/user_mobile/announcements"
    
  $(".content-div").on "click", ".item", ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + cid + "?back=list"

    
  page = 2

  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load-gif").show()
    $.getJSON "/user_mobile/courses/more?page=" + page, (data) ->
      $(".load-gif").hide()
      render_more.show()
      if data.success
        console.log data.more
        if (data.more.length == 0)
          $.mobile_page_notification("没有了")
        else
          page = page + 1
          $.each(
            data.more,
            (index, course_item_data) ->
              course_item = $(HandlebarsTemplates["course_item"](course_item_data))
              $(".render-more").before(course_item)
          )
      else
        $.mobile_page_notification "服务器出错"

  # $('.content-area').on 'click', '.content', ->
  #   path = $(this).attr("data-path")
  #   location.href = "/user_mobile/" + path
