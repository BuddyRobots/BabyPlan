$ ->
    $("dd").click ->
    $("a").removeClass("select")
  $(document).on 'click', '.content', ->
    bid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + bid + "?back=books"
