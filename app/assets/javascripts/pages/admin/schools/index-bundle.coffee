
$ ->
  if window.profile == "close"
    $('.nav-tabs a[href="#tab2"]').tab('show')
  # search-btn press
  search = ->
    value = $("#search-input").val()
    location.href = "/admin/schools?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()
      
  
  $(".close").click ->
    $(".unity-input").val("")
    $(".unity-input-num").val("")
    $("#unity-mobile").val("")
    $(".unity-notice").css("visibility", "hidden")
    $(".unity-confirm-btn").addClass("button-disabled")
    $(".unity-confirm-btn").removeClass("button-enabled")

  $('#unityModal').on 'hidden.bs.modal', ->
    $(".unity-input").val("")
    $(".unity-input-num").val("")
    $("#unity-mobile").val("")
    $(".unity-notice").css("visibility", "hidden")
    $(".unity-confirm-btn").addClass("button-disabled")
    $(".unity-confirm-btn").removeClass("button-enabled")

  check_input = ->
    if $(".unity-input").val().trim() == "" || $(".unity-input-num").val().trim() == "" || $("#unity-mobile").val().trim() == ""
      $(".unity-confirm-btn").addClass("button-disabled")
      $(".unity-confirm-btn").removeClass("button-enabled")
    else
      $(".unity-confirm-btn").addClass("button-enabled")
      $(".unity-confirm-btn").removeClass("button-disabled")

  $(".unity-input").keyup ->
    check_input()
    $(".unity-notice").css("visibility", "hidden")
  $(".unity-input-num").keyup ->
    check_input()
  $("#unity-mobile").keyup ->
    check_input()


  $("#confirm").click ->
    name = $("#unity-name").val()
    manager = $("#unity-manager").val()
    mobile = $("#unity-mobile").val()
    available = true
    if !$.isNumeric(mobile)
      $.page_notification("请输入正确的联系方式", 1000)
      return false
    $.postJSON(
      '/admin/schools',
      {
        school: {
          name: name
          manager: manager
          mobile: mobile
          available: available
        }
      },
      (data) ->
        if data.success
          $("#unityModal").modal("hide")
          $.page_notification("操作完成", 1000)
          location.href = "/admin/schools"
        else
          if data.code == UNITY_IS_EXIST
            $(".unity-notice").text("该单位已存在").css({visibility: "visible", color: "#d70c19"})
    )


  # $(".set-available").click ->
  #   current_state = "unavailable"
  #   if $(this).hasClass("link-available")
  #     current_state = "available"
  #   cid = $(this).closest("tr").attr("data-id")
  #   link = $(this)
  #   console.log current_state
  #   $.postJSON(
  #     '/staff/courses/' + cid + '/set_available',
  #     {
  #       available: current_state == "unavailable"
  #     },
  #     (data) ->
  #       console.log data
  #       if data.success
  #         $.page_notification("操作完成")
  #         location.href = "/staff/courses"
  #         # if current_state == "available"
  #         #   link.removeClass("link-available")
  #         #   link.addClass("link-unavailable")
  #         #   link.text("上架")
  #         #   link.closest("tr").removeClass("available")
  #         #   link.closest("tr").addClass("unavailable")
  #         # else
  #         #   link.addClass("link-available")
  #         #   link.removeClass("link-unavailable")
  #         #   link.text("下架")
  #         #   link.closest("tr").addClass("available")
  #         #   link.closest("tr").removeClass("unavailable")
  #     )
  #   return false


 
  