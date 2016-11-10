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
	          transfer_id: window.transfer_id
	        },
	        (data) ->
	          console.log data
	          if data.success
	          	# show the book info
	          else
	          	# show the error info
	        )

	if window.auto == 'true'
		scan()

  $("#clicked").click ->
  	scan()
