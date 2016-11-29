$ ->

  $(".close").click ->
    $("#borrowModal input").val("")
    $("#confirm-borrow-setting").removeClass("button-enabled")
    $("#confirm-borrow-setting").addClass("button-disabled")
    
  if window.profile == "transfers"
    $('.nav-tabs a[href="#tab2"]').tab('show')
    $("#search-input-book").hide()
    $("#search-input-transfer").show()
  else
    $("#search-input-book").show()
    $("#search-input-transfer").hide()

  $('#books-tab').on 'shown.bs.tab', (e) ->
    window.profile = "books"
    $("#search-input-book").show()
    $("#search-input-transfer").hide()

  $('#transfers-tab').on 'shown.bs.tab', (e) ->
    window.profile = "transfers"
    $("#search-input-book").hide()
    $("#search-input-transfer").show()

  search = ->
    book_keyword = $("#search-input-book").val()
    transfer_keyword = $("#search-input-transfer").val()
    window.location.href = "/admin/books?profile=" + window.profile + "&book_keyword=" + book_keyword + "&transfer_keyword=" + transfer_keyword + "&page=1"

  $("#search-btn").click ->
    search()

  
  $("#search-input-book").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $("#search-input-transfer").keydown (event) ->
    code = event.which
    if code == 13
      search()

  check_add_input = ->
    if $("#borrow-num").val().trim() == "" ||
        $("#borrow-time").val().trim() == ""
      $("#confirm-borrow-setting").addClass("button-disabled")
      $("#confirm-borrow-setting").removeClass("button-enabled")
    else
      $("#confirm-borrow-setting").removeClass("button-disabled")
      $("#confirm-borrow-setting").addClass("button-enabled")

  check_add_input()

  $("#borrow-num").keyup ->
    check_add_input()
  $("#borrow-time").keyup ->
    check_add_input()

  $("#confirm-borrow-setting").click ->
    book_num = $("#borrow-num").val()
    if $.isNumeric(book_num) == false || parseInt(book_num) <= 0
      $.page_notification("请输入正确的最大可借本数")
      return false
    borrow_duration = $("#borrow-time").val()
    if $.isNumeric(borrow_duration) == false || parseInt(borrow_duration) <= 0
      $.page_notification("请输入正确的最长可借天数")
      return false
    $.postJSON(
      '/admin/books/update_setting',
      {
        book_num: book_num
        borrow_duration: borrow_duration
      },
      (data) ->
        if data.success
          $.page_notification("设置完成")
        else
          $.page_notification("服务器出错")
      )
    return false

