$ ->
  weixin_jsapi_authorize(["chooseImage"])
  # $("#upload-photo").click ->
  #   $("#photo_file").trigger("click")

  # $("#photo_file").change (event) ->
  #   if event.target.files[0] == undefined
  #     return
  #   has_photo = true
  #   photo = $(".avatar-icon")[0]
  #   photo.src = URL.createObjectURL(event.target.files[0])


  $("#upload-photo").click ->
    wx.chooseImage
      count: 1
      scanType: ["original", "compressed"]
      sourceType: ['album', 'camera']
      success: (res) ->
        localIds = res.localIds
        alert(localIds)
