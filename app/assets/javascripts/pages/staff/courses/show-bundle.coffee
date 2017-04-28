#= require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW
#= require highcharts
#= require "./_templates/signin_info"

$ ->

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
      height: 350
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

  $(".operation").click ->
    current_state = "unavailable"
    if $(this).hasClass("delete-normal")
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
          if current_state == "available"
            btn.removeClass("delete-normal")
            btn.addClass("new-normal")
            btn.text("上架")
          else
            btn.addClass("delete-normal")
            btn.removeClass("new-normal")
            btn.text("下架")
      )

  $("#delete-btn").click ->
    $.postJSON(
      "/staff/courses/" + window.cid + "/delete_course_inst",
      {},
      (data) ->
        console.log(data)
        if data.success
          location.href = "/staff/courses"
        else
          if data.code == COURSE_PARTICIPATE_EXIST
            $.page_notification("该课程有人报名参加，不能删除", 1000)
      )


  $("#edit-btn").click ->
    $(".operation").attr("disabled", true)
    $("#delete-btn").attr("disabled", true)
    $(".unedit-box").toggle()
    $(".edit-box").toggle()
    $(".class-calendar").toggle()
    $(".calendar-operation-wrapper").toggle()
    $(".calendar-wrapper").css("border", "1px solid #c8c8c8")
    $("#calendar").removeClass("show-calendar").addClass("edit-calendar")
    $("#upload-photo").toggle()
    $("#course-num").val($("#num-span").text())
    $("#course-capacity").val(window.capacity)
    $("#course-charge").val(window.price)
    $("#public-charge").val(window.price_pay)
    $("#course-times").val(window.length)
    $("#course-date").val($("#date-span").text())
    $("#course-speaker").val($("#speaker-span").text())
    $("#course-center").val($("#center-span").text())
    $("#classroom").val($("#classroom-span").text())
    $("#course-num").css("width", $(".num-box").width() - $(".course-num").width()-6)
    $("#edit-btn").toggle()
    $("#finish-btn").toggle()
    is_edit = true



  check_course_input = (code, capacity, price, length, date, speaker, address, date_in_calendar) ->
    if code == "" || capacity == "" || price == "" || length == "" || date == "" || speaker == "" || address == ""
      $.page_notification("请将信息补充完整")
      return false
    if !$.isNumeric(capacity) || parseInt(capacity) <= 0
      $.page_notification("请填写正确的课程容量")
      return false
    if !$.isNumeric(price) || parseInt(price) < 0
      $.page_notification("请填写正确的市场价")
      return false
    if !$.isNumeric(length) || parseInt(length) <= 0
      $.page_notification("请填写正确的课次")
      return false
    if parseInt(length) != date_in_calendar.length
      $.page_notification("课次与上课时间不匹配")
      return false
    return true


  $("#finish-btn").click ->
    code = $("#course-num").val()
    capacity = parseInt($("#course-capacity").val())
    price = $("#course-charge").val()
    price_pay = $("#public-charge").val()
    length = parseInt($("#course-times").val())
    date = $("#course-date").val()
    speaker = $("#course-speaker").val()
    center = $("#course-center").val()
    address = $("#classroom").val()
    fc_events = $('#calendar').fullCalendar('clientEvents')
    date_in_calendar = []

    $.each(
      fc_events,
      (index, fc_event) ->
        date_in_calendar.push(fc_event.start._i + "," + fc_event.end._i)
    )

    ret = check_course_input(code, capacity, price, length, date, speaker, address, date_in_calendar)
    if ret == false
      return

    $.putJSON(
      '/staff/courses/' + window.cid,
      {
        course_inst: {
          code: code
          capacity: capacity
          price: price
          price_pay: price_pay
          length: length
          date: date
          speaker: speaker
          center: center
          address: address
          date_in_calendar: date_in_calendar
        }
      },
      (data) ->
        console.log data
        if data.success
          is_edit = false
          $("#edit-btn").toggle()
          $("#finish-btn").toggle()
          $(".unedit-box").show()
          $(".edit-box").hide()

          $(".operation").attr("disabled", false)
          $("#delete-btn").attr("disabled", false)

          $("#num-span").text(code)
          $("#capacity-span").text(capacity + "人")
          $("#charge-span").text(price + "元")
          $("#public-span").text(price_pay + "元")
          $("#times-span").text(length + "次")
          window.capacity = capacity
          window.price = price
          window.price_pay = price_pay
          window.length = length
          $("#date-span").text(date)
          $("#speaker-span").text(speaker)
          $("#center-span").text(center)

          disable_repeat()
          $(".class-calendar").toggle()
          $(".calendar-operation-wrapper").toggle()
          $(".calendar-wrapper").css("border", "0")
          $("#calendar").removeClass("edit-calendar").addClass("show-calendar")
          $("#upload-photo").toggle()

          if has_photo
            $("#upload-photo-form").submit()
        else
          if data.code == COURSE_DATE_UNMATCH
            $.page_notification "更新失败，课次与上课时间不匹配"
          else if data.code == COURSE_INST_EXIST
            $.page_notification "更新失败，开课编号已存在"
          else
            $.page_notification "服务器出错，请稍后重试"
    )

  $("#user-review").click ->
    $("#finish-btn").hide()
    $("#edit-btn").hide()
    $("#unshelve-btn").hide()
    $("#delete-btn").hide()

  $("#register-message").click ->
    $("#finish-btn").hide()
    $("#edit-btn").hide()
    $("#unshelve-btn").hide()
    $("#delete-btn").hide()

  $("#course-sign").click ->
    $("#finish-btn").hide()
    $("#edit-btn").hide()
    $("#unshelve-btn").hide()
    $("#delete-btn").hide()

  $("#statistics").click ->
    $("#finish-btn").hide()
    $("#edit-btn").hide()
    $("#unshelve-btn").hide()
    $("#delete-btn").hide()

  $("#course-message").click ->
    if is_edit
      $("#finish-btn").show()
    else
      $("#edit-btn").show()
    $("#unshelve-btn").show()
    $("#delete-btn").show()

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

  add_event = ->
    if is_edit == false
      return
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

