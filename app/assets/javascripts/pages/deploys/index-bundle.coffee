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
          $("#code_update").text(data.pull_result)
          $("#bundle_message").text(data.bundle_result)
          $("#compile_message").text(data.compile_result)
    )
