$ ->

  $(".delete_qr").click ->
    $.postJSON(
      "/staff/books/" + window.qid + "/delete_qr_code",
      {},
      (data) ->
        if data.success
          location.href = "/staff/books/code_list"
      )