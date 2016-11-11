
$ ->
	$("#review").click ->
    $(".mask").show()
    $("#review").hide()

  $(".empty-div").click ->
    $(".mask").hide()
    $("#review").show()