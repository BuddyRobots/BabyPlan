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

    $("#unshelve-btn").attr("disabled", true)
    $("#name-input").val($("#name-span").text())
    $("#type-input").val($("#type-span").text())
    $("#stock-input").val(window.stock)
    $("#isbn-input").val($("#isbn-span").text())
    $("#author-input").val($("#author-span").text())
    $("#translator-input").val($("#translator-span").text())
    $("#illustrator-input").val($("#illustrator-span").text())

    desc = $("#editor-content").html()
    console.log desc
    editor.$txt.html(desc)

  # finish-btn pressdown
  $(".finish-btn").click ->
    name = $("#name-input").val()
    type = $("#type-input").val()
    stock = $("#stock-input").val()
    isbn = $("#isbn-input").val()
    author = $("#author-input").val()
    translator = $("#translator-input").val()
    illustrator = $("#illustrator-input").val()
    desc = editor.$txt.html()

    $.putJSON(
      '/staff/books/' + window.bid,
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
        }
      },
      (data) ->
        if data.success
          $.page_notification("图书信息更新成功")
          $(".unedit-box").toggle()
          $(".shelve").toggle()
          $(".edit-box").toggle()
          $(".introduce-details").toggle()
          $(".wangedit-area").toggle()
          $(".finish-btn").toggle()
          $(".edit-btn").toggle() 

          $("#unshelve-btn").attr("disabled", false)

          $("#name-span").text(name)
          $("#type-span").text(type)
          $("#stock-span").text(stock + "本")
          $("#isbn-span").text(isbn)
          $("#author-span").text(author)
          $("#translator-span").text(translator)
          $("#illustrator-span").text(illustrator)

          $("#editor-content").html(desc)
          window.stock = stock
          $(".introduce-details").text("")
          $(".introduce-details").append(desc)
        else
          $.page_notification("服务器出错")
      )

  $("#unshelve-btn").click ->
    current_state = "unavailable"
    if $(this).hasClass("available")
      current_state = "available"
    btn = $(this)
    $.postJSON(
      '/staff/books/' + window.bid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        if data.success
          $.page_notification("操作完成")
          console.log btn.find("img").attr("src")
          if current_state == "available"
            btn.removeClass("available")
            btn.addClass("unavailable")
            btn.find("span").text("上架")
            btn.find("img").attr("src", "/assets/managecenter/shelve.png")
            $("#available-status").text("已下架")
          else
            btn.addClass("available")
            btn.removeClass("unavailable")
            btn.find("span").text("下架")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
            $("#available-status").text("在架上")
      )

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
