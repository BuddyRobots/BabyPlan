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

  $(".edit-btn").click ->
    $(".unedit-box").toggle()
    $(".edit-box").toggle()
    $(".shelve").hide()
    $("#name-input").val($("#name-span").text())
    $("#course-num").val($("#num-span").text())
    $("#course-capacity").val($("#capacity-span").text())
    $("#course-charge").val($("#charge-span").text())
    $("#course-times").val($("#times-span").text())
    $("#course-date").val($("#date-span").text())
    $("#course-speaker").val($("#speaker-span").text())
    $("#course-address").val($("#address-span").text())

    $(".notice").show()
    $("#calendar").css("margin-top","15px")
    $("#calendar").css("margin-left","79px")

