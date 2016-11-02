$ ->
    $("dd").click ->
    $("a").removeClass("select")
  $(document).on 'click', '.content', ->
    bid = $(this).attr("data-id")
    location.href = "/user_mobile/books/" + bid + "?back=books"
