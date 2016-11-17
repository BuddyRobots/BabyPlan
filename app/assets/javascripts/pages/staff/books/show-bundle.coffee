#= require wangEditor.min
#= require tag-it.min
$ ->

  if window.profile == "reviews"
    $('.nav-tabs a[href="#tab2"]').tab('show')

  if window.profile == "borrows"
    $('.nav-tabs a[href="#tab3"]').tab('show')

  has_cover = false
  has_back = false

  is_edit = false

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

  $('#type-tag').tagit
    fieldName: 'skills'
    availableTags: [
      'c++'
      'java'
      'php'
      'javascript'
      'ruby'
      'python'
      'c'
    ]
    autocomplete:
      delay: 0
      minLength: 2
    showAutocompleteOnFocus: false
    removeConfirmation: false
    caseSensitive: true
    allowDuplicates: false
    allowSpaces: false
    readOnly: false
    tagLimit: null
    singleField: false
    singleFieldDelimiter: ','
    singleFieldNode: null
    tabIndex: null
    placeholderText: null
    beforeTagAdded: (event, ui) ->
      return
    afterTagAdded: (event, ui) ->
      return
    beforeTagRemoved: (event, ui) ->
      return
    onTagExists: (event, ui) ->
      return
    onTagClicked: (event, ui) ->
      return
    onTagLimitExceeded: (event, ui) ->
      return


  # edit-btn pressdown
  $(".edit-btn").click ->
    $(".unedit-box").toggle()
    $(".shelve").toggle()
    $(".edit-box").toggle()
    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()
    $(".finish-btn").toggle()
    $(".edit-btn").toggle()
    $(".type-span-template").hide()
    is_edit = true

    $(".unshelve-btn").attr("disabled", true)
    $(".QRcode-btn").attr("disabled", true)
    $("#name-input").val($("#name-span").text())
    $("#type-input").val($("#type-span").text())
    $("#stock-input").val(window.stock)
    $("#age-lower-bound-input").val(window.age_lower_bound)
    $("#age-upper-bound-input").val(window.age_upper_bound)
    $("#isbn-input").val($("#isbn-span").text())
    $("#author-input").val($("#author-span").text())
    $("#translator-input").val($("#translator-span").text())
    $("#illustrator-input").val($("#illustrator-span").text())

    $(".type-span-ele").each ->
      $("#type-tag").tagit("createTag", $(this).text());

    desc = $("#editor-content").html()
    console.log desc
    editor.$txt.html(desc)

    # 我的方法
    #   desc = $(".introduce-details").html()
    #   console.log desc
    #   editor.$txt.html(desc)

# button hide
  $("#book-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $(".unshelve-btn").show()
    $(".QRcode-btn").show()

  $("#user-review").click ->
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()
    $(".finish-btn").hide()
    $(".QRcode-btn").hide()

  $("#borrow-message").click ->
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()
    $(".finish-btn").hide()  
    $(".QRcode-btn").hide()  

  # finish-btn pressdown
  $(".finish-btn").click ->
    name = $("#name-input").val()
    type = $("#type-input").val()
    stock = $("#stock-input").val()
    age_lower_bound = $("#age-lower-bound-input").val()
    age_upper_bound = $("#age-upper-bound-input").val()
    tags = $("#type-tag").tagit("assignedTags")
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
          age_lower_bound: age_lower_bound
          age_upper_bound: age_upper_bound
          tags: tags
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
          $(".type-span-template").hide()

          $(".unshelve-btn").attr("disabled", false)
          $("#QRcode-btn").attr("disabled", false)
          $("#name-span").text(name)
          $("#type-span").text(type)
          $("#stock-span").text(stock + "本")
          $("#age-lower-bound-span").text(age_lower_bound + "岁")
          $("#age-upper-bound-span").text(age_upper_bound + "岁")
          $("#isbn-span").text(isbn)
          $("#author-span").text(author)
          $("#translator-span").text(translator)
          $("#illustrator-span").text(illustrator)

          $("#editor-content").html(desc)

          # 我的方法
          # $(".introduce-details").html(desc)

          window.stock = stock
          window.age_lower_bound = age_lower_bound
          window.age_upper_bound = age_upper_bound
          $(".introduce-details").text("")
          $(".introduce-details").append(desc)

          $("#tag-form .type-span-ele").remove()
          $.each(
            tags,
            (index, tag) ->
              ele = $(".type-span-template").clone().removeClass("hide").removeClass("type-span-template").addClass("type-span-ele")
              ele.text(tag)
              ele.appendTo($("#tag-form")).show()
          )

          if has_cover || has_back
            $("#has_cover").val(has_cover)
            $("#has_back").val(has_back)
            $("#upload-photo-form").submit()

        else
          $.page_notification("服务器出错")
      )

  $(".unshelve-btn").click ->
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

  $(".QRcode-btn").click ->
    location.href = "/staff/books/" + window.bid + "/download_qrcode"

# img upload
  $("#upload-cover").click ->
    if is_edit
      $("#cover_file").trigger("click")
  $("#upload-back").click ->
    if is_edit
      $("#back_file").trigger("click")

  $("#cover_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_cover = true
    photo = $("#cover-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])
  $("#back_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_back = true
    photo = $("#back-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])




