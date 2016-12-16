$ ->

  $("#deploy-btn").click ->
    address = $("#address").val()
    $.postJSON(
      '/deploys',
      {
        address: address
      },
      (data) ->
        console.log data
        if data.success
          
    )
