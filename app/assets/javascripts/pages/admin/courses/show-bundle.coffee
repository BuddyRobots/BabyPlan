#= require moment.min
#= require fullcalendar.min
#= require locale-all
#= require wangEditor.min

$ ->


  is_edit = false

# wangEditor
  editor = new wangEditor('edit-area')
  editor.config.menus = ['head', 'img']
  editor.config.uploadImgUrl = '/materials'
  editor.config.uploadHeaders = {'Accept' : 'HTML'}
  editor.config.hideLinkImg = true
  editor.create()

  $("#course-area").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $("#unshelve-btn").hide()

  $("#course-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $("#unshelve-btn").show()

  # unshelve-btn press-down
  $("#unshelve-btn").click ->
    current_state = "unavailable"
    if $(this).hasClass("available")
      current_state = "available"
    btn = $(this)
    $.postJSON(
      '/admin/courses/' + window.cid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        if data.success
          $.page_notification("操作完成")
          console.log btn.find("img").attr("src")
          if current_state == "available"
            btn.removeClass("available")
            btn.addClass("unavailable")
            btn.find("span").text("上架")
            btn.find("img").attr("src", "/assets/managecenter/shelve.png")
            $(".shelve").text("未上架")
          else
            btn.addClass("available")
            btn.removeClass("unavailable")
            btn.find("span").text("下架")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
            $(".shelve").text("在架上")
      )

  $(".edit-btn").click ->
    $("#unshelve-btn").attr("disabled", true)
    $(".unedit-box").hide()
    $(".edit-box").show()
    $("#code-input").val($("#code-span").text())
    $("#classname-input").val($("#classname-span").text())
    $("#code-input").val($("#course-span").text())
    $("#classspeaker-input").val($("#classspeaker-span").text())
    $("#public-price-input").val($("#public-price-span").text())
    $("#nums-input").val($("#nums-span").text())
    $("#charge-input").val(window.price)

    $("#edit-area").html($(".introduce-details").html())

    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()

    $(".edit-btn").toggle()
    $(".finish-btn").toggle()

    is_edit = true
 
  $(".finish-btn").click ->

    is_edit = false

    name = $("#classname-input").val()
    speaker = $("#classspeaker-input").val()
    price = $("#charge-input").val()
    code = $("#code-input").val()
    desc = editor.$txt.html()

    $.putJSON(
      '/admin/courses/' + window.cid,
      {
        course: {
          name: name
          speaker: speaker
          price: price
          code: code
          desc: desc
        }
      },
      (data) ->
        console.log data
        if data.success
          $(".edit-btn").toggle()
          $(".finish-btn").toggle()
          $(".introduce-details").toggle()
          $(".wangedit-area").toggle()
          $(".unedit-box").show()
          $(".edit-box").hide()

          $("#unshelve-btn").attr("disabled", false)

          $("#classname-span").text(name)
          $("#classspeaker-span").text(speaker)
          $("#code-span").text(code)
          $("#charge-span").text(price + "元")
          window.price = price
          $(".introduce-details").html(desc)
        else
          $.page_notification "服务器出错，请稍后重试"
    )

  # fullcalendar
  $('#course-area').on 'shown.bs.tab', (e) ->
    initialLocaleCode = "zh-cn"
    $("#calendar").fullCalendar({
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,agendaWeek,agendaDay,listMonth'
      locale: initialLocaleCode
      weekNumbers: true
      navLinks: true
      eventLimit: true
      fixedWeekCount: false
      nowIndicator: true
      height: 500
    })

  if window.profile == "area"
    $('.nav-tabs a[href="#tab2"]').tab('show')
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $("#unshelve-btn").hide()

  parse_calendar_events = ->
    event_str_ary = window.date_in_calendar.split(';')
    $.each(
      event_str_ary,
      (index, event_str) ->
        start_str = event_str.split(',')[0]
        end_str = event_str.split(',')[1]
        e = {
          id: guid()
          title: ""
          allDay: false
          start: start_str
          end: end_str
        }
        $("#calendar").fullCalendar('renderEvent', e, true)
    )

  $(".course-inst-tr").click ->
    ci_id = $(this).attr("data-id")
    tr = $(this)

    $.getJSON "/admin/courses/" + ci_id + "/get_calendar", (data) ->
      if data.success
        $("#calendar").fullCalendar('removeEvents')
        console.log data.calendar
        $.each(
          data.calendar,
          (index, event_str) ->
            start_str = event_str.split(',')[0]
            end_str = event_str.split(',')[1]
            e = {
              title: ""
              allDay: false
              start: start_str
              end: end_str
            }
            $("#calendar").fullCalendar('renderEvent', e, true)
        )
        $(".course-inst-tr").removeClass("clicked")
        tr.addClass("clicked")
      else
        $.page_notification "课程不存在"

