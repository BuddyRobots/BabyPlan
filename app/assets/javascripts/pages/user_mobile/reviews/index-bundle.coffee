$ ->

  hide = true
  score = 0

  $("#review").click ->
    $(this).hide()
    $(".mask").show()

  $(".text-div").click ->
    hide = false
    return true

  $(".mask").click ->
    if hide == true
      $(".mask").hide()
      $("#review").show()
    hide = true

  $(".review-div").submit ->
    return false

  $("#submit").click ->
    score = $("input:checked").val()
    content = $("#text").val()
    if score == 0
      $.mobile_page_notification("请评分", 3000)
      return
    if content == ""
      $.mobile_page_notification("请填写评价内容", 3000)
      return
    $.postJSON(
      '/user_mobile/reviews',
      {
        score: score
        content: content
        review_type: window.review_type
        book_id: window.book_id
        course_id: window.course_id
      },
      (data) ->
        console.log data
        if data.success
          window.location.reload()
        else
          $.mobile_page_notification "服务器出错，请稍后重试"
      )
