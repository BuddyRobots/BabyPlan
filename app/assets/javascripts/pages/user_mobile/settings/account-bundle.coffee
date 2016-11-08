$ ->
	$("#upload-photo").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_photo = true
    photo = $(".avatar-icon")[0]
    photo.src = URL.createObjectURL(event.target.files[0])