
$ ->
  search = ->
    keyword = $("#input-value").val().trim()
    if keyword != ""
      window.location.href = "/user_mobile/courses/search_result?keyword=" + keyword

  $(".search").click ->
    search()
    return false

  $("#input-value").keydown (event) ->
    code = event.which
    if code == 13
      search()
    


  page = 2

  $('.content-area').on 'click', '.content', ->
    bid = $(this).attr("data-id")
    location.href = "/user_mobile/books/" + bid + "?back=books"

  $("#search-btn").click ->
    lower = $(".select").attr("data-lower")
    upper = $(".select").attr("data-upper")
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/books?keyword=" + keyword + "&lower=" + lower + "&upper=" + upper

  $(".dl-div a").each ->
    lower = $(this).attr("data-lower")
    upper = $(this).attr("data-upper")
    if lower == window.lower && upper == window.upper
      $(this).addClass("select")

  $(".dl-div a").click ->
    lower = $(this).attr("data-lower")
    upper = $(this).attr("data-upper")
    keyword = $("#input-box").val()
    window.location.href = "/user_mobile/books?keyword=" + keyword + "&lower=" + lower + "&upper=" + upper

  $(".render-more").click ->
    render_more = $(this)
    render_more.hide()
    $(".load").show()
    $.getJSON "/user_mobile/books/more?keyword=" + window.keyword + "&lower=" + window.lower + "&upper=" + window.upper + "&page=" + page, (data) ->
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
            (index, book_item_data) ->
              book_item = $(HandlebarsTemplates["book_item"](book_item_data))
              $(".render-more").before(book_item)
          )
      else
        $.mobile_page_notification "服务器出错"
