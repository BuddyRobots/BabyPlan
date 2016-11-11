$ ->
  $("#confirm-transfer-out").click ->
    transfer_id = $(this).attr("data-id")
    $.postJSON(
      '/staff_mobile/transfers/' + transfer_id +'/confirm_transfer_out',
      { },
      (data) ->
        console.log data
        if data.success
          window.location.href = "/staff_mobile/transfers/transfer_done"
        else
          $.page_notification "服务器出错，请稍后重试"
      )