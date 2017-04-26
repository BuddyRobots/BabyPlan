$ ->
  
  $.mobile_page_notification $("#remainTime").text()

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
          '/user_mobile/courses/' + window.course_participate_id + '/pay_finished',
          { },
          (data) ->
            # redirect to the result page
            location.href = "/user_mobile/courses/" + window.course_id + '/pay_success'
          )
      else if res.err_msg == 'get_brand_wcpay_request:fail'
        $.postJSON(
          '/user_mobile/courses/' + window.course_participate_id + '/pay_failed',
          { },
          (data) ->
            # redirect to the result page
            location.href = "/user_mobile/courses/" + window.course_id
          )
      else
        # user cancels, do nothing
      return
    return

  $("#wechat-pay").click ->
    # should first send request to server to check whether the order is expired, and if expired, redirect to show page
    $.postJSON(
      '/user_mobile/courses/' + window.course_participate_id + '/is_expired',
      {
        before_pay: true
      },
      (data) ->
        if data.success
          if data.is_expired
            window.location.href = '/user_mobile/courses/' + window.course_id
          else
            pay()
    )
    # pay()

  $("#free-course-signup").click ->
    # should first send request to server to check whether the order is expired, and if expired, redirect to show page
    $.postJSON(
      '/user_mobile/courses/' + window.course_participate_id + '/is_expired',
      { },
      (data) ->
        if data.success
          if data.is_expired
            window.location.href = '/user_mobile/courses/' + window.course_id
          else
            $.postJSON(
              '/user_mobile/courses/' + window.course_participate_id + '/pay_finished',
              { },
              (data) ->
                location.href = "/user_mobile/courses/" + window.course_id + '/pay_success'
              )
    )
