#= require "./_templates/announcement_item"
$ ->
  page = 2

  $('.content-div').on 'click', '.item', ->
    aid = $(this).attr("data-id")
    location.href = "/user_mobile/announcements/" + aid + "?back=announcements"


  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load-gif").show()
    $.getJSON "/user_mobile/announcements/more?page=" + page, (data) ->
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
            (index, announcement_item_data) ->
              announcement_item = $(HandlebarsTemplates["announcement_item"](announcement_item_data))
              $(".render-more").before(announcement_item)
          )
      else
        $.mobile_page_notification "服务器出错"
