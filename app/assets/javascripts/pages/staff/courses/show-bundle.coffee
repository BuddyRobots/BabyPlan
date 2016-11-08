#= require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW
#= require highcharts

Highcharts.setOptions lang:
  contextButtonTitle: '图表导出菜单'
  decimalPoint: '.'
  downloadJPEG: '下载JPEG图片'
  downloadPDF: '下载PDF文件'
  downloadPNG: '下载PNG文件'
  downloadSVG: '下载SVG文件'
  drillUpText: '返回 {series.name}'
  loading: '加载中'
  months: [
    '一月'
    '二月'
    '三月'
    '四月'
    '五月'
    '六月'
    '七月'
    '八月'
    '九月'
    '十月'
    '十一月'
    '十二月'
  ]
  noData: '没有数据'
  numericSymbols: [
    '千'
    '兆'
    'G'
    'T'
    'P'
    'E'
  ]
  printChart: '打印图表'
  resetZoom: '恢复缩放'
  resetZoomTitle: '恢复图表'
  shortMonths: [
    'Jan'
    'Feb'
    'Mar'
    'Apr'
    'May'
    'Jun'
    'Jul'
    'Aug'
    'Sep'
    'Oct'
    'Nov'
    'Dec'
  ]
  thousandsSep: ','
  weekdays: [
    '星期一'
    '星期二'
    '星期三'
    '星期三'
    '星期四'
    '星期五'
    '星期六'
    '星期天'
  ]

$ ->

  $('#gender-statistics').highcharts
    chart:
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false
    colors: ['#90c5fc', '#ffa1a1', '#ED561B', '#DDDF00',
                    '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
    title: text: null
    tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
    plotOptions: pie:
      allowPointSelect: true
      cursor: 'pointer'
      dataLabels: enabled: false
      showInLegend: true
    credits:
         enabled: false
    series: [ {
      type: 'pie'
      name: '性别比例'
      data: [
        [
          '男生'
          60
        ]
        [
          '女生'
          40
        ]
      ]
    } ]

  $('#age-statistics').highcharts
    chart:
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false
    colors: ['#90c5fc', '#7fbaf7', '#67aaef', '#4898e7',
                    '#3388df', '#227dda', '#FF9655', '#FFF263', '#6AF9C4']
    title: text: null
    tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
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
      name: '性别比例'
      data: [
        [
          '0-3岁'
          10
        ]
        [
          '3-6岁'
          15
        ]
        [
          '6-9岁'
          20
        ]
        [
          '9-12岁'
          25
        ]
        [
          '12-15岁'
          20
        ]
        [
          '15-18岁'
          10
        ]
      ]
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
          data: [
            1.0
            2.3
            2.8
            3.2
            4.5
            6.0
            6.6
            7.5
            8.5
            15.3
          ]
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
                            
         
      tooltip: valueSuffix: '人次'
      credits:
           enabled: false
      legend:
        enabled: false
      series: [
        {
          color: '#90c5fc'
          data: [
            100
            99
            97
            95
            97
            91
            93
            85
            88
            5
            96
            97
            91
            93
          ]
        }
      ]

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
      # $('#dialog-confirm').dialog
      #   resizable: false
      #   height: 'auto'
      #   width: 400
      #   modal: true
      #   buttons:
      #     '确定': ->
      #       $(this).dialog 'close'
      #       $("#calendar").fullCalendar('removeEvents', calEvent.id)
      #       return
      #     "取消": ->
      #       $(this).dialog 'close'
      #       return
      # return
  })


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

  $(".unshelve-btn").click ->
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
    $(".unshelve-btn").attr("disabled", true)
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
    $("#course-address").val($("#address-span").text())

    $("#course-num").css("width", $(".num-box").width() - $(".course-num").width()-5)

    $(".edit-btn").toggle()
    $(".finish-btn").toggle()
    is_edit = true

  $(".finish-btn").click ->
    is_edit = false
    disable_repeat()
    $(".class-calendar").toggle()
    $(".calendar-operation-wrapper").toggle()
    $(".calendar-wrapper").css("border", "0")
    $("#calendar").removeClass("edit-calendar").addClass("show-calendar")
    $("#upload-photo").toggle()
    code = $("#course-num").val()
    capacity = $("#course-capacity").val()
    price = $("#course-charge").val()
    price_pay = $("#public-charge").val()
    length = $("#course-times").val()
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
          address: address
          date_in_calendar: date_in_calendar
        }
      },
      (data) ->
        console.log data
        if data.success
          $(".edit-btn").toggle()
          $(".finish-btn").toggle()
          $(".unedit-box").show()
          $(".edit-box").hide()

          $(".unshelve-btn").attr("disabled", false)

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
          $("#address-span").text(address)

          if has_photo
            $("#upload-photo-form").submit()
        else
          $.page_notification "服务器出错，请稍后重试"
    )

  $("#user-review").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()

  $("#register-message").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()

  $("#course-sign").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()

  $("#statistics").click ->
    $(".finish-btn").hide()
    $(".edit-btn").hide()
    $(".unshelve-btn").hide()

  $("#course-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $(".unshelve-btn").show()

  # calender set
  $( "#datepicker" ).datepicker({
        # changeMonth: true,
        # changeYear: true
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

#img upload
  $("#upload-photo").click ->
    if is_edit
      $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
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
        else
          if data.code == USER_NOT_EXIST
            $.page_notification "用户不存在"
          if data.code == COURSE_INST_NOT_EXIST
            $.page_notification "未参加课程"
      )

  $("#class_num").change ->
    $(".code-figure").attr("src", "/assets/web/bigqrcode.png")
