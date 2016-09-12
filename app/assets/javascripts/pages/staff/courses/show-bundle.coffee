#= require moment.min
#= require fullcalendar.min
#= require locale-all

$ ->

  $("#calendar-operation-wrapper").hide()
  is_edit = false

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
    # events: [
    #   {
    #     title: 'All Day Event'
    #     start: '2016-09-01'
    #   }
    #   {
    #     title: 'Long Event'
    #     start: '2016-09-07'
    #     end: '2016-09-10'
    #   }
    #   {
    #     id: 999
    #     title: 'Repeating Event'
    #     start: '2016-09-09T16:00:00'
    #   }
    #   {
    #     id: 999
    #     title: 'Repeating Event'
    #     start: '2016-09-16T16:00:00'
    #   }
    #   {
    #     title: 'Conference'
    #     start: '2016-09-11'
    #     end: '2016-09-13'
    #   }
    #   {
    #     title: 'Meeting'
    #     start: '2016-09-12T10:30:00'
    #     end: '2016-09-12T12:30:00'
    #   }
    #   {
    #     title: 'Lunch'
    #     start: '2016-09-12T12:00:00'
    #   }
    #   {
    #     title: 'Meeting'
    #     start: '2016-09-12T14:30:00'
    #   }
    #   {
    #     title: 'Happy Hour'
    #     start: '2016-09-12T17:30:00'
    #   }
    #   {
    #     title: 'Dinner'
    #     start: '2016-09-12T20:00:00'
    #   }
    #   {
    #     title: 'Birthday Party'
    #     start: '2016-09-13T07:00:00'
    #   }
    #   {
    #     title: 'Click for Google'
    #     url: 'http://google.com/'
    #     start: '2016-09-28'
    #     color: "red"
    #   }
    # ]
    eventClick: (calEvent, jsEvent, view) ->
      alert 'Event: ' + calEvent.id
      return
  })

  $("#unshelve-btn").click ->
    current_state = "unavailable"
    if $(this).hasClass("available")
      current_state = "available"
    btn = $(this)
    $.postJSON(
      '/staff/courses/' + window.cid + '/set_available',
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
            $(".shelve").text("已下架")
          else
            btn.addClass("available")
            btn.removeClass("unavailable")
            btn.find("span").text("下架")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
            $(".shelve").text("在架上")
      )

  $(".edit-btn").click ->
    $("#unshelve-btn").attr("disabled", true)
    $(".unedit-box").toggle()
    $(".edit-box").toggle()
    $("#course-num").val($("#num-span").text())
    $("#course-capacity").val(window.capacity)
    $("#course-charge").val(window.price)
    $("#course-times").val(window.length)
    $("#course-date").val($("#date-span").text())
    $("#course-speaker").val($("#speaker-span").text())
    $("#course-address").val($("#address-span").text())

    $("#calendar-operation-wrapper").show()

    $(".edit-btn").toggle()
    $(".finish-btn").toggle()
    is_edit = true

  $(".finish-btn").click ->
    is_edit = false

    code = $("#course-num").val()
    capacity = $("#course-capacity").val()
    price = $("#course-charge").val()
    length = $("#course-times").val()
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    address = $("#course-address").val()

    $.putJSON(
      '/staff/courses/' + window.cid,
      {
        course_inst: {
          code: code
          capacity: capacity
          price: price
          length: length
          date: date
          speaker: speaker
          address: address
        }
      },
      (data) ->
        console.log data
        if data.success
          $(".edit-btn").toggle()
          $(".finish-btn").toggle()
          $(".unedit-box").show()
          $(".edit-box").hide()

          $("#unshelve-btn").attr("disabled", false)
          $("#calendar-operation-wrapper").hide()

          $("#num-span").text(code)
          $("#capacity-span").text(capacity + "人")
          $("#charge-span").text(price + "元")
          $("#times-span").text(length + "次")
          window.capacity = capacity
          window.price = price
          window.length = length
          $("#date-span").text(date)
          $("#speaker-span").text(speaker)
          $("#address-span").text(address)
        else
          $.page_notification "服务器出错，请稍后重试"
    )

  $("#user-review").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $("#unshelve-btn").hide()

  $("#register-message").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $("#unshelve-btn").hide()

  $("#course-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $("#unshelve-btn").show()

  # calender set
  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true
      });
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $('#start-time').timepicker({
    'minTime': '7:00am'
    'maxTime': '9:00pm'
    'showDuration': false
    'timeFormat': 'H:i:s'
  })
  $('#end-time').timepicker({
    'minTime': '7:00am'
    'maxTime': '9:00pm'
    'showDuration': false
    'timeFormat': 'H:i:s'
  })

  $("#add-event").click ->
    date = $("#datepicker").val()
    start_time = $("#start-time").val()
    end_time = $("#end-time").val()
    console.log date
    console.log start_time
    console.log end_time
    e = {
      title: ""
      allDay: false
      start: date + "T" + start_time
      end: date + "T" + end_time
    }
    $("#calendar").fullCalendar('renderEvent', e, true)
