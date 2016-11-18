#= require wangEditor.min

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


  $(".end-btn").click ->
    name = $("#course-name").val()
    speaker = $("#course-speaker").val()
    price = $("#course-price").val()
    price_pay = $("#public-price").val()
    code = $("#course-code").val()
    length = $("#course-length").val()
    desc = editor.$txt.html()
    available = $("#available").is(":checked")
    if name == "" || speaker == "" || price == "" || price_pay == "" || desc == "" || code == ""
      $.page_notification("请补全信息")
      return
    $.postJSON(
      '/admin/courses',
      {
        course: {
          name: name
          speaker: speaker
          price: price
          price_pay: price_pay
          length: length
          desc: desc
          code: code
          available: available
        }
      },
      (data) ->
        console.log data
        if data.success
          location.href = "/admin/courses/" + data.course_id
        else
          if data.code == COURSE_CODE_EXIST
            $.page_notification("课程编号已经存在")
          else
            $.page_notification "服务器出错，请稍后重试"
      )

