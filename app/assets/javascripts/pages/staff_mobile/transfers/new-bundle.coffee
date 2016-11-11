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
            transfer_id: window.transfer_id
          },
          (data) ->
            console.log data
            if data.success
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id="
                              + window.transfer_id + "&name=" + data.name + "&isbn=" + data.isbn
              # show the book info
              # $(".unreturned-div").hide()
              # $(".desc-div").show()
              # $("#name").text("绘本名称：" + data.name)
              # if data.isbn != ""
              #   $("#isbn").show()
              #   $("#isbn").text("ISBN号：" + data.isbn)
              # else
              #   $("#isbn").hide()
            else
              # show the error info
              location.href = "/staff_mobile/transfers/transfer_out?transfer_id="
                              + window.transfer_id + "&code=" + data.code
              $(".unreturned-div").show()
              $(".desc-div").hide()
              if data.code == BOOK_NOT_EXIST
                $("#unreturn").text("没有找到绘本")
              if data.code == BOOK_NOT_RETURNED
                $("#unreturn").text("该绘本在借出状态")
              if data.code == BOOK_IN_TRANSFER
                $("#unreturn").text("该绘本在迁移状态")
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
          # window.location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + data.transfer_id + "&auto=true"
        else
          $.page_notification "服务器出错，请稍后重试"
      )