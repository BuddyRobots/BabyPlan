$ ->
  if window.profile == "global"
    $('.nav-tabs a[href="#tab2"]').tab('show')

  if window.profile == "local"
    $('.nav-tabs a[href="#tab1"]').tab('show')

  $(".add-btn").click ->
    location.href = "/staff/announcements/new"

  search = ->
    value = $("#search-input").val()
    location.href = "/staff/announcements?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  jump = ->
    link = $(".jump").attr("data-link")
    page = $(".auto-page-box").val()
    if $.isNumeric(page)
      page = parseInt(page)
      if page <= 0
        $.page_notification("请输入正确的页码", 1000)
      else
        if page >= local_total_page
          location.href = link + "local_page=" + local_total_page
        if page < local_total_page
          location.href = link + "local_page=" + page


  $(".jump").click ->
    jump()


  $("#global_announce").on "shown.bs.tab", (e) ->
    $(".jump").click ->
      link = $(this).attr("data-link")
      page = $(this).siblings(".auto-page-box").val()
      if $.isNumeric(page)
        page = parseInt(page)
        if page <= 0
          $.page_notification("请输入正确的页码", 1000)
        else
          if page >= global_total_page
            location.href = link + "global_page=" + global_total_page
          if page < global_total_page
            location.href = link + "global_page=" + page
