#= require wangEditor.min
# = require moment.min
#= require fullcalendar.min
#= require locale-all
#= require datepicker-zh-TW

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
  
  # has_photo = false

  # can_repeat = false
  # enable_repeat = ->
  #   can_repeat = true
  #   $(".date-btn").addClass("active-btn")
  #   $(".week-btn").addClass("active-btn")

  # disable_repeat = ->
  #   can_repeat = false
  #   $(".date-btn").removeClass("active-btn")
  #   $(".week-btn").removeClass("active-btn")

  # guid = ->
  #   s4 = ->
  #     Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
  #   s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

  # initialLocaleCode = "zh-cn"
  # $("#calendar").fullCalendar({
  #   header:
  #     left: 'prev,next today'
  #     center: 'title'
  #     right: 'month,agendaWeek,agendaDay,listMonth'
  #   locale: initialLocaleCode
  #   weekNumbers: true
  #   navLinks: true
  #   editable: true
  #   eventLimit: true
  #   fixedWeekCount: false
  #   nowIndicator: true
  #   height: 355
  #   # aspectRatio: 2
  #   eventClick: (calEvent, jsEvent, view) ->
  #     $("#calendar").fullCalendar('removeEvents', calEvent.id)
  # })

  check_course_input = (code, name, price, speaker, length) ->
    if code == "" || name == "" || price == "" || speaker == "" || length == ""
      $.page_notification("请将信息补充完整")
      return false
    if !$.isNumeric(price) || parseInt(price) < 0
      $.page_notification("请填写正确的市场价")
      return false
    if !$.isNumeric(length) || parseInt(length) <= 0
      $.page_notification("请填写正确的课次")
      return false
    return true

  $("#finish-btn").click ->
    code = $("#course-code").val()
    price = $("#course-price").val()
    length = parseInt($("#course-length").val())
    speaker = $("#course-speaker").val()
    name = $("#course-name").val()
    desc = editor.$txt.html()
    if desc == ""
      $.page_notification("请补全信息")
      return
    ret = check_course_input(code, name, price, speaker, length)
    if ret == false
      return

    $.postJSON(
      '/staff/courses/',
      course: {
        code: code
        price: price
        length: length
        speaker: speaker
        name: name
        desc: desc
      },
      (data) ->
        if data.success
          location.href = "/staff/courses?profile=template"
        else
          if data.code == COURSE_INST_EXIST
            $.page_notification("课程编号已存在")
      )
  $("#open-now").click ->
    code = $("#course-code").val()
    price = $("#course-price").val()
    length = parseInt($("#course-length").val())
    speaker = $("#course-speaker").val()
    name = $("#course-name").val()
    desc = editor.$txt.html()
    if desc == ""
      $.page_notification("请补全信息")
      return
    ret = check_course_input(code, name, price, speaker, length)
    if ret == false
      return

    $.postJSON(
      '/staff/courses/',
      course: {
        code: code
        price: price
        length: length
        speaker: speaker
        name: name
        desc: desc
      },
      (data) ->
        console.log(data)
        if data.success
          location.href = "/staff/courses/" + data.course_id + "/description"
    )

#   $( "#datepicker" ).datepicker({
#         changeMonth: true,
#         changeYear: true,
#         yearRange : '-20:+10'
#       })
#   $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
#   $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

#   $('#start-time').timepicker({
#     'minTime': '7:00am'
#     'maxTime': '9:00pm'
#     'showDuration': false
#     'timeFormat': 'H:i:s'
#   })
#   $('#end-time').timepicker({
#     'minTime': '7:00am'
#     'maxTime': '9:00pm'
#     'showDuration': false
#     'timeFormat': 'H:i:s'
#   })

#   add_event = ->
#     date = $("#datepicker").val().match(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
#     if date == null
#       $.page_notification("请输入合法的日期", 3000)
#       return
#     date = date[0]

#     start_time = $("#start-time").val().match(/[0-9]{2}:[0-9]{2}:[0-9]{2}/)
#     end_time = $("#end-time").val().match(/[0-9]{2}:[0-9]{2}:[0-9]{2}/)
#     if start_time == null || end_time == null
#       $.page_notification("请输入合法的时间", 3000)
#       return
#     start_time = start_time[0]
#     end_time = end_time[0]

#     start_ary = start_time.split(":")
#     end_ary = end_time.split(":")
#     start_seconds = parseInt(start_ary[0]) * 3600 + parseInt(start_ary[1]) * 60 +parseInt(start_ary[2])
#     end_seconds = parseInt(end_ary[0]) * 3600 + parseInt(end_ary[1]) * 60 +parseInt(end_ary[2])
#     if start_seconds >= end_seconds
#       $.page_notification("结束时间必须在开始时间之后", 3000)
#       return

#     e = {
#       id: guid()
#       title: ""
#       allDay: false
#       start: date + "T" + start_time
#       end: date + "T" + end_time
#     }
#     $("#calendar").fullCalendar('renderEvent', e, true)
#     $("#calendar").fullCalendar("gotoDate", Date.parse(date))
#     enable_repeat()

#   $("#add-event").click ->
#     add_event()

#   $("#datepicker").change ->
#     disable_repeat()

#   $("#start-time").change ->
#     disable_repeat()

#   $("#end-time").change ->
#     disable_repeat()

#   $(".week-btn").click ->
#     if can_repeat == false
#       return
#     date = $("#datepicker").val()
#     next_week = new Date(Date.parse(date) + 7 * 86400000)
#     $("#datepicker").datepicker("setDate", next_week);
#     add_event()

#   $(".date-btn").click ->
#     if can_repeat == false
#       return
#     date = $("#datepicker").val()
#     next_day = new Date(Date.parse(date) + 86400000)
#     $("#datepicker").datepicker("setDate", next_day);
#     add_event()

# #photo upload
#   $("#upload-photo").click ->
#     $("#photo_file").trigger("click")

#   $("#photo_file").change (event) ->
#     if event.target.files[0] == undefined
#       return
#     has_photo = true
#     photo = $("#photo")[0]
#     photo.src = URL.createObjectURL(event.target.files[0])