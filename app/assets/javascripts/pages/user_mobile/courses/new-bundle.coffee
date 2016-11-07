$ ->
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
        $.postJSON(
          '/user_mobile/courses/' + window.course_participate_id + '/pay_finished',
          { },
          (data) ->
            # redirect to the result page
          )
      else
        # redirect to the result page
      return
    return

  $("#wechat-pay").click ->
    pay()
