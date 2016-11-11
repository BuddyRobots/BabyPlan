
$ ->

	$("#review").click ->
    $(".mask").show()

  $(".text-div").click ->
    return false

  $(".mask").click ->
    $(".mask").hide()
