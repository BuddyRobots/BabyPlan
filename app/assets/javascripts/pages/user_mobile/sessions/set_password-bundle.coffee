$ ->
  $(".next").click ->
    password = $("#password").val()
    password_confirm = $("#password_confirm").val()
    if password == ""
      $.mobile_page_notification("请输入新密码", 2000)
      return
    if password != password_confirm
      $.mobile_page_notification("密码不一致", 2000)
      return
    $.postJSON(
      '/user_mobile/sessions/update_password',
      {
        uid: window.uid
        password: password
      },
      (data) ->
        if data.success
          location.href="/user_mobile/sessions/new?code=" + DONE
        else
          $.mobile_page_notification("服务器错误", 3000)
      )
