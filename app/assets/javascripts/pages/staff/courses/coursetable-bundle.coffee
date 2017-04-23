# = require moment.min
#= require fullcalendar


$ ->
  $ ->
    $('#fc-dateSelect').delegate 'select', 'change', ->
      fcsYear = $('#fcs_date_year').val()
      fcsMonth = $('#fcs_date_month').val()
      $('#calendar').fullCalendar 'gotoDate', fcsYear, fcsMonth
      return
    return
  
  guid = ->
    s4 = ->
      Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

  initialLocaleCode = "zh-cn"
  $("#calendar").fullCalendar({
    buttonText: {
      today: "今天"
      month: "月课表"
      week: "周课表"
    }
    header:
      left: 'basicWeek,month'
      center: 'title'
      right: 'prev,next today'
    locale: initialLocaleCode
    weekNumbers: true
    navLinks: true
    editable: true
    eventLimit: true
    fixedWeekCount: false
    nowIndicator: true
    height: 610
    allDaySlot: false
    weekMode: 'liquid'
    weekNumberTitle: "周"
    timeFormat: "H:mm"
    editable: false
    # slotMinutes: 60
    # minTime: 8
    # maxTime: 21
    
    # aspectRatio: 2
    # eventClick: (calEvent, jsEvent, view) ->
    #   $("#calendar").fullCalendar('removeEvents', calEvent.id)

  })

  parse_calendar_events = ->
    $.getJSON "/staff/courses/calendar_data", (data) ->
      if data.success
        $.each(
          data.course, (index, course) ->
            date_in_calendar = course.date_in_calendar
            $.each(
              date_in_calendar, (index, date) ->
                if date != ""
                  start_str = date.split(",")[0]
                  e = {
                    id: guid()
                    title: course.name
                    color: "#fff"
                    textcolor: "#323232"
                    className: "eventstyle"
                    start: start_str
                    allDay: false
                  }
                  $("#calendar").fullCalendar('renderEvent', e, true)
              )
          )

  parse_calendar_events()


  $(".download-btn").click ->
    $("#tableModal").modal("show")

  $("#confirm-print").click ->
    $("#tableModal").modal("hide")
    

 