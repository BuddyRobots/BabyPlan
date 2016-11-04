$ ->
  $(document).on 'click', '.content', ->
    cid = $(this).attr("data-id")
    alert(cid)
    location.href = "/user_mobile/courses/" + cid + "?back=courses"
