
$ ->
  $(".fingure").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    if event.target.files[0] == undefined
      return
    photo = $("#figure-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])

  $("#upload-photo").mouseover (e) ->
    $(".fingure").show()
  $(".fingure").mouseout (e) ->
    $(".fingure").hide()

  $("#finish").click ->
    console.log "AAAAAAAAAAAA"
    name = $("#user_name").val()
    console.log "BBBBBBBBBBBBBBBB"
    console.log(name)
    if name == ""
      $.page_notification("请输入姓名", 1000)
      return
    $("#upload-photo-form").submit()

