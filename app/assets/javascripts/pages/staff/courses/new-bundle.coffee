#= require moment.min
#= require fullcalendar.min
#= require locale-all

$ ->
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

  $(".end-btn").click ->
    course_id = window.cid
    available = $("#available").is(":checked")
    code = $("#course-code").val()
    capacity = $("#course-capacity").val()
    price = $("#course-price").val()
    length = $("#course-length").val()
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    address = $("#course-address").val()

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
        length: length
        date: date
        speaker: speaker
        address: address
      },
      (data) ->
        if data.success
          location.href = "/staff/courses/" + data.course_inst_id
        else
          if data.code == COURSE_INST_EXIST
            $.page_notification("课程编号已存在")
          else
            $.page_notification("服务器出错")
      )
