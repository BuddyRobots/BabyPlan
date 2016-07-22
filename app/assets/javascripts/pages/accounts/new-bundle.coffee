$ ->

  $("#send-code").click ->
    mobile = $("#mobile").val()
    console.log mobile
    $.postJSON(
      '/accounts',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          console.log "user created"
        else
          console.log "failed"
    )