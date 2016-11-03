$ ->
  # alert($("#appId").text())
  # alrt($("#timeStamp").text())
  # alrt($("#nonceStr").text())
  # alrt($("#package").text())
  # alrt($("#signType").text())
  # alrt($("#paySign").text())
  pay = ->
    WeixinJSBridge.invoke 'getBrandWCPayRequest', {
      'appId': $("#appId").text(),
      'timeStamp': $("#timeStamp").text(),
      'nonceStr': $("#nonceStr").text(),
      'package': $("#package").text(),
      'signType': $("#signType").text(),
      'paySign': $("#paySign").text()
    }, (res) ->
      if res.err_msg == 'get_brand_wcpay_request：ok'
        alert("SUCCESS")
      else
        alert(res.err_msg)
      return
    return

  $("#wechat-pay").click ->
    pay()
