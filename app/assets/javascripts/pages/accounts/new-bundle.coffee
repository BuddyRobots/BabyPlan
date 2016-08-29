#= require wangEditor.min


$(document).ready ->

  uid = ""

  $("#send-code").click ->
    mobile = $("#mobile").val()
    console.log mobile
    $.postJSON(
      '/accounts',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.condition
          console.log "user created"
          console.log data.user_id
          uid = data.user_id
        else
          console.log "failed"
    )



  $("#sign-up").click ->
    name = $("#name").val()
    password = $("#password").val()
    code = $("#code").val()
    console.log name
    $.postJSON(
      '/accounts/' + uid + '/activate',
      {
        name: name,
        password: password,
        code: code
      },
      (data) ->
        if data.request
          alert("注册成功")
        else
          alert("验证码输入错误")
      )



  editor = new wangEditor("area1")
  # editor.config.uploadImgUrl = '/assets'
  editor.create()
  $("#btn1").click ->
    html = editor.$txt.html()
    console.log html
    $.postJSON(
      '/accounts',
      {
        html: html
      },
      (data) ->
        console.log data
      )



