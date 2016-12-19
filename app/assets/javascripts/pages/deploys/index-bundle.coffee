$ ->

  $("#deploy-btn").click ->
    $(this).attr("disabled", true)
    $.postJSON(
      '/deploys',
      {
      },
      (data) ->
        console.log data
        if data.success
          $("#code_update").text(data.stat.pull_result)
          $("#bundle_message").text(data.stat.bundle_result)
          $("#deploy-btn").attr("disabled", false)
    )
