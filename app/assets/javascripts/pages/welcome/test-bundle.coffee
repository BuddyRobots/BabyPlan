
$ ->

  window.data = null
  window.p1 = null

  window.p2 = null
  window.p = null
  size = new qq.maps.Size(30, 30)
  origin = new qq.maps.Point(0, 0)
  anchor = new qq.maps.Point(10, 30)
  center = new qq.maps.LatLng(39.982163, 116.306070);

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
        marker = new qq.maps.Marker({
          # 设置Marker的位置坐标
          position: p,
          map: map,
          # 自定义Marker图标样式
          icon: new qq.maps.MarkerImage(
            "/assets/dingwei03.png",
            size,
            origin,
            anchor
            ),
          # 设置Marker标题，鼠标划过Marker时显示
          title: '测试',
          # 设置Marker的可见性，为true时可见,false时不可见
          visible: true,
        })
      )

  init()