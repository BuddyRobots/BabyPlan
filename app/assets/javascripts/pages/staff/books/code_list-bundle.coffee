$ ->

  $("#delete-btn").click ->
    $.postJSON(
      "/staff/books/clear_list",
      {},
      (data) ->
        if data.success
          location.href = "/staff/books/code_list"
      )

  $("#download-btn").click ->
    $(this).text("正在处理中").attr("disabled", true)
    $.postJSON(
      "/staff/books/download_all_qr",
      {},
      (data) ->
        if data.success
          window.open(data.filename)
          $("#download-btn").text("全部下载").attr("disabled", false)
          $.page_notification("请在新窗口中下载", 2000)
      )

  