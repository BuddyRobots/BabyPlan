#= require wangEditor.min
#= require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW
#= require highcharts

$ ->

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

  refresh_stat = ->
    $.getJSON "/staff/courses/" + window.cid + "/stat", (data) ->
      if data.success
        $('#gender-statistics').highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          colors: ['#90c5fc', '#ffa1a1', '#a1aeff', '#DDDF00',
                          '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
          plotOptions: pie:
            allowPointSelect: true
            cursor: 'pointer'
            dataLabels: enabled: false
            showInLegend: true
          credits:
               enabled: false
          series: [ {
            type: 'pie'
            name: '人数'
            data: data.stat.gender
          } ]
      
        $('#age-statistics').highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          colors: ['#90c5fc', '#7fbaf7', '#67aaef', '#4898e7',
                          '#3388df', '#a1aeff', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
          plotOptions: pie:
            allowPointSelect: true
            cursor: 'pointer'
            dataLabels: enabled: false
            showInLegend: true
          credits:
            enabled: false
          legend:
            layout: 'vertical'
            align: 'right'
            verticalAlign: 'middle'
          series: [ {
            type: 'pie'
            name: '人数'
            data: data.stat.age
          } ]
      
        $('#nums-statistics').highcharts
            title:
              text: null
            xAxis: 
              title:
                text: '周数'
            yAxis:
              title: text: '报名数量(人次)'
              max: 20
            tooltip: valueSuffix: '人次'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                color: '#90c5fc'
                data: data.stat.num
                pointStart: 1
              }
            ]
      
        $('#attend-statistics').highcharts
            title:
              text: null
            xAxis: 
              title:
                text: '课次'
            yAxis:
              title: text: '出勤率'
              max: 100
              labels:  
                formatter: ->
                  return this.value + '%'  
            tooltip: valueSuffix: '%'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                color: '#90c5fc'
                data: data.stat.signin
                pointStart: 1
              }
            ]
        if data.stat.signup_start_str != undefined && data.stat.signup_start_str != null
          $(".kids-nums .column-title").text("报名情况（从" + data.stat.signup_start_str + "开始）")

      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_stat()

  can_repeat = false
  has_photo = false

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

  is_edit = false

  initialLocaleCode = "zh-cn"
  show_calendar = ->
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
      height: 355
      eventClick: (calEvent, jsEvent, view) ->
        if is_edit == false
          return
        $("#calendar").fullCalendar('removeEvents', calEvent.id)
    })

  if window.profile == "" || window.profile == undefined
    show_calendar()

  $('#course-message').on 'shown.bs.tab', (e) ->
    show_calendar()


  parse_calendar_events = ->
    event_str_ary = (window.date_in_calendar || "").split(';')
    $.each(
      event_str_ary,
      (index, event_str) ->
        if event_str != ""
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

  parse_calendar_events()



  # calender set
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


  $(".details").click ->
    span = $(this).find("span")
    row = $(this).closest("tr")
    status = row.next()
    status.toggle()
    if span.hasClass("triangle-down")
      span.removeClass("triangle-down").addClass("triangle-up")
    else
      span.removeClass("triangle-up").addClass("triangle-down")


  $("#class_num").change ->
    $(".code-figure").attr("src", window.qrcode_path)
    refresh_signin_info(parseInt($(this).val()))

  if window.profile == "participates"
    $("#register-message").trigger('click')

  if window.profile == "reviews"
    $("#user-review").trigger('click')

  $(document).on 'click', '.hide-review', ->
    rid = $(this).attr("data-id")
    hide_review(rid, $(this))

  $(document).on 'click', '.show-review', ->
    rid = $(this).attr("data-id")
    show_review(rid, $(this))


