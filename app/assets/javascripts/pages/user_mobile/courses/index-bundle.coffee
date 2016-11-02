$ ->
  $(document).on 'click', '.content', ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + cid + "?back=courses"
