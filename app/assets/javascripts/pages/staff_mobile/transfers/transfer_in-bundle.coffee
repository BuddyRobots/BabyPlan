$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  if window.name != ""
    # show the book info
    $(".unreturn-div").hide()
    $(".desc-div").show()
    $("#name").text("绘本名称：" + window.name)
    if window.isbn != ""
      $("#isbn").show()
      $("#isbn").text("ISBN号：" + window.isbn)
    else
      $("#isbn").hide()
  else
    # show the error info
    $(".unreturn-div").show()
    $(".desc-div").hide()
    if window.code == BOOK_NOT_IN_TRANSFER
      $("#unreturn").text("绘本不在此次迁移中")
