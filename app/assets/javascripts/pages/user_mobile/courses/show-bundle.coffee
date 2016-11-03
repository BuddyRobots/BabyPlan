
$ ->

  # QQ map set
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

  # window.lat = null
  # window.lng = null

  init = ->
    center = new qq.maps.LatLng(39.87601941962116, 116.43310546875)
    map = new qq.maps.Map(document.getElementById("map-container"), {
      center: center,
      zoom: 12
      })

    marker = new qq.maps.Marker({
      # 设置Marker的位置坐标
      position: center,
      map: map
      })
    
    marker.setIcon(icon)
    marker.setTitle("test")
    marker.setVisible(true)
  init()


  # click set marker
    # if window.lat != null
    #   p = new qq.maps.LatLng(window.lat, window.lng)
    #   marker = new qq.maps.Marker({
    #     # 设置Marker的位置坐标
    #     position: p,
    #     map: map
    #     })
     
    #   marker.setIcon(icon)
    #   marker.setTitle("test")
    #   marker.setVisible(true)
    # qq.maps.event.addListener(
    #   map,
    #   'click',
    #   (d) ->
    #     window.lat = d.latLng.lat
    #     window.lng = d.latLng.lng
       
    #     p = new qq.maps.LatLng(window.lat, window.lng)

    #     if marker != null
    #       marker.setVisible(false)

    #     marker = new qq.maps.Marker({
    #       # 设置Marker的位置坐标
    #       position: p,
    #       map: map
    #       })
       
    #     marker.setIcon(icon)
    #     marker.setTitle("test")
    #     marker.setVisible(true)
    #   )

  # init()