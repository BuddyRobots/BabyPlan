
$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录工作人员后台", 3000)
    $("#signinModal").modal("show")

  $(".modify_password").click ->
    $("#modify_passwordModal").modal("show")

  toggle_forget_password_tip = (wrong) ->
    if (wrong)
      $("#origin-password").addClass("clicked-box")
      $("#confirm-password").addClass("clicked-box")
    else
      $("#origin-password").removeClass("clicked-box")
      $("#confirm-password").removeClass("clicked-box")

  check_forget_signup_input = ->
    console.log "check_signup_input pressed"
    if $("#forget-mobile").val().trim() == "" ||
        $("#forget-mobilecode").val().trim() == "" ||
        $("#forget-password").val().trim() == "" ||
        $("#forget-confirm-password").val().trim() == "" ||
        uid == ""
      $("#forget").addClass("button-disabled")
      $("#forget").removeClass("button-enabled")
    else
      $("#forget").removeClass("button-disabled")
      $("#forget").addClass("button-enabled")
 