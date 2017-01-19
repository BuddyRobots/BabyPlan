
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

  window.lat = null
  window.lng = null

  init = ->
    center = new qq.maps.LatLng(39.87601941962116, 116.43310546875)
    map = new qq.maps.Map(document.getElementById("map-container"), {
      center: center,
      zoom: 12
      })
    geocoder = new qq.maps.Geocoder()
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
        marker.setIcon(icon)
        marker.setTitle("test")
      )
  init()

  codeAddress = ->
    address = document.getElementById('center-address').value
    #对指定地址进行解析
    geocoder.getLocation(address)
    #设置服务请求成功的回调函数
    geocoder.setComplete (result) ->
      map.setCenter(result.detail.location)
      if marker != null
        marker.setVisible(false)
      window.lat = result.detail.location.lat
      window.lng = result.detail.location.lng
      marker = new qq.maps.Marker(
        map: map
        position: result.detail.location)
      marker.setIcon(icon)
    #若服务请求失败，则运行以下函数
    geocoder.setError ->
      alert '出错了，请输入正确的地址！！！'

  $("#auto-locate").click ->
    codeAddress()
    
  $("#finish-btn").click ->
    name = $("#center-name").val()
    address = $("#center-address").val()
    if name == "" || address == ""
      $.page_notification("请补全信息")
      return
    if window.lat == null
      $.page_notification("请在地图上确定具体位置")
      return
    $.postJSON(
      '/staff/centers',
      {
        center: {
          name: name
          address: address
          lat: window.lat
          lng: window.lng
        }
      },
      (data) ->
        console.log data
        if data.success != true
          if data.code == CENTER_EXIST
            $.page_notification "儿童中心已存在"
          else
            $.page_notification "服务器出错，请稍后重试"
          return
        else
          location.href = "/staff/centers"
      )

