$ ->
  $(document).on 'click', '.content', ->
    bid = $(this).attr("data-id")
    location.href = "/user_mobile/books/" + bid + "?back=books"

  $("#search-btn").click ->
    lower = $(".select").attr("data-lower")
    upper = $(".select").attr("data-upper")
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/books?keyword=" + keyword + "&lower=" + lower + "&upper=" + upper

  $(".dl-div a").each ->
    lower = $(this).attr("data-lower")
    upper = $(this).attr("data-upper")
    if lower == window.lower && upper == window.upper
      $(this).addClass("select")

  $(".dl-div a").click ->
    lower = $(this).attr("data-lower")
    upper = $(this).attr("data-upper")
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/books?keyword=" + keyword + "&lower=" + lower + "&upper=" + upper