#img upload
  $("#upload-photo").click ->
    if is_edit
      $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    $(".unedit-photo").attr("src", "")
    if event.target.files[0] == undefined
      return
    has_photo = true
    photo = $(".edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])


  $(".details").click ->
    span = $(this).find("span")
    row = $(this).closest("tr")
    status = row.next()
    status.toggle()
    if span.hasClass("triangle-down")
      span.removeClass("triangle-down").addClass("triangle-up")
    else
      span.removeClass("triangle-up").addClass("triangle-down")

  $(".code-figure").click ->
    class_num = $("#class_num").val()
    console.log class_num
    $.getJSON "/staff/courses/" + window.cid + "/qrcode?class_num=" + class_num, (data) ->
      if data.success
        $(".code-figure").attr("src", data.img_src)
      else
        $.page_notification "服务器出错，请稍后再试"

  $(".sign-btn").click ->
    class_num = $("#class_num").val()
    mobile = $("#sign-mobile").val()
    $.postJSON(
      '/staff/courses/' + window.cid + '/signin_client',
      {
        class_num: class_num
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification "签到完成"
          refresh_signin_info(parseInt(class_num))
        else
          if data.code == USER_NOT_EXIST
            $.page_notification "用户不存在"
          if data.code == COURSE_INST_NOT_EXIST
            $.page_notification "未参加课程"
      )

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

  refresh_signin_info = (class_num) ->
    $.getJSON "/staff/courses/" + window.cid + "/signin_info?class_num=" + class_num, (data) ->
      if data.success
        signin_info_table = $(HandlebarsTemplates["signin_info"](data))
        $("#sign-table").remove()
        $(".sign-status").append(signin_info_table)
      else
        $.mobile_page_notification "服务器出错"

  refresh_signin_info(0)
