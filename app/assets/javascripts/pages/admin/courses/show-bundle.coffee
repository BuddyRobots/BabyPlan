#= require wangEditor.min

$ ->

# wangEditor
  editor = new wangEditor('edit-area')

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

  $("#course-area").click ->
    $(".btn").hide()

  $("#course-message").click ->
    $(".btn").show()

  $(".edit-btn").click ->
    $(".unedit-box").hide()
    $(".edit-box").show()
    $("#classname-input").val($("#classname-span").text())
    $("#classspeaker-input").val($("#classspeaker-span").text())
    $("#charge-input").val($("#charge-span").text())

    $("#edit-area").html($(".introduce-details").html())

    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()
 
