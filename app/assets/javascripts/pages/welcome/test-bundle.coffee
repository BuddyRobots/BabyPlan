
$ ->

  marker = null
  map = null
  window.data = null
  window.p1 = null
  window.p2 = null
  window.p = null

  init = ->
    map = new qq.maps.Map(document.getElementById("container"),
      center: new qq.maps.LatLng(39.916527, 116.397128)   
      )

    qq.maps.event.addListener(
      map,
      'click',
      (d) ->
        console.log d
        window.data = d
        console.log window.data.latLng.lat
        console.log window.data.latLng.lng
       
        p1 = window.data.latLng.lat
        p2 = window.data.latLng.lng
        p = new qq.maps.LatLng(p1, p2)

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