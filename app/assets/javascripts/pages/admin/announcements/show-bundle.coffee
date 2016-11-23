#= require wangEditor.min

$ ->
  has_photo = false
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
  $("#unshelve-btn").click ->
    current_state = "unpublished"
    if $(this).hasClass("published")
      current_state = "published"
    btn = $(this)
    $.postJSON(
      '/admin/announcements/' + window.aid + '/set_publish',
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

    $("#unshelve-btn").attr("disabled", true)
    
    $("#input-caption").val($("#show-caption").text())
    $("#edit-box").html($(".display-content").html())

  $(".end-btn").click ->

    title = $("#input-caption").val()
    content = editor.$txt.html()

    if title == ""
      $.page_notification "请输入标题"
      return
    if content.replace(/(<([^>]+)>)/ig, "").trim() == ""
      $.page_notification "请输入公告内容"
      return

    $.putJSON(
      '/admin/announcements/' + window.aid,
      {
        announcement: {
          title: title
          content: content
        }
      },
      (data) ->
        console.log data
        if data.success != true
          $.page_notification "服务器出错，请稍后重试"
          return
        if has_photo == false
          window.location.href = "/admin/announcements/" + data.announcement_id
        else
          $("#upload-photo-form")[0].action = "/admin/announcements/" + data.announcement_id + "/upload_photo"
          $("#upload-photo-form").submit()


        # console.log data
        # if data.success
        #   $(".edit-btn").toggle()
        #   $(".end-btn").toggle()
        #   $(".display-box").toggle()
        #   $(".edit-area").toggle()

        #   $("#unshelve-btn").attr("disabled", false)

        #   $("#show-caption").text($("#input-caption").val())
        #   console.log content
        #   $(".display-content").html(content)
        # else
        #   $.page_notification "服务器出错，请稍后重试"
    )

#img upload
  $("#upload-photo").click ->
    $("#photo_file").trigger("click")

  $("#photo_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_photo = true
    photo = $(".edit-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])