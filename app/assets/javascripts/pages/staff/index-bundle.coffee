
$ ->
  $(".forget-password").click ->
    $("#signinModal").modal('hide')

  uid = ""
  $("#mobilecode").click ->
    mobile = $("signup-mobile").val()
    console.log mobile
    $.postJSON(
      '/staff/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          uid = data.user_id
        else
          $("#mobile-notice").val("USER_EXIST").show()
          console.log $("#mobile-notice").val()
    )
