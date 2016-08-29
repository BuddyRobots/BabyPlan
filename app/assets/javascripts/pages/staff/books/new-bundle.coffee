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
          if data.code == BOOOK_EXIST
            $.page_notification("该书号图书已经存在")
      )
