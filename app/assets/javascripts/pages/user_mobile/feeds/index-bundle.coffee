$ ->
  # $(document).on 'click', '.content', ->
  #   aid = $(this).attr("data-id")
  #   location.href = "/user_mobile/announcements/" + aid + "?back=announcements"

  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/feeds?keyword=" + keyword