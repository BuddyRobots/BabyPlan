#= require wangEditor.min

$ ->

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


  $(".end-btn").click ->
    name = $("#book-name").val().trim()
    type = $("#book-type").val().trim()
    stock = $("#book-stock").val().trim()
    isbn = $("#book-isbn").val().trim()
    author = $("#book-author").val().trim()
    translator = $("#book-translator").val().trim()
    illustrator = $("#book-illustrator").val().trim()
    available = $("#available").is(":checked")
    
    desc = editor.$txt.html()
    if name == "" || stock == "" || isbn == "" || desc == ""
      $.page_notification("请补全信息")
      return
    $.postJSON(
      '/staff/books',
      {
        book: {
          name: name
          type: type
          stock: stock
          isbn: isbn
          author: author
          translator: translator
          illustrator: illustrator
          desc: desc
          available: available
        }
      },
      (data) ->
        console.log data
        if data.success
          location.href = "/staff/books/" + data.book_id
        else
          if data.code == BOOK_EXIST
            $.page_notification("该书号图书已经存在")
      )

# img upload
  $("#upload-cover").click ->
    $("#uploadCoverModal").modal("show")

  coverIntervalFunc = ->
    $('#cover-name').html $('#cover_file').val();

  $("#browser-cover-click").click ->
    $("#cover_file").click()
    setInterval(coverIntervalFunc, 1)

  $("#upload-back").click ->
    $("#uploadBackModal").modal("show")

  backIntervalFunc = ->
    $('#back-name').html $('#back_file').val();

  $("#browser-back-click").click ->
    $("#back_file").click()
    setInterval(backIntervalFunc, 1)
