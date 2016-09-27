#= require wangEditor.min

$ ->
  # wangEditor
  editor = new wangEditor('edit-box')
  editor.config.menus = [
        'head',
        'img'
     ]
  editor.config.uploadImgUrl = '/materials'
  editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }
  editor.config.hideLinkImg = true
  editor.create()

  # unshelve-btn press-down
  $(".unshelve-btn").click ->
    current_state = "unpublished"
    if $(this).hasClass("published")
      current_state = "published"
    btn = $(this)
    $.postJSON(
      '/staff/announcements/' + window.aid + '/set_publish',
      {
        publish: current_state == "unpublished"
      },
      (data) ->
        if data.success
          $.page_notification("操作完成")
          console.log btn.find("img").attr("src")
          if current_state == "published"
            btn.removeClass("published")
            btn.addClass("unpublished")
            btn.find("span").text("公布")
            btn.find("img").attr("src", "/assets/managecenter/shelve.png")
          else
            btn.addClass("published")
            btn.removeClass("unpublished")
            btn.find("span").text("隐藏")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
      )

  # edit-btn press-down
  $(".edit-btn").click ->
    $(".edit-btn").toggle()
    $(".end-btn").toggle()
    $(".display-box").toggle()
    $(".edit-area").toggle()

    $(".unshelve-btn").attr("disabled", true)
    
    $("#input-caption").val($("#show-caption").text())
    $("#edit-box").html($(".display-content").html())

  $(".end-btn").click ->

    title = $("#input-caption").val()
    content = editor.$txt.html()

    $.putJSON(
      '/staff/announcements/' + window.aid,
      {
        announcement: {
          title: title
          content: content
        }
      },
      (data) ->
        console.log data
        if data.success
          $(".edit-btn").toggle()
          $(".end-btn").toggle()
          $(".display-box").toggle()
          $(".edit-area").toggle()

          $(".unshelve-btn").attr("disabled", false)

          $("#show-caption").text($("#input-caption").val())
          console.log content
          $(".display-content").html(content)
        else
          $.page_notification "服务器出错，请稍后重试"
    )
