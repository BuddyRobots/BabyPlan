#= require wangEditor.min
#= require tag-it.min
$ ->

  $('#QR-codeModal').on 'hidden.bs.modal', ->
    $("#code-num").val("")
    $("#confirm-qr-code").removeClass("button-enabled")
    $("#confirm-qr-code").addClass("button-disabled")
    $("#transfer-qr-code").removeClass("button-enabled")
    $("#transfer-qr-code").addClass("button-disabled")
    $("#transfer-qr-code").text("导出到表格")

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

  is_edit = false

# wangEditor
  # editor = new wangEditor('edit-area')

  # editor.config.menus = [
  #       'head',
  #       'img'
  #    ]

  # editor.config.uploadImgUrl = '/materials'
  # editor.config.uploadHeaders = {
  #   'Accept' : 'HTML'
  # }
  # editor.config.hideLinkImg = true
  # editor.create()

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
    $(".unedit-stock-box").toggle()
    $(".shelve").toggle()
    $(".edit-stock-box").toggle()
    $(".finish-btn").toggle()
    $(".edit-btn").toggle()
    $(".type-span-template").hide()
    is_edit = true
    $(".delete-btn").attr("disabled", true)
    $(".unshelve-btn").attr("disabled", true)
    $(".QRcode-btn").attr("disabled", true)
    $("#stock-input").val(window.stock)

# button hide
  $("#book-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $(".unshelve-btn").show()
    $(".QRcode-btn").show()
    $(".delete-btn").show()

  $("#user-review").click ->
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()
    $(".finish-btn").hide()
    $(".QRcode-btn").hide()
    $(".delete-btn").hide()

  $("#borrow-message").click ->
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()
    $(".finish-btn").hide()  
    $(".QRcode-btn").hide()
    $(".delete-btn").hide()  

  $("#return-book").click ->
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()
    $(".finish-btn").hide()  
    $(".QRcode-btn").hide()
    $(".delete-btn").hide()  

  # finish-btn pressdown
  $(".finish-btn").click ->
    stock = $("#stock-input").val()
    if stock == ""
      $.page_notification("请补全信息", 1000)
      return

    if $.isNumeric(stock) == false || parseInt(stock) < 0
      $.page_notification("请输入合法的库存数量", 1000)
      return

    num = parseInt(stock) - parseInt(window.stock)
    $.putJSON(
      '/staff/books/' + window.bid,
      {
        stock: parseInt(stock)
        num: num
      },
      (data) ->
        if data.success
          $.page_notification("图书信息更新成功", 1000)
          $(".unedit-stock-box").toggle()
          $(".shelve").toggle()
          $(".edit-stock-box").toggle()
          $(".finish-btn").toggle()
          $(".edit-btn").toggle()
          $(".type-span-template").hide()
          $(".delete-btn").attr("disabled", false)
          $(".unshelve-btn").attr("disabled", false)
          $(".QRcode-btn").attr("disabled", false)
          $("#stock-span").text(stock + "本")

          window.stock = stock
        else
          $.page_notification("服务器出错")
      )

  $(".delete-btn").click ->
    $.postJSON(
      "/staff/books/" + window.bid + "/set_delete",
      {
        deleted: true
      },
      (data) ->
        if data.success
          location.href = "/staff/books"
        else
          if data.code == BOOK_EXIST
            $.page_notification("该绘本尚有库存，不能删除", 1000)
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
      $("#confirm-qr-code").addClass("button-disabled")
      $("#confirm-qr-code").removeClass("button-enabled")
      $("#transfer-qr-code").addClass("button-disabled")
      $("#transfer-qr-code").removeClass("button-enabled")
    else
      $("#confirm-qr-code").removeClass("button-disabled")
      $("#confirm-qr-code").addClass("button-enabled")
      $("#transfer-qr-code").removeClass("button-disabled")
      $("#transfer-qr-code").addClass("button-enabled")
      $("#transfer-qr-code").text("导出到表格")

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
    else
      $.page_notification("请正确输入数量", 2000)
    return false

  $("#transfer-qr-code").click ->
    $(this).text("已导出")
    $(this).removeClass("button-enabled")
    $(this).addClass("button-disabled")
    num = $("#code-num").val()
    if !$.isNumeric(num)
      $.page_notification("请正确输入数量", 2000)
      return
    num = parseInt(num)
    if !num > 0
      $.page_notification("请正确输入数量", 2000)
      return
    $.postJSON(
      "/staff/books/" + window.bid + "/add_to_list",
      {
        num: num
      },
      (data) ->

      )
    return false

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

