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


  # edit-btn press-down
  $(".edit-btn").click ->
    $(".edit-btn").toggle()
    $(".end-btn").toggle()
    $(".display-box").toggle()
    $(".edit-area").toggle()
    
    $("#input-caption").val($(".title").text())
    $("#edit-box").html($(".display-content").html())

  $(".end-btn").click ->

    title = $("#input-caption").val()
    content = editor.$txt.html()

    if title == ""
      $.page_notification "请输入标题"
      return
    if content.replace(/(<([^>]+)>)/ig, "").trim() == ""
      $.page_notification "请输入须知内容"
      return

    $.postJSON(
      '/admin/agreements',
      {
        title: title
        content: content
      },
      (data) ->
        console.log data
        if data.success != true
          $.page_notification "服务器出错，请稍后重试"
          return
        else
          location.href = "/admin/agreements"
    )