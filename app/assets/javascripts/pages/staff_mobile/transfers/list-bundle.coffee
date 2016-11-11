$ ->
  $("li").click ->
    $(this).siblings().removeClass("active")

  $(".out-li").click ->
    $(".out-list").show()
    $(".in-list").hide()

  $(".in-li").click ->
    $(".in-list").show()
    $(".out-list").hide()

  $(".item-div").click ->
    location.href = "/staff_mobile/transfers/" + $(this).attr("data-id")
