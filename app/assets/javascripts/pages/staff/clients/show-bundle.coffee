

$ ->

  is_edit = false
  # edit-btn pressdown
  $(".edit-btn").click ->
    $(".edit-box").toggle()
    $(".unedit-box").toggle()
    $(".finish-btn").toggle()
    $(".edit-btn").hide()
    $("#name-input").val($("#name-span").text())
    $("#age-input").val($("#age-span").text())
    $("#gender-input").val($("#gender-span").text())
    $("#phone-input").val($("#phone-span").text())
    $("#parent-input").val($("#parent-span").text())
    $("#address-input").val($("#address-span").text())
    is_edit = true

  $("#kids-message").click ->
    if is_edit
      $(".finish-btn").show()
    else
      $(".edit-btn").show()

  $("#course-review").click ->
    $(".edit-btn").hide()
    $(".finish-btn").hide()

  $("#book-review").click ->
    $(".edit-btn").hide()
    $(".finish-btn").hide()

  $(".details").click ->
    span = $(this).find("span")
    row = $(this).closest("tr")
    status = row.next()
    status.toggle()
    if span.hasClass("triangle-down")
      span.removeClass("triangle-down").addClass("triangle-up")
    else
      span.removeClass("triangle-up").addClass("triangle-down")


