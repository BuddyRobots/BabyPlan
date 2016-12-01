#= require wangEditor.min
#= require tag-it.min
$ ->

  $(".close").click -> 
    $("#code-num").val("")
    $("#confirm").removeClass("button-enabled")
    $("#confirm").addClass("button-disabled")

  $(".return").click ->
    client_name = $(this).closest('tr').attr('data-clientname')
    name = $(this).closest('tr').attr('data-name')
    id = $(this).closest('tr').attr('data-id')
    $("#returnModal").modal("show")
    $("#returnModal .client-name").text(client_name)
    $("#returnModal .book-name").text("《" + name + "》")
    $("#returnModal").attr("data-id", id)

  $("#return-cancel").click ->
    $("#returnModal").modal("hide")

  $("#return-confirm").click ->
    id = $("#returnModal").attr("data-id")
    $.postJSON(
      '/staff/books/' + id + '/back',
      { },
      (data) ->
        if data.success
          window.location.href = "/staff/books/" + window.bid + "?code=" + DONE + "&profile=return"
      )

  $(".lost").click ->
    client_name = $(this).closest('tr').attr('data-clientname')
    name = $(this).closest('tr').attr('data-name')
    id = $(this).closest('tr').attr('data-id')
    $("#lostModal").modal("show")
    $("#lostModal .client-name").text(client_name)
    $("#lostModal .book-name").text("《" + name + "》")
    $("#lostModal").attr("data-id", id)

  $("#lost-cancel").click ->
    $("#lostModal").modal("hide")

  $("#lost-confirm").click ->
    id = $("#lostModal").attr("data-id")
    $.postJSON(
      '/staff/books/' + id + '/lost',
      { },
      (data) ->
        if data.success
          window.location.href = "/staff/books/" + window.bid + "?code=" + DONE + "&profile=return"
      )

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

  $("#return-book").click ->
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
    $(".upload-photo").toggle()

    if name == "" || stock == "" || isbn == "" || desc == ""
      $.page_notification("请补全信息")
      return

    if $.isNumeric(stock) == false || parseInt(stock) < 0
      $.page_notification("请输入合法的库存数量")
      return

    if !$.isNumeric(age_lower_bound) || !$.isNumeric(age_upper_bound) || parseInt(age_lower_bound) < 0 || parseInt(age_upper_bound) < 0 || parseInt(age_lower_bound) >= parseInt(age_lower_bound)
      $.page_notification("请输入合法的年龄限制")
      return

    $.putJSON(
      '/staff/books/' + window.bid,
      {
        book: {
          name: name
          type: type
          stock: parseInt(stock)
          isbn: isbn
          author: author
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
          $(".shelve").toggle()
          $(".edit-box").toggle()
          $(".introduce-details").toggle()
          $(".wangedit-area").toggle()
          $(".finish-btn").toggle()
          $(".edit-btn").toggle() 
          $(".type-span-template").hide()

          $(".unshelve-btn").attr("disabled", false)
          $(".QRcode-btn").attr("disabled", false)
          $("#name-span").text(name)
          $("#type-span").text(type)
          $("#stock-span").text(stock + "本")
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
            btn.find("img").attr("src", window.shelve_path)
            $("#available-status").text("已下架")
          else
            btn.addClass("available")
            btn.removeClass("unavailable")
            btn.find("span").text("下架")
            btn.find("img").attr("src", window.unshelve_path)
            $("#available-status").text("在架上")
      )

  check_code_input = ->
    if $("#code-num").val().trim() == ""
      $("#confirm").addClass("button-disabled")
      $("#confirm").removeClass("button-enabled")
    else
      $("#confirm").removeClass("button-disabled")
      $("#confirm").addClass("button-enabled")

  $("#code-num").keyup ->
    check_code_input()

  $(".QRcode-btn").click ->
    $("#QR-codeModal").modal("show")

  $("#confirm-qr-code").click ->
    num = $("#code-num").val()
    if $.isNumeric(num)
      num = parseInt(num)
      if num > 0
        location.href = "/staff/books/" + window.bid + "/download_qrcode?amount=" + num
        $("#QR-codeModal").modal("hide")
    else
      $.page_notification("请正确输入数量", 2000)

# img upload
  $("#upload-cover-div").click ->
    if is_edit
      $("#cover_file").trigger("click")
  $("#upload-back-div").click ->
    if is_edit
      $("#back_file").trigger("click")

  $("#cover_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_cover = true
    photo = $("#cover-edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])
  $("#back_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_back = true
    photo = $("#back-edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])


  if window.profile == "reviews"
    $("#user-review").trigger("click")

  if window.profile == "borrows"
    $("#borrow-message").trigger("click")

  if window.profile == "return"
    $("#return-book").trigger("click")

  $(document).on 'click', '.hide-review', ->
    rid = $(this).attr("data-id")
    hide_review(rid, $(this))

  $(document).on 'click', '.show-review', ->
    rid = $(this).attr("data-id")
    show_review(rid, $(this))

  $(".details").click ->
    span = $(this).find("span")
    row = $(this).closest("tr")
    status = row.next()
    status.toggle()
    if span.hasClass("triangle-down")
      span.removeClass("triangle-down").addClass("triangle-up")
    else
      span.removeClass("triangle-up").addClass("triangle-down")

