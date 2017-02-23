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
