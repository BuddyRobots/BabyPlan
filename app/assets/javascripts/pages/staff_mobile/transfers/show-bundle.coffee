$ ->
  weixin_jsapi_authorize(["scanQRCode"])


  $("#confirm-transfer-out").click ->
    transfer_id = $(this).attr("data-id")
    $.postJSON(
      '/staff_mobile/transfers/' + transfer_id + '/confirm_transfer_out',
      { },
      (data) ->
        console.log data
        if data.success
          window.location.href = "/staff_mobile/transfers/transfer_done"
        else
          $.mobile_page_notification "服务器出错，请稍后重试"
      )

  continue_out_scan = ->
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
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&book_id=" + data.id
            else
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&code=" + data.code
          )

  $("#continue-transfer-out").click ->
    continue_out_scan()

  $("#back").click ->
    location.href = "/staff_mobile/transfers"

  start_in_scan = ->
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
              location.href = "/staff_mobile/transfers/transfer_in?transfer_id=" + window.transfer_id + "&book_id=" + data.id
            else
              location.href = "/staff_mobile/transfers/transfer_in?transfer_id=" + window.transfer_id + "&code=" + data.code
          )

  $("#start").click ->
    start_in_scan()
