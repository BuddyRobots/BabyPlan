$ ->
  $(document).on 'click', '.content', ->
    bid = $(this).attr("data-id")
    location.href = "/user_mobile/books/" + bid + "?back=books"

  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/books?keyword=" + keyword

