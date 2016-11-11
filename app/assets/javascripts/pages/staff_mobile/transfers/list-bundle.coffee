$ ->
  $("li").click ->
    $(this).siblings().removeClass("active")

  $(".out-li").click ->
    $(".out-list").show()
    $(".in-list").show()

  $(".in-li").click ->
    $(".in-list").show()
    $(".out-list").show()
