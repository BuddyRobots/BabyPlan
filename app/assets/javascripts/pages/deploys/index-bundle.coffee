$ ->

  post = (mode, btn) ->
    # $("#" + btn).attr("disabled", true)
    btn.attr("disabled", true)
    deploy_type = mode
    $.postJSON(
      '/deploys',
      {
        deploy_type: deploy_type
      },
      (data) ->
        if data.success
          $("#code_update").text(data.stat.pull_result)
          $("#bundle_message").text(data.stat.bundle_result)
          # $("#" + btn).attr("disabled", false)
          btn.attr("disabled", false)
      )
  $("#deploy_production").click ->
    post("production", $("#deploy_production"))

  $("#deploy_staging").click ->
    post("staging", $("#deploy_staging"))

  $("#deploy_development").click ->
   post("development", $("#deploy-development"))
