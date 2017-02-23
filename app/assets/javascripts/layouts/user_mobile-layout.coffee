$ ->
  viewHeight = window.innerHeight     
  $("input").focus( ->
    $(".wrapper").css("height", viewHeight)
  ).blur(->
    $(".wrapper").css("height", "100%")
  )
	document.documentElement.style.fontSize = document.documentElement.clientWidth / 7.2 + 'px'
#   $.each(
#     ["feeds", "announcements", "courses", "books"],
#     (index, type) ->
#       $("#" + type + "-link").click ->
#         location.href = "/user_mobile/" + type + "?keyword=" + $("#input-box").val()
#   )

#   if parseInt(window.code) == DONE
#     $.mobile_page_notification("操作完成", 3000)
