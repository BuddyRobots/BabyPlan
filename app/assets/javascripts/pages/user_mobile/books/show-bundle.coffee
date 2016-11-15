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
            $(".smallheart").attr("src", "/assets/concern.png")
            $(".smallheart").attr("data-fav", "false")
          else
            $(".smallheart").attr("src", "/assets/cancel-concern.png")
            $(".smallheart").attr("data-fav", "true")
        else
          $.page_notification "服务器出错，请稍后重试"
      )