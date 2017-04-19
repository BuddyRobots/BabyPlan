# = require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW
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


  check_course_input = (code, capacity, price, price_pay, length, date, speaker, address, date_in_calendar, min_age, max_age, school_id) ->
    if code == "" || capacity == "" || price_pay == "" || length == "" || date == "" || speaker == "" || address == "" || school_id == ""
      $.page_notification("请将信息补充完整")
      return false
    if !$.isNumeric(capacity) || parseInt(capacity) <= 0
      $.page_notification("请填写正确的课程容量")
      return false
    if !$.isNumeric(price) || parseInt(price) < 0
      $.page_notification("请填写正确的市场价")
      return false
    if !$.isNumeric(price_pay) || parseInt(price_pay) < 0
      $.page_notification("请填写正确的公益价")
      return false
    if !$.isNumeric(length) || parseInt(length) <= 0
      $.page_notification("请填写正确的课次")
      return false
    if parseInt(length) != date_in_calendar.length
      $.page_notification("课次与上课时间不匹配")
      return false
    if min_age != "" && !$.isNumeric(min_age) || parseInt(min_age) < 0
      $.page_notification("请填写正确的最小适龄")
      return false
    if max_age != "" && !$.isNumeric(max_age) || parseInt(max_age) < 0 || parseInt(max_age) < parseInt(min_age)
      $.page_notification("请填写正确的最大适龄")
      return false
    return true

  $(".end-btn").click ->
    name = $("#course-name").val()
    available = !$("#unshelve").is(":checked")
    capacity = parseInt($("#course-capacity").val())
    price = $("#course-price").val()
    price_pay = $("#public-price").val()
    length = parseInt($("#course-length").val())
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    address = $("#course-address").val()
    min_age = $("#min-age").val()
    max_age = $("#max-age").val()
    school_id = $("#school_id").val()
    desc = editor.$txt.html()
    code = $(".num-box").text()
    console.log(school_id)
    fc_events = $('#calendar').fullCalendar('clientEvents')
    date_in_calendar = []

    $.each(
      fc_events,
      (index, fc_event) ->
        date_in_calendar.push(fc_event.start._i + "," + fc_event.end._i)
    )
    ret = check_course_input(code, capacity, price, price_pay, length, date, speaker, address, date_in_calendar, min_age, max_age, school_id)
    if ret == false
      return

    first_day = date_in_calendar[0]
    start_time = first_day.split(',')[0]
    start_course = start_time

    $.postJSON(
      '/staff/courses/',
      course: {
        available: available
        name: name
        code: code
        capacity: capacity
        price: price
        price_pay: price_pay
        length: length
        date: date
        speaker: speaker
        address: address
        date_in_calendar: date_in_calendar
        min_age: min_age
        max_age: max_age
        school_id: school_id
        desc: desc
        start_course: start_course
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
          else if data.code == COURSE_DATE_UNMATCH
            $.page_notification("课次与上课时间不匹配")
          else
            $.page_notification("服务器出错")
      )


  $( "#datepicker" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+10'
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
    date = $("#datepicker").val().match(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
    if date == null
      $.page_notification("请输入合法的日期", 3000)
      return
    date = date[0]

    start_time = $("#start-time").val().match(/[0-9]{2}:[0-9]{2}:[0-9]{2}/)
    end_time = $("#end-time").val().match(/[0-9]{2}:[0-9]{2}:[0-9]{2}/)
    if start_time == null || end_time == null
      $.page_notification("请输入合法的时间", 3000)
      return
    start_time = start_time[0]
    end_time = end_time[0]

    start_ary = start_time.split(":")
    end_ary = end_time.split(":")
    start_seconds = parseInt(start_ary[0]) * 3600 + parseInt(start_ary[1]) * 60 +parseInt(start_ary[2])
    end_seconds = parseInt(end_ary[0]) * 3600 + parseInt(end_ary[1]) * 60 +parseInt(end_ary[2])
    if start_seconds >= end_seconds
      $.page_notification("结束时间必须在开始时间之后", 3000)
      return

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