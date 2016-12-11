$ ->
  weixin_jsapi_authorize(["chooseImage", "uploadImage"])
  # $("#upload-photo").click ->
  #   $("#photo_file").trigger("click")

  # $("#photo_file").change (event) ->
  #   if event.target.files[0] == undefined
  #     return
  #   has_photo = true
  #   photo = $(".avatar-icon")[0]
  #   photo.src = URL.createObjectURL(event.target.files[0])

  $(".item-box").click ->
    window.location.href = $(this).attr("data-link")

  $("#upload-photo").click ->
    wx.chooseImage
      count: 1
      scanType: ["original", "compressed"]
      sourceType: ['album', 'camera']
      success: (res) ->
        localId = res.localIds[0]
        $(".avatar-icon").attr("src", localId)
        wx.uploadImage
            localId: localId
            isShowProgressTips: 1
            success: (res) ->
              serverId = res.serverId
              $.postJSON(
                '/user_mobile/settings/upload_avatar',
                {
                  server_id: serverId
                },
                (data) ->
                  console.log data
                  if !data.success
                    $.mobile_page_notification "服务器出错，请稍后重试"
                )

  $("#logoff").click ->
    location.href = "/user_mobile/sessions/signout"