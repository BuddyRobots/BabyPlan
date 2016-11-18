$ ->
  $(".details").click ->
    cid = $(this).attr("data-id")
    window.location.href = "/user_mobile/courses/" + cid + "?back=setting"
