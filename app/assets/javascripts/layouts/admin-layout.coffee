$ ->
  if parseInt(window.code) == REQUIRE_SIGNIN
    $.page_notification("请登录管理员系统", 3000)
    $("#signinModal").modal("show")


