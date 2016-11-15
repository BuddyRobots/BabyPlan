
$ ->

  hide = true

  $("#review").click ->
    $(".mask").show()

  $(".text-div").click ->
    hide = false
    return true

  $(".mask").click ->
    if hide == true
      $(".mask").hide()
    hide = true
