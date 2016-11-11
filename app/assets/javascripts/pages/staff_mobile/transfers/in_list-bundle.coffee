$ ->
  $(".transfer-item").click ->
    location.href = "/staff_mobile/transfers/" + $(this).attr("data-id")