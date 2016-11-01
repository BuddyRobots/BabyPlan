$ ->
  $(".next").click ->
    password = $("#password").val()
    password_confirm = $("#password_confirm").val()
    if password != password_confirm
      $.mobile_page_notification("密码不一致", 3000)
      return
    $.postJSON(
      '/user_mobile/sessions/update_password',
      {
        uid: window.uid
        password: password
      },
      (data) ->
        console.log data
        if data.success
          location.href="/user_mobile/sessions/new?code=" + DONE
        else
          $.mobile_page_notification("服务器错误", 3000)
      )
