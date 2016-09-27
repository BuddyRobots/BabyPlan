$ ->

  $("input").change (event) ->
    output = $("#output")
    output.src = URL.createObjectURL(event.target.files[0])
