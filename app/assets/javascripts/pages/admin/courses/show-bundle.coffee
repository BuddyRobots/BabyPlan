#= require moment.min
#= require fullcalendar.min
#= require locale-all
#= require wangEditor.min

$ ->

# wangEditor
  editor = new wangEditor('edit-area')

  editor.config.menus = [
        'head',
        'img'
     ]
  editor.config.uploadImgUrl = '/materials'

  editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }
  editor.config.hideLinkImg = true
  editor.create()

  $("#course-area").click ->
    $(".btn").hide()

  $("#course-message").click ->
    $(".btn").show()

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
    $("#classname-input").val($("#classname-span").text())
    $("#classspeaker-input").val($("#classspeaker-span").text())
    $("#charge-input").val(window.price)

    $("#edit-area").html($(".introduce-details").html())

    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()

    $(".edit-btn").toggle()
    $(".finish-btn").toggle()
 
  $(".finish-btn").click ->

    name = $("#classname-input").val()
    speaker = $("#classspeaker-input").val()
    price = $("#charge-input").val()
    desc = editor.$txt.html()

    $.putJSON(
      '/admin/courses/' + window.cid,
      {
        course: {
          name: name
          speaker: speaker
          price: price
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
      buttonIcons: true
      weekNumbers: true
      navLinks: true
      editable: true
      eventLimit: true
      fixedWeekCount: false
      nowIndicator: true
      height: 500
      dayClick: (date) ->
        alert(date)
      events: [
        {
          title: 'All Day Event'
          start: '2016-09-01'
        }
        {
          title: 'Long Event'
          start: '2016-09-07'
          end: '2016-09-10'
        }
        {
          id: 999
          title: 'Repeating Event'
          start: '2016-09-09T16:00:00'
        }
        {
          id: 999
          title: 'Repeating Event'
          start: '2016-09-16T16:00:00'
        }
        {
          title: 'Conference'
          start: '2016-09-11'
          end: '2016-09-13'
        }
        {
          title: 'Meeting'
          start: '2016-09-12T10:30:00'
          end: '2016-09-12T12:30:00'
        }
        {
          title: 'Lunch'
          start: '2016-09-12T12:00:00'
        }
        {
          title: 'Meeting'
          start: '2016-09-12T14:30:00'
        }
        {
          title: 'Happy Hour'
          start: '2016-09-12T17:30:00'
        }
        {
          title: 'Dinner'
          start: '2016-09-12T20:00:00'
        }
        {
          title: 'Birthday Party'
          start: '2016-09-13T07:00:00'
        }
        {
          title: 'Click for Google'
          url: 'http://google.com/'
          start: '2016-09-28'
          color: "red"
        }
      ]
    })
