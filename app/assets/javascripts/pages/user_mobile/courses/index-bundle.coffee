#= require "./_templates/course_item"
$ ->
  page = 2

  $('.content-area').on 'click', '.content', ->
    cid = $(this).attr("data-id")
    location.href = "/user_mobile/courses/" + cid + "?back=courses"


  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/courses?keyword=" + keyword + "&price=" + window.price + "&age=" + window.age


  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load").show()
    $.getJSON "/user_mobile/courses/more?keyword=" + window.keyword + "&price=" + window.price + "&age=" + window.age + "&page=" + page, (data) ->
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

  $("#choice-price").change ->
    keyword = $("#input-box").val()
    $("#choice-price option:selected").each ->
      price = $(this).val()
      console.log price
      if price == "0"
        location.href = "/user_mobile/courses?keyword=" + keyword + "&age=" + window.age
      else
        location.href = "/user_mobile/courses?price=" + price + "&keyword=" + keyword + "&age=" + window.age

  $("#choice-age").change ->
    keyword = $("#input-box").val()
    $("#choice-age option:selected").each ->
      age = $(this).val()
      console.log age
      if age == "0"
        location.href = "/user_mobile/courses?keyword=" + keyword + "&price=" + window.price
      else
        location.href = "/user_mobile/courses?age=" + age + "&keyword=" + keyword + "&price=" + window.price
