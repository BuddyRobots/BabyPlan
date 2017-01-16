#= require wangEditor.min

$ ->
  has_photo = false
  # wangEditor
  editor = new wangEditor('edit-box')
  editor.config.menus = [
        'head',
        'img'
     ]
  editor.config.uploadImgUrl = '/materials'
  editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }
  editor.config.hideLinkImg = true
  editor.create()

  # unshelve-btn press-down
  $(".operation").click ->
    current_state = "unpublished"
    if $(this).hasClass("delete-normal")
      current_state = "published"
    btn = $(this)
    $.postJSON(
      '/staff/announcements/' + window.aid + '/set_publish',
      {
        publish: current_state == "unpublished"
      },
      (data) ->
        if data.success
          $.page_notification("操作完成")
          if current_state == "published"
            btn.removeClass("delete-normal")
            btn.addClass("new-normal")
            btn.text("公布")
          else
            btn.addClass("delete-normal")
            btn.removeClass("new-normal")
            btn.text("不公布")

      )

  # edit-btn press-down
  $("#edit-btn").click ->
    $("#edit-btn").toggle()
    $("#finish-btn").toggle()
    $(".display-box").toggle()
    $(".edit-area").toggle()
    $("#input-caption").val($("#show-caption").text())
    $("#edit-box").html($(".display-content").html())

  $("#finish-btn").click ->
    title = $("#input-caption").val()
    content = editor.$txt.html()

    if title == ""
      $.page_notification "请输入标题"
      return
    if content.replace(/(<([^>]+)>)/ig, "").trim() == ""
      $.page_notification "请输入公告内容"
      return

    $.putJSON(
      '/staff/announcements/' + window.aid,
      {
        announcement: {
          title: title
          content: content
        }
      },
      (data) ->
        console.log data
        if data.success != true
          $.page_notification "服务器出错，请稍后重试"
          return
        if has_photo == false
          window.location.href = "/staff/announcements/" + data.announcement_id
        else
          $("#upload-photo-form")[0].action = "/staff/announcements/" + data.announcement_id + "/upload_photo"
          $("#upload-photo-form").submit()
    )


#img upload
  $("#upload-photo").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_photo = true
    photo = $(".edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])