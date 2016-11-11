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
              location.href = "/staff_mobile/transfers/transfer_in?transfer_id=" + window.transfer_id + "&name=" + data.name + "&isbn=" + data.isbn
            else
              location.href = "/staff_mobile/transfers/transfer_in?transfer_id=" + window.transfer_id + "&code=" + data.code
          )

  $("#clicked").click ->
    scan()


  $("#unclicked").click ->
    $.postJSON(
      '/staff_mobile/transfers/' + window.transfer_id + '/finish_transfer',
      {
        force: true
      },
      (data) ->
        console.log data
        if data.success
          location.href = "/staff_mobile/transfers/" + window.transfer_id
        else
          $.mobile_page_notification("服务器错误")
      )
