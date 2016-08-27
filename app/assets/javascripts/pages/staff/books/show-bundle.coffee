#= require wangEditor.min

$ ->

  editor = new wangEditor('edit-area')
  # editor.config.menus = $.map(wangEditor.config.menus, (item, key) ->
  #   if item == 'insertcode'
  #     return null
  #   if item == 'fullscreen'
  #     return null    
  #   item
  # )
  
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



# edit-btn pressdown
  $(".edit-btn").click ->
    $(".unedit-box").toggle()
    $(".shelve").toggle()
    $(".edit-box").toggle()
    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()
    $(".finish-btn").toggle()
    $(".edit-btn").toggle()

# finish-btn pressdown
  $(".finish-btn").click ->
    location.href = "/staff/books/show"