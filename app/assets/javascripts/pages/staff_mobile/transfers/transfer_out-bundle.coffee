$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  scan = ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        $.postJSON(
          '/staff_mobile/transfers/' + window.transfer_id + '/add_to_transfer',
          {
            book_inst_id: result
          },
          (data) ->
            console.log data
            if data.success
              # show the book info
              $(".unreturn-div").hide()
              $(".desc-div").show()
              $("#name").text("绘本名称：" + data.name)
              if data.isbn != ""
                $("#isbn").show()
                $("#isbn").text("ISBN号：" + data.isbn)
              else
                $("#isbn").hide()
            else
              # show the error info
              $(".unreturn-div").show()
              $(".desc-div").hide()
              if data.code == BOOK_NOT_EXIST
                $("#unreturn").text("没有找到绘本")
              if data.code == BOOK_NOT_RETURNED
                $("#unreturn").text("该绘本在借出状态")
              if data.code == BOOK_IN_TRANSFER
                $("#unreturn").text("该绘本在迁移状态")
          )

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
    if window.code == BOOK_NOT_EXIST
      $("#unreturn").text("没有找到绘本")
    if window.code == BOOK_NOT_RETURNED
      $("#unreturn").text("该绘本在借出状态")
    if window.code == BOOK_IN_TRANSFER
      $("#unreturn").text("该绘本在迁移状态")

  $("#clicked").click ->
    scan()
