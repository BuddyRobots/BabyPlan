# = require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW

$ ->
  has_photo = false

  can_repeat = false
  enable_repeat = ->
    can_repeat = true
    $(".date-btn").addClass("active-btn")
    $(".week-btn").addClass("active-btn")

  disable_repeat = ->
    can_repeat = false
    $(".date-btn").removeClass("active-btn")
    $(".week-btn").removeClass("active-btn")

  guid = ->
    s4 = ->
      Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

  initialLocaleCode = "zh-cn"
  $("#calendar").fullCalendar({
    header:
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek,agendaDay,listMonth'
    locale: initialLocaleCode
    weekNumbers: true
    navLinks: true
    editable: true
    eventLimit: true
    fixedWeekCount: false
    nowIndicator: true
    height: 355
    # aspectRatio: 2
    eventClick: (calEvent, jsEvent, view) ->
      $("#calendar").fullCalendar('removeEvents', calEvent.id)
  })

  $("#course-code").css("width", $(".num-box").width() - $(".course-num").width() - 6)

  $(".end-btn").click ->
    course_id = window.cid
    available = $("#available").is(":checked")
    code = $("#course-code").val()
    capacity = $("#course-capacity").val()
    price = $("#course-price").val()
    price_pay = $("#public-price").val()
    length = $("#course-length").val()
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    address = $("#course-address").val()

    fc_events = $('#calendar').fullCalendar('clientEvents')
    date_in_calendar = []

    $.each(
      fc_events,
      (index, fc_event) ->
        date_in_calendar.push(fc_event.start._i + "," + fc_event.end._i)
    )


    if code == "" || capacity == "" || price == "" || length == "" || date == "" || speaker == "" || address == ""
      $.page_notification("请将信息补充完整")
      return

    $.postJSON(
      '/staff/courses/',
      course: {
        course_id: course_id
        available: available
        code: code
        capacity: capacity
        price: price
        price_pay: price_pay
        length: length
        date: date
        speaker: speaker
        address: address
        date_in_calendar: date_in_calendar
      },
      (data) ->
        if data.success
          if has_photo == false
            # the user does not upload photo, skip photo uploading step
            location.href = "/staff/courses/" + data.course_inst_id
          else
            $("#upload-photo-form")[0].action = "/staff/courses/" + data.course_inst_id + "/upload_photo"
            $("#upload-photo-form").submit()
        else
          if data.code == COURSE_INST_EXIST
            $.page_notification("课程编号已存在")
          else
            $.page_notification("服务器出错")
      )


  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true
      })
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

  add_event = ->
    if $("#datepicker").val().trim() == "" ||
        $("#start-time").val().trim() == "" || 
        $("#end-time").val().trim() == ""
      $.page_notification("请输入完整的上课日期和时间")
      return false
    date = $("#datepicker").val()
    start_time = $("#start-time").val()
    end_time = $("#end-time").val()
    e = {
      id: guid()
      title: ""
      allDay: false
      start: date + "T" + start_time
      end: date + "T" + end_time
    }
    $("#calendar").fullCalendar('renderEvent', e, true)
    $("#calendar").fullCalendar("gotoDate", Date.parse(date))
    enable_repeat()

  $("#add-event").click ->
    add_event()

  $("#datepicker").change ->
    disable_repeat()

  $("#start-time").change ->
    disable_repeat()

  $("#end-time").change ->
    disable_repeat()

  $(".week-btn").click ->
    if can_repeat == false
      return
    date = $("#datepicker").val()
    next_week = new Date(Date.parse(date) + 7 * 86400000)
    $("#datepicker").datepicker("setDate", next_week);
    add_event()

  $(".date-btn").click ->
    if can_repeat == false
      return
    date = $("#datepicker").val()
    next_day = new Date(Date.parse(date) + 86400000)
    $("#datepicker").datepicker("setDate", next_day);
    add_event()

#photo upload
  $("#upload-photo").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_photo = true
    photo = $("#photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])