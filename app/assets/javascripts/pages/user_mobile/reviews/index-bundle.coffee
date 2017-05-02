#= require "./_templates/review_item"
$ ->

  $("#submit").click ->
    score = $("input:checked").val()
    content = $("#text").val()
    if score == 0
      $.mobile_page_notification("请评分", 2000)
      return
    if content == ""
      $.mobile_page_notification("请填写评价内容", 2000)
      return
    $.postJSON(
      '/user_mobile/reviews',
      {
        score: score
        content: content
        course_id: window.course_id
      },
      (data) ->
        console.log data
        if data.success
          window.location.reload()
        else
          $.mobile_page_notification "服务器出错，请稍后重试"
      )

  page = 2

  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load-gif").show()
    $.getJSON "/user_mobile/reviews/" + window.course_id + "more?page=" + page, (data) ->
      $(".load-gif").hide()
      render_more.show()
      if data.success
        console.log data.more
        if (data.more.length == 0)
          $.mobile_page_notification("没有了")
        else
          page = page + 1
          $.each(
            data.more,
            (index, review_item_data) ->
              review_item = $(HandlebarsTemplates["review_item"](review_item_data))
              $(".render-more").before(review_item)
          )
      else
        $.mobile_page_notification "服务器出错"
