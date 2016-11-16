#= require "./_templates/feed_item"
$ ->
  page = 2

  $(document).on 'click', '.content', ->
    path = $(this).attr("data-path")
    location.href = "/user_mobile/" + path

  $("#search-btn").click ->
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/feeds?keyword=" + keyword

  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load").show()
    $.getJSON "/user_mobile/feeds/more?keyword=" + window.keyword + "&page=" + page, (data) ->
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
            (index, feed_item_data) ->
              feed_item = $(HandlebarsTemplates["feed_item"](feed_item_data))
              $(".render-more").before(feed_item)
          )
      else
        $.mobile_page_notification "服务器出错"
