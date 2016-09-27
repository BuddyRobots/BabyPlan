#= require wangEditor.min

$ ->
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

# end-btn press-down
  $(".end-btn").click ->
    title = $("#input-caption").val().trim()
    console.log title
    if title == ""
      $.page_notification "请输入标题"
      return
    content = editor.$txt.html()
    if content == ""
      $.page_notification "请输入公告内容"
      return
    is_published = $("#publish-cb").is(":checked")
    $.postJSON(
      '/staff/announcements',
      {
        announcement: 
          {
            title: title
            content: content
            is_published: is_published
          }
      },
      (data) ->
        console.log data
        if data.success != true
          $.page_notification "服务器出错，请稍后重试"
          return
        src = $(".photo")[0].src
        if src == "/assets/web/photo.png"
          window.location.href = "/staff/announcements/" + data.announcement_id
        else
          $("#upload-photo-form")[0].action = "/staff/announcements/" + data.announcement_id + "/upload_photo"
          $("#upload-photo-form").submit()
      )

#img upload
  $("#upload-photo").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    photo = $(".photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])