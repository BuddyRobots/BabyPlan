$ ->

  $("#deploy-production").click ->
    $(this).attr("disabled", true)
    deploy_type = "production"
    $.postJSON(
      '/deploys',
      {
        deploy_type: deploy_type
      },
      (data) ->
        console.log data
        if data.success
          $("#code_update").text(data.stat.pull_result)
          $("#bundle_message").text(data.stat.bundle_result)
          $("#deploy-production").attr("disabled", false)
    )

  $("#deploy-staging").click ->
    $(this).attr("disabled", true)
    deploy_type = "staging"
    $.postJSON(
      '/deploys',
      {
        deploy_type: deploy_type
      },
      (data) ->
        console.log data
        if data.success
          $("#code_update").text(data.stat.pull_result)
          $("#bundle_message").text(data.stat.bundle_result)
          $("#deploy-staging").attr("disabled", false)
    )

  $("#deploy-development").click ->
    $(this).attr("disabled", true)
    deploy_type = "development"
    $.postJSON(
      '/deploys',
      {
        deploy_type: deploy_type
      },
      (data) ->
        console.log data
        if data.success
          $("#code_update").text(data.stat.pull_result)
          $("#bundle_message").text(data.stat.bundle_result)
          $("#deploy-development").attr("disabled", false)
    )
