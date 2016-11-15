$ ->
  $(".details").click ->
    bid = $(this).attr("data-id")
    window.location.href = "/user_mobile/books/" + bid
