#= require "./_templates/course_item"
$ ->
  page = 2

  $('.content-area').on 'click', '.content', ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + cid + "?back=courses"


  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/courses?keyword=" + keyword


  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load").show()
    $.getJSON "/user_mobile/courses/more?keyword=" + window.keyword + "&page=" + page, (data) ->
      $(".load").hide()
      render_more.show()
      if data.success
        console.log data.more
        if (data.more.length == 0)
          $.mobile_page_notification("没有了")
        else
          page = page + 1
          $.each(
            data.more,
            (index, course_item_data) ->
              course_item = $(HandlebarsTemplates["course_item"](course_item_data))
              $(".render-more").before(course_item)
          )
      else
        $.mobile_page_notification "服务器出错"
