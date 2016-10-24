

$ ->
  $("li").click ->
    $(this).siblings().removeClass("active")
