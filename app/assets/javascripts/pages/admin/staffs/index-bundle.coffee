
$ ->
  if window.profile == "operator"
    $('.nav-tabs a[href="#tab2"]').tab('show')

  search = ->
    value = $("#search-input").val()
    location.href = "/admin/staffs?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()


  $(".close").click ->
    $(".entry-input").val("")
    $(".entry-input-num").val("")
    $("#entry-mobile").val("")
    $("#entry-password").val("")
    $(".entry-notice").css("visibility", "hidden")
    $(".entry-confirm-btn").addClass("button-disabled")
    $(".entry-confirm-btn").removeClass("button-enabled")

  $('#entryModal').on 'hidden.bs.modal', ->
    $(".entry-input").val("")
    $(".entry-input-num").val("")
    $("#entry-mobile").val("")
    $("#entry-password").val("")
    $(".entry-notice").css("visibility", "hidden")
    $(".entry-confirm-btn").addClass("button-disabled")
    $(".entry-confirm-btn").removeClass("button-enabled")

  check_input = ->
    if $(".entry-input").val().trim() == "" || $(".entry-input-num").val().trim() == "" || $("#entry-mobile").val().trim() == "" || $("#entry-password").val().trim() == ""
      $(".entry-confirm-btn").addClass("button-disabled")
      $(".entry-confirm-btn").removeClass("button-enabled")
    else
      $(".entry-confirm-btn").addClass("button-enabled")
      $(".entry-confirm-btn").removeClass("button-disabled")

  $(".entry-input").keyup ->
    check_input() 
  $(".entry-input-num").keyup ->
    check_input()
  $("#entry-mobile").keyup ->
    check_input()
    $(".entry-notice").css("visibility", "hidden")
  $("#entry-password").keyup ->
    check_input()

  $(".add-btn").click ->
    $("#entryModal").modal("show")
    $("#confirm-entry").attr("data-btn", "new")
      

  $(".edit").click ->
    $("#entryModal").modal("show")
    $("#confirm-entry").attr("data-btn", "edit")
    name = $(this).closest("tr").attr("data-name")
    company = $(this).closest("tr").attr("data-company")
    mobile = $(this).closest("tr").attr("data-mobile")
    window.oid = $(this).closest("tr").attr("data-id")
    $("#entry-name").val(name)
    $("#entry-company").val(company)
    $("#entry-mobile").val(mobile)

  $("#confirm-entry").click ->
    type = $(this).attr("data-btn")
    console.log(type)
    name = $("#entry-name").val()
    company = $("#entry-company").val()
    mobile = $("#entry-mobile").val()
    password = $("#entry-password").val().trim()
    available = true
    mobile_retval = $.regex.isMobile(mobile)
    if mobile_retval == false
      $.page_notification("请输入正确的联系方式", 1000)
      return false
    if password == ""
      $.page_notification("请输入密码", 1000)
      return false
    if type == "new"
      $.postJSON(
        '/admin/staffs',
        {
          operator: {
            name: name
            company: company
            mobile: mobile
            password: password
            available: available
          }
        },
        (data) ->
          if data.success
            $("#entryModal").modal("hide")
            $.page_notification("操作完成", 1000)
            location.href = "/admin/staffs"
          else
            if data.code == OPERATOR_IS_EXIST
              $(".entry-notice").text("该录入员已存在").css({visibility: "visible", color: "#d70c19"})

      )
    if type == "edit"
      $.putJSON(
        '/admin/staffs/' + window.oid,
        {
          operator: {
            name: name
            company: company
            mobile: mobile
            password: password
          }
        },
        (data) ->
          if data.success
            $("#entryModal").modal("hide")
            $.page_notification("操作完成", 1000)
            location.href = "/admin/staffs"
          else
            if data.code == OPERATOR_NOT_EXIST
              $(".entry-notice").text("该录入员不存在").css({visibility: "visible", color: "#d70c19"})
      )

  $(".set-available").click ->
    current_state = "unavailable"
    if $(this).hasClass("link-available")
      current_state = "available"
    oid = $(this).closest("tr").attr("data-id")
    link = $(this)
    console.log current_state
    $.postJSON(
      '/admin/staffs/' + oid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        console.log data
        if data.success
          $.page_notification("操作完成", 1000)
          if current_state == "available"
            link.removeClass("link-available")
            link.addClass("link-unavailable")
            link.text("解锁")
            link.closest("tr").removeClass("available")
            link.closest("tr").addClass("unavailable")
          else
            link.addClass("link-available")
            link.removeClass("link-unavailable")
            link.text("锁定")
            link.closest("tr").addClass("available")
            link.closest("tr").removeClass("unavailable")
        else
          if data.code == OPERATOR_NOT_EXIST
            $.page_notification("该录入员不存在", 1000)
      )
    return false

  


  