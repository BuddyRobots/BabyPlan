$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  scan = ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        $.postJSON(
          '/staff_mobile/transfers/' + window.transfer_id + '/transfer_arrive',
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
              if data.code == BOOK_NOT_IN_TRANSFER
                $("#unreturn").text("绘本不在此次迁移中")
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
    if window.code == BOOK_NOT_IN_TRANSFER
      $("#unreturn").text("绘本不在此次迁移中")

  $("#clicked").click ->
    scan()


  $("#unclicked").click ->
    $.postJSON(
      '/staff_mobile/transfers/' + window.transfer_id + '/finish_transfer',
      {
        force: false
      },
      (data) ->
        console.log data
        if data.success
          if data.finish == true
            location.href = "/staff_mobile/transfers/" + window.transfer_id
          else
            location.href = "/staff_mobile/transfers/" + window.transfer_id + "/confirm_lost"
        else
          $.mobile_page_notification("服务器错误")
      )
