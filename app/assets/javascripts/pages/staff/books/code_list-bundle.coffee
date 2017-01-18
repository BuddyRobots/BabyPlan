$ ->

  # $(".delete_qr").click ->
  #   $.postJSON(
  #     "/staff/books/" + window.qrid + "/delete_qr_code",
  #     {},
  #     (data) ->
  #       if data.success
  #         location.href = "/staff/books/code_list"
  #     )

  $("#delete-btn").click ->
    $.postJSON(
      "/staff/books/clear_list",
      {},
      (data) ->
        if data.success
          location.href = "/staff/books/code_list"
      )

  