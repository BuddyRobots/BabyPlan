#= require wangEditor.min

$ ->
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

  $(".end-btn").click ->
    title = $("#input-caption").val().trim()
    console.log title
    if title == ""
      $.page_notification "请输入标题"
    content = editor.$txt.html()
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
        if data.success
          window.location.href = "/staff/announcements/" + data.announcement_id
        else
          $.page_notification "服务器出错，请稍后重试"
    )
