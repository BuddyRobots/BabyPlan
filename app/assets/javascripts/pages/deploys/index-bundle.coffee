$ ->

  $("#deploy-btn").click ->
    $.postJSON(
      '/deploys',
      {
      },
      (data) ->
        console.log data
    )
