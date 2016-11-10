$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".next-btn").click ->
    # 1. check mobile
    mobile = $("#mobile").val()
    password = $("#password").val()
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.mobile_page_notification("错误的手机号", 3000)
      return
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        $.postJSON(
          '/staff_mobile/books/do_borrow',
          {
            mobile: mobile
            book_id: result
          },
          (data) ->
            console.log data
            if data.success
              location.href = "/staff_mobile/books/borrow_result?borrow_id=" + data.borrow_id
            else
              if data.code == USER_NOT_EXIST
                $.mobile_page_notification("用户不存在", 3000)
              if data.code == BOOK_NOT_EXIST
                location.href = "/staff_mobile/books/borrow_result?err=book_not_exist"
              if data.code == BOOK_NOT_RETURNED
                location.href = "/staff_mobile/books/borrow_result?err=book_not_returned"
        )
