$ ->
  $(document).on 'click', '.content', ->
    aid = $(this).attr("data-id")
    location.href = "/user_mobile/announcements/" + aid + "?back=announcements"
