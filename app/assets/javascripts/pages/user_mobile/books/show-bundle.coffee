$ ->
  $(".smallheart").click ->
    fav = $(this).attr("data-fav")
    $.postJSON(
      '/user_mobile/books/' + window.book_id + '/favorite',
      {
        favorite: fav
      },
      (data) ->
        console.log data
        if data.success
          if fav == "true"
            $(".smallheart").attr("src", window.concern_path)
            $(".smallheart").attr("data-fav", "false")
          else
            $(".smallheart").attr("src", window.unconcern_path)
            $(".smallheart").attr("data-fav", "true")
        else
          $.page_notification "服务器出错，请稍后重试"
      )