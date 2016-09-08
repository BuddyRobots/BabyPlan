# = require wangEditor.min

$ ->

  is_edit = false

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

  listener = null

  enable_set_marker = ->
    listener = qq.maps.event.addListener(
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

  disable_set_marker = ->
    qq.maps.event.removeListener(listener)

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



  $("#center-message").click ->
    # $(".edit-btn").show()
    if is_edit == true
      $(".finish-btn").show()
    else
      $(".edit-btn").show()
    $("#unshelve-btn").show()

  $("#center-class").click ->
    $(".edit-btn").hide()
    $(".finish-btn").hide()
    $("#unshelve-btn").hide()

  $("#center-book").click ->
    $(".edit-btn").hide()
    $(".finish-btn").hide()
    $("#unshelve-btn").hide()


  $(".edit-btn").click ->
    $(".unedit-box").toggle()
    $(".shelve").toggle()
    $(".edit-box").toggle()
    $(".map-notice").css("display", "inline-block")
    $("#map-container").css("margin-left", "77px")
    $(".introduce-details").toggle()
    $(".wangedit-area").toggle()

    $("#name-input").val($("#name-span").text())
    $("#center-address").val($("#address-span").text())
    $("#edit-area").html($(".introduce-details").html())

    $(".edit-btn").toggle()
    $(".finish-btn").toggle()

    enable_set_marker()
    is_edit = true

  $(".finish-btn").click ->
    is_edit = false
    name = $("#name-input").val()
    address = $("#center-address").val()
    desc = editor.$txt.html()

    $.putJSON(
      '/admin/centers/' + window.cid,
      {
        center: {
          name: name
          address: address
          desc: desc
          lat: window.lat
          lng: window.lng
        }
      },
      (data) ->
        console.log data
        if data.success
          $(".edit-btn").toggle()
          $(".finish-btn").toggle()
          $(".introduce-details").toggle()
          $(".wangedit-area").toggle()
          $(".unedit-box").show()
          $(".edit-box").hide()

          $(".map-notice").css("display", "none")
          $("#map-container").css("margin-left", "0px")

          $("#unshelve-btn").attr("disabled", false)

          $("#name-span").text(name)
          $("#address-span").text(address)
          $(".introduce-details").html(desc)
          disable_set_marker()
        else
          $.page_notification "服务器出错，请稍后重试"
    )


  $("#unshelve-btn").click ->
    current_state = "unavailable"
    if $(this).hasClass("available")
      current_state = "available"
    btn = $(this)
    $.postJSON(
      '/admin/centers/' + window.cid + '/set_available',
      {
        available: current_state == "unavailable"
      },
      (data) ->
        if data.success
          $.page_notification("操作完成")
          console.log btn.find("img").attr("src")
          if current_state == "available"
            btn.removeClass("available")
            btn.addClass("unavailable")
            btn.find("span").text("开放")
            btn.find("img").attr("src", "/assets/managecenter/shelve.png")
            $(".shelve").text("关闭中")
          else
            btn.addClass("available")
            btn.removeClass("unavailable")
            btn.find("span").text("关闭")
            btn.find("img").attr("src", "/assets/managecenter/unshelve.png")
            $(".shelve").text("开放中")
      )
