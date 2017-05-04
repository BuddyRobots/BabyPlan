#= require wangEditor.min
#= require tag-it.min
$ ->

  # if window.user == "User"
  #   $(".btn").attr("disabled", true)
    
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
    $(".upload-photo").toggle()
    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()
    $(".finish-btn").toggle()
    $(".edit-btn").toggle()
    $(".type-span-template").hide()
    is_edit = true

    $("#name-input").val($("#name-span").text())
    $("#type-input").val($("#type-span").text())
    $("#age-lower-bound-input").val(window.age_lower_bound)
    $("#age-upper-bound-input").val(window.age_upper_bound)
    $("#isbn-input").val($("#isbn-span").text())
    $("#author-input").val($("#author-span").text())
    $("#publisher-input").val($("#publisher-span").text())
    $("#translator-input").val($("#translator-span").text())
    $("#illustrator-input").val($("#illustrator-span").text())

    $(".type-span-ele").each ->
      $("#type-tag").tagit("createTag", $(this).text());

    desc = $("#editor-content").html()
    console.log desc
    editor.$txt.html(desc)

  # finish-btn pressdown
  $(".finish-btn").click ->
    name = $("#name-input").val()
    type = $("#type-input").val()
    age_lower_bound = $("#age-lower-bound-input").val()
    age_upper_bound = $("#age-upper-bound-input").val()
    tags = $("#type-tag").tagit("assignedTags")
    isbn = $("#isbn-input").val()
    author = $("#author-input").val()
    publisher = $("#publisher-input").val()
    translator = $("#translator-input").val()
    illustrator = $("#illustrator-input").val()
    desc = editor.$txt.html()
    $(".upload-photo").toggle()

    if name == "" || isbn == "" || desc == ""
      $.page_notification("请补全信息")
      return

    if !$.isNumeric(age_lower_bound) || !$.isNumeric(age_upper_bound) || parseInt(age_lower_bound) < 0 || parseInt(age_upper_bound) < 0 || parseInt(age_lower_bound) > parseInt(age_upper_bound)
      $.page_notification("请输入合法的年龄限制")
      return

    $.putJSON(
      '/operator/books/' + window.bid,
      {
        book: {
          name: name
          type: type
          isbn: isbn
          author: author
          publisher: publisher
          translator: translator
          illustrator: illustrator
          age_lower_bound: parseInt(age_lower_bound)
          age_upper_bound: parseInt(age_upper_bound)
          tags: tags
          desc: desc
        }
      },
      (data) ->
        if data.success
          $.page_notification("图书信息更新成功")
          $(".unedit-box").toggle()
          $(".edit-box").toggle()
          $(".introduce-details").toggle()
          $(".wangedit-area").toggle()
          $(".finish-btn").toggle()
          $(".edit-btn").toggle() 
          $(".type-span-template").hide()
          $("#name-span").text(name)
          $("#type-span").text(type)
          if age_lower_bound == "" || age_lower_bound == undefined
            $("#age-lower-bound-span").text("未填写")
          else
            $("#age-lower-bound-span").text(age_lower_bound + "岁")
          if age_upper_bound == "" || age_upper_bound == undefined
            $("#age-upper-bound-span").text("未填写")
          else
            $("#age-upper-bound-span").text(age_upper_bound + "岁")
          $("#isbn-span").text(isbn)
          $("#author-span").text(author)
          $("#publisher-span").text(publisher)
          $("#translator-span").text(translator)
          $("#illustrator-span").text(illustrator)

          $("#editor-content").html(desc)

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
          if data.code == BOOK_NOT_EXIST
            $.page_notification("该书不存在", 1000)
          if data.code == BOOK_EXIST
            $.page_notification("isbn号与其它书籍重复", 1000)
          else
            $.page_notification("服务器出错")
      )

  $(".delete-btn").click ->
    $("#deleteModal").modal("show")

  $("#cancel").click ->
    $("#deleteModal").modal("hide")

  $("#confirm-delete").click ->
    $("#deleteModal").modal("hide")
    $.deleteJSON(
      '/operator/books/' + window.bid,
      {},
      (data) ->
        if data.success
          location.href = "/operator/books"
        else
          if data.code == BOOK_EXIST
            $.page_notification("系统中存在该绘本的应用，不能删除", 1000)
      )

# img upload
  $("#upload-cover-div").click ->
    if is_edit
      $("#cover_file").trigger("click")
  $("#upload-back-div").click ->
    if is_edit
      $("#back_file").trigger("click")

  $("#cover_file").change (event) ->
    $("#cover-photo").attr("src", "")
    if event.target.files[0] == undefined
      return
    has_cover = true
    photo = $("#cover-edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])
  $("#back_file").change (event) ->
    $("#back-photo").attr("src", "")
    if event.target.files[0] == undefined
      return
    has_back = true
    photo = $("#back-edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])

