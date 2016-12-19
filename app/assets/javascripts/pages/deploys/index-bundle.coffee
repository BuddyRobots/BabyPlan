$ ->

  $("#deploy-btn").click ->
    address = $("#address").val()
    $(this).attr("disabled", true)
    $.postJSON(
      '/deploys',
      {
        address: address
      },
      (data) ->
        console.log data
        if data.success
          $("#code_update").text(data.pull_result)
          $("#bundle_message").html(data.bundle_result)
          $("#compile_message").text(data.compile_result)
          $("deploy_btn").attr("enabled",true)
    )
