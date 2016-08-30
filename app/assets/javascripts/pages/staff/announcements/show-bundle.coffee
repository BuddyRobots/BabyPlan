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

# edit-btn press-down
  $(".edit-btn").click ->
    $(".edit-btn").toggle()
    $(".unshelve-btn").toggle()
    $(".end-btn").toggle()
    $(".declare-btn").toggle()
    $(".display-box").toggle()
    $(".edit-area").toggle()
    
    $("#input-caption").val($(".caption").text())
    $("#edit-box").html($(".display-content").html())

# end-btn press-down   未完成
  $(".end-btn").click ->
    location.href = "/staff/announcements/show"
    $(".unshelve-btn").toggle()
    $(".declare-btn").toggle()






