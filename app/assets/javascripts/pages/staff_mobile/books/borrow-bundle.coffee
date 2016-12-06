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
          '/staff_mobile/books/' + result + '/do_borrow',
          {
            mobile: mobile
          },
          (data) ->
            console.log data
            if data.success
              location.href = "/staff_mobile/books/borrow_result?borrow_id=" + data.borrow_id + "&mobile=" + mobile
            else
              if data.code == USER_NOT_EXIST
                $.mobile_page_notification("不是本儿童中心用户", 3000)
              if data.code == BOOK_NOT_EXIST
                location.href = "/staff_mobile/books/borrow_result?err=book_not_exist" + "&mobile=" + mobile
              if data.code == BOOK_NOT_RETURNED
                location.href = "/staff_mobile/books/borrow_result?err=book_not_returned" + "&mobile=" + mobile
              if data.code == BOOK_IN_TRANSFER
                location.href = "/staff_mobile/books/borrow_result?err=book_in_transfer" + "&mobile=" + mobile
              if data.code == BOOK_NOT_AVAILABLE
                location.href = "/staff_mobile/books/borrow_result?err=book_not_available" + "&mobile=" + mobile
              if data.code == HAS_EXPIRED_BOOK
                location.href = "/staff_mobile/books/borrow_result?err=has_expired_book" + "&mobile=" + mobile
              if data.code == REACH_MAX_BORROW
                location.href = "/staff_mobile/books/borrow_result?err=reach_max_borrow" + "&mobile=" + mobile
              if data.code == BOOK_ALL_OFF_SHELF
                location.href = "/staff_mobile/books/borrow_result?err=book_all_off_shelf" + "&mobile=" + mobile
              if data.code == LATEFEE_NOT_PAID
                location.href = "/staff_mobile/books/borrow_result?err=latefee_not_paid" + "&mobile=" + mobile
              if data.code == DEPOSIT_NOT_PAID
                location.href = "/staff_mobile/books/borrow_result?err=deposit_not_paid" + "&mobile=" + mobile
        )
