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
    desc = editor.$txt.html()
    