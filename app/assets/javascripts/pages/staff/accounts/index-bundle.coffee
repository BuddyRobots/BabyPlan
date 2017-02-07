
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

  $(".change_status").click ->
    if $(this).hasClass("available")
      status = "close"
      lock = true
    if $(this).hasClass("unavailable")
      status = "open"
      lock = false
    window.sid = $(this).closest("tr").attr("data-id")
    t_cell = $(this)
    $.postJSON(
      '/staff/accounts/' + window.sid + '/change_status',
      {
        status: status
        lock: lock
      },
      (data) ->
        if data.success
          $.page_notification("操作完成", 1000)
          if status == "open"
            t_cell.addClass("available font-color-brown")
            t_cell.removeClass("unavailable font-color-green")
            t_cell.text("关闭")
            t_cell.closest("tr").find(".status").text("正常")
          else
            t_cell.addClass("unavailable font-color-green")
            t_cell.removeClass("available font-color-brown")
            t_cell.text("开通")
            t_cell.closest("tr").find(".status").text("关闭")
    )

