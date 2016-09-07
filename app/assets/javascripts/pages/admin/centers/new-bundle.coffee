#= require wangEditor.min

$ ->

  editor = new wangEditor('edit-area')
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

  marker = null

  window.lat = null
  window.lng = null

  init = ->
    map = new qq.maps.Map(document.getElementById("map-container"))

    qq.maps.event.addListener(
      map,
      'click',
      (d) ->
        window.lat = d.latLng.lat
        window.lng = d.latLng.lng
       
        p = new qq.maps.LatLng(window.lat, window.lng)

        if marker != null
          marker.setVisible(false)

        marker = new qq.maps.Marker({
          # 设置Marker的位置坐标
          position: p,
          map: map
          })
        # 自定义Marker图标样式
        size = new qq.maps.Size(30, 30)
        origin = new qq.maps.Point(0, 0)
        anchor = new qq.maps.Point(10, 30)
        icon = new qq.maps.MarkerImage(
          "/assets/dingwei03.png",
          size,
          origin,
          anchor
          )
        marker.setIcon(icon)
        marker.setTitle("test")
      )

  init()

  $(".end-btn").click ->
    name = $("#center-name").val()
    address = $("#center-address").val()
    desc = editor.$txt.html()
    available = $("#available").is(":checked")
    if name == "" || address == "" || desc == ""
      $.page_notification("请补全信息")
      return
    if window.lat == null
      $.page_notification("请在地图上确定具体位置")
      return
    $.postJSON(
      '/admin/centers',
      {
        center: {
          name: name
          address: address
          desc: desc
          available: available
          lat: window.lat
          lng: window.lng
        }
      },
      (data) ->
        console.log data
        if data.success
          location.href = "/admin/centers/" + data.center_id
      )