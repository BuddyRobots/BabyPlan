$ ->

  weixin_jsapi_authorize(["scanQRCode"])

  $("#borrow-book").click ->
    location.href = "/staff_mobile/books/borrow"

  $("#book-transfer").click ->
    location.href = "/staff_mobile/transfers"

  $("#book-borrow").click ->
    location.href = "/staff_mobile/books?v=" + new Date().getTime()

  $("#scan-book").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        location.href="/staff_mobile/books/" + result

  $("#return-book").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        location.href="/staff_mobile/books/" + result + "/back"

