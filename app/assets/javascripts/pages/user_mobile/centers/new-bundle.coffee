$ ->
  $(".desc-add-div").click ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/centers/" + cid