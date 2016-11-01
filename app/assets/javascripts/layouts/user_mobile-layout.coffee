$ ->
  $.each(
    ["feeds", "announcements", "courses", "books"],
    (index, type) ->
      $("#" + type + "-link").click ->
        location.href = "/user_mobile/" + type + "?keyword=" + $("#input-box").val()
  )