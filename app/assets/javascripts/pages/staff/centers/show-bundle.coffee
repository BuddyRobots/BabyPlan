$ ->

  marker = null
  map = null
  geocoder = null
  # 自定义Marker图标样式
  size = new qq.maps.Size(30, 30)
  origin = new qq.maps.Point(0, 0)
  anchor = new qq.maps.Point(10, 30)
  icon = new qq.maps.MarkerImage(
    window.marker_path,
    size,
    origin,
    anchor
    )

  # window.lat = null
  # window.lng = null
  init = ->
    center = new qq.maps.LatLng(window.lat, window.lng)
    map = new qq.maps.Map(document.getElementById("map-container"), {
      center: center,
      zoom: 12
      })
    geocoder = new qq.maps.Geocoder()
    if window.lat != null
      p = new qq.maps.LatLng(window.lat, window.lng)
      marker = new qq.maps.Marker({
        # 设置Marker的位置坐标
        position: p,
        map: map
        })
      marker.setIcon(icon)
      marker.setTitle("test")
      marker.setVisible(true)
  init()

  $("#delete-btn").click ->
    $.deleteJSON(
      "/staff/centers/" + window.cid,
      {},
      (data) ->
        if data.success
          location.href = "/staff/centers"
      )