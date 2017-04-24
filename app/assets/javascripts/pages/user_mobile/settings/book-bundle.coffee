$ ->
  $(".details").click ->
    bid = $(this).attr("data-id")
    window.location.href = "/user_mobile/settings/" + bid + "?back=setting"

  pay = ->
    WeixinJSBridge.invoke 'getBrandWCPayRequest', {
      'appId': $("#appId").text(),
      'timeStamp': $("#timeStamp").text(),
      'nonceStr': $("#nonceStr").text(),
      'package': $("#package").text(),
      'signType': $("#signType").text(),
      'paySign': $("#paySign").text()
    }, (res) ->
      if res.err_msg == 'get_brand_wcpay_request:ok'
        $.postJSON(
          '/user_mobile/settings/pay_finished',
          { },
          (data) ->
            # redirect to the result page
            location.href = "/user_mobile/settings/book"
          )
      else if res.err_msg == 'get_brand_wcpay_request:fail'
        $.postJSON(
          '/user_mobile/settings/pay_failed',
          { },
          (data) ->
            # redirect to the result page
            location.href = "/user_mobile/settings/book"
          )
      else
        # user cancels, do nothing
      return
    return

  $("#confirm-pay").click ->
    pay()

  # $("#deposit").click ->
  #   $.postJSON(
  #     '/user_mobile/settings/refund_deposit',
  #     {},
  #     (data) ->
  #       if data.str == "ok"
  #         $.mobile_page_notification("退款成功", 1000)
  #         setTimeout(location.href = "/user_mobile/settings/book", 1200)
  #       else
  #         $.mobile_page_notification("服务器错误")
  #     )
