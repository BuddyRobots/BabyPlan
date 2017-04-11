$ ->
  if window.unnamed == "true"
    $.mobile_page_notification("请先完善个人资料")

  if $("#choice").is(":checked")
    $("#num1, #num2, #num3").hide()

  $( "#datepicker" ).datepicker({
    changeMonth: true,
    changeYear: true,
    yearRange : '-20:+0'
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
    is_pregnant = $("#choice").is(":checked")
    if is_pregnant == true && parent.trim() == ""
      $.mobile_page_notification("请填写家长姓名")
      return false
    
    if is_pregnant == false && name.trim() == ""
      $.mobile_page_notification("请填写儿童姓名")
      return false

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
            is_pregnant: is_pregnant
          }
      },
      (data) ->
        if data.success
          if window.unnamed == "true"
            window.location.href = "/user_mobile/feeds"
          else
            $.mobile_page_notification("已更新")
        else
          $.mobile_page_notification("服务器出错")
      )

  $("#choice").click ->
    if $(this).attr("checked", "checked")
      $("#num1, #num2, #num3").toggle(400)
