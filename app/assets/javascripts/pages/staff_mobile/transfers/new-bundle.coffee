$ ->

  window.transfer_id = ""

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
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&book_id=" + data.id
            else
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + window.transfer_id + "&code=" + data.code
          )


  $(".next-btn").click ->
    out_center_id = window.cid
    in_center_id = $("#center-choice").val()
    if (out_center_id == in_center_id)
      $.mobile_page_notification("不能迁至本儿童中心", 3000)
      return
    $.postJSON(
      '/staff_mobile/transfers',
      {
        out_center_id: out_center_id
        in_center_id: in_center_id
      },
      (data) ->
        console.log data
        if data.success
          window.transfer_id = data.transfer_id
          scan()
        else
          $.page_notification "服务器出错，请稍后重试"
      )