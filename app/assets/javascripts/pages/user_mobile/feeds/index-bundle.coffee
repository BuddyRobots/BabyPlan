$ ->
  $(document).on 'click', '.content', ->
    path = $(this).attr("data-path")
    location.href = "/user_mobile/" + path

  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/feeds?keyword=" + keyword