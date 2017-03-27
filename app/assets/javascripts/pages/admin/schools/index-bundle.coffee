
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

  $(".add-btn").click ->
    $("#unityModal").modal("show")
    $('#myModal').on('show.bs.modal', ->
      {
        $("#unity-confirm").attr("data-action", "new")
    })
    console.log($("#unity-confirm").attr("data-action"))
    

  $(".edit").click ->
    $("#unityModal").modal("show")
    $("#unity-confirm").attr("data-action", "edit")
    name = $(this).closest("tr").attr("data-name")
    manager = $(this).closest("tr").attr("data-manager")
    mobile = $(this).closest("tr").attr("data-mobile")
    window.cid = $(this).closest("tr").attr("data-id")
    $("#unity-name").val(name)
    $("#unity-manager").val(manager)
    $("#unity-mobile").val(mobile)
    $("#confirm-unity").addClass("button-enabled")
    $("#confirm-unity").removeClass("button-disabled")

  $("#confirm-unity").click ->
    type = $(this).attr("data-action")
    # console.log(type)
    name = $("#unity-name").val()
    manager = $("#unity-manager").val()
    mobile = $("#unity-mobile").val()
    available = true
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.page_notification("请输入正确的联系方式", 1000)
      return false
    if type == "new"
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
      return false
    if type == "eidt"
      $.putJSON(
        '/admin/schools/' + window.cid,
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
            if data.code = UNITY_NOT_EXIST
              $(".unity-notice").text("该单位不存在").css({visibility: "visible", color: "#d70c19"})
      )
      return false
        


    
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


 
  