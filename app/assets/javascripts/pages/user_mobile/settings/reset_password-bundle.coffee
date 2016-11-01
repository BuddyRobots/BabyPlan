$ ->
  $(".next").click ->
    password = $("#password").val()
    new_password = $("#new_password").val()
    password_confirm = $("#password_confirm").val()
    if new_password != password_confirm
      $.mobile_page_notification("密码不一致", 3000)
      return
    $.postJSON(
      '/user_mobile/settings/update_password',
      {
        old_password: password
        new_password: new_password
      },
      (data) ->
        if data.success
          location.href="/user_mobile/settings/account?code=" + DONE
        else
          if data.code == WRONG_PASSWORD
            $.mobile_page_notification("原密码不正确", 3000)
    )
