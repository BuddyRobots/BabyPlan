$ ->
  $(".next-btn").click ->
    out_center_id = window.cid
    in_center_id = $("#center-choice").val()
    if (out_center_id == in_center_id)
      $.mobile_page_notification("不能迁至本儿童中心", 3000)
      $.postJSON(
        '/staff_mobile/transfers',
        {
          out_center_id: out_center_id
          in_center_id: in_center_id
        },
        (data) ->
          console.log data
          if data.success
            window.location.href = "/staff_mobile/transfers/transfer_out?transfer_id=" + data.transfer_id + "&auto=true"
          else
            $.page_notification "服务器出错，请稍后重试"
        )