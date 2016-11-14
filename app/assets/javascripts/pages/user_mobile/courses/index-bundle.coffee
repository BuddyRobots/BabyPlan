$ ->
  $('.content').on 'click', ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + cid + "?back=courses"


  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/courses?keyword=" + keyword
