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
  window.data = null
  map = null
  geocoder = null
  window.p1 = null
  window.p2 = null
  window.p = null
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
       
        marker.setIcon(icon)
        marker.setTitle("test")
      )

  init()

  codeAddress = ->
    address = document.getElementById('address').value
    #对指定地址进行解析
    geocoder.getLocation(address)
    #设置服务请求成功的回调函数
    geocoder.setComplete (result) ->
      map.setCenter(result.detail.location)
      if marker != null
        marker.setVisible(false)
      marker = new qq.maps.Marker(
        map: map
        position: result.detail.location)
      marker.setIcon(icon)
    #若服务请求失败，则运行以下函数
    geocoder.setError ->
      alert '出错了，请输入正确的地址！！！'

  $("#auto-jump-position").click ->
    codeAddress()
    