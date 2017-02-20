$ ->

  $(".item").click ->
    url = $(this).attr("data-url")
    window.location.href = url + "?back=favorite"
