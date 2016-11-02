$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".next-btn").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        alert(result)
        # $.postJSON(
        #   '/coach/users/bind',
        #   {
        #     coach_id: result
        #   },
        #   (data) ->
        #     console.log data
        #     # if data.success
        # )
