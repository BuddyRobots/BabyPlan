$ ->
  weixin_jsapi_authorize(["scanQRCode"])


  $("#confirm-transfer-out").click ->
    transfer_id = $(this).attr("data-id")
    $.postJSON(
      '/staff_mobile/transfers/' + transfer_id +'/confirm_transfer_out',
      { },
      (data) ->
        console.log data
        if data.success
          window.location.href = "/staff_mobile/transfers/transfer_done"
        else
          $.page_notification "服务器出错，请稍后重试"
      )

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
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&name=" + data.name + "&isbn=" + data.isbn
            else
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&code=" + data.code
          )

  $("#continue-transfer-out").click ->
    scan()
