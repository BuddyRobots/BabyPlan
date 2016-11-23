
$ ->
  
  marker = null
  map = null
  geocoder = null
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
 

  init = ->
    map = new qq.maps.Map(document.getElementById("map-container"), {
      center: new qq.maps.LatLng(window.lat, window.lng),
      zoom: 12
      })
    p = new qq.maps.LatLng(window.lat, window.lng)
    marker = new qq.maps.Marker({
      # 设置Marker的位置坐标
      position: p,
      map: map
      })
    marker.setIcon(icon)
    marker.setTitle("儿童中心地址")
    marker.setVisible(true)
   
  init()

    

  