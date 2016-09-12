
$ ->
  if window.code == REQUIRE_SIGNIN
    $.page_notification("请登录工作人员后台", 3000)
    $("#signinModal").modal("show")
