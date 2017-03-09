$ ->
  $.each(
    ["feeds", "announcements", "courses", "books"],
    (index, type) ->
      $("#" + type + "-link").click ->
      	if window.current_user_id == ""
          location.href = "/user_mobile/sessions/" + type
      	else
        	location.href = "/user_mobile/" + type + "?keyword=" + $("#input-box").val()
  )

  if parseInt(window.code) == DONE
    $.mobile_page_notification("操作完成", 3000)
