$ ->
  if window.first_signin == "true"
    $.mobile_page_notification("请先完善个人资料")

  $( "#datepicker" ).datepicker({
    changeMonth: true,
    changeYear: true
  })
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $("#datepicker").val(window.birthday_str)

  $("#confirm").click ->
    name = $("#name").val()
    birthday = $("#datepicker").val()
    gender = $("#gender").val()
    parent = $("#parent").val()
    address = $("#address").val()

    $.postJSON(
      '/user_mobile/settings/update_profile/',
      {
        profile:
          {
            name: name
            birthday: birthday
            gender: gender
            parent: parent
            address: address
          }
      },
      (data) ->
        if data.success
          if window.first_signin == "true"
            window.location.href = "/user_mobile/feeds?code=" + DONE
          else
            $.mobile_page_notification("已更新")
        else
          $.mobile_page_notification("服务器出错")
      )