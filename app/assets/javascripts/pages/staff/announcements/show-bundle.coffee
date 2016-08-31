#= require wangEditor.min

$ ->
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

  $(".unpublish").click ->
    $.postJSON(
      '/staff/announcements' + window.aid + "/set_publish",
      {
        is_published: false
      },
      (data) ->
        console.log data
        if data.success
          $(".unshelve-btn").removeClass("unpublish").addClass("publish")
        else
          if data.code == ANNOUNCEMENT_NOT_EXIST
            $.page_notification("公告不存在")
      )


  $("#unshelve-btn").click ->
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
            $("#publish-status").text("未公布").removeClass("declared").addClass("undeclared")
          else
            btn.addClass("published")
            btn.removeClass("unpublished")
            btn.find("span").text("隐藏")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
            $("#publish-status").text("已公布").addClass("declared").removeClass("undeclared")
      )

# edit-btn press-down
  $(".edit-btn").click ->
    $(".edit-btn").toggle()
    $(".unshelve-btn").toggle()
    $(".end-btn").toggle()
    $(".declare-btn").toggle()
    $(".display-box").toggle()
    $(".edit-area").toggle()
    
    $("#input-caption").val($(".caption").text())
    $("#edit-box").html($(".display-content").html())

# end-btn press-down   未完成
  $(".end-btn").click ->
    location.href = "/staff/announcements/show"
    $(".unshelve-btn").toggle()
    $(".declare-btn").toggle()


