#= require bootstrap.min

$ ->
  if window.code == "-6"
    $.page_notification("请登录工作人员后台", 3000)
    $("#signinModal").modal("show")


