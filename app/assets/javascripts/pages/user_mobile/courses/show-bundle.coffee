$ ->
  
  $(".like-icon").click ->
    fav = $(this).attr("data-fav")
    $.postJSON(
      '/user_mobile/courses/' + window.course_inst_id + '/favorite',
      {
        favorite: fav
      },
      (data) ->
        console.log data
        if data.success
          if fav == "true"
            $(".like-icon").attr("src", window.like_path)
            $(".like-icon").attr("data-fav", "false")
            $.mobile_page_notification("成功收藏该课程", 1000)
          else
            $(".like-icon").attr("src", window.unlike_path)
            $(".like-icon").attr("data-fav", "true")
            $.mobile_page_notification("收藏已取消", 1000)
        else
          $.mobile_page_notification "服务器出错，请稍后重试"
      )


  # QQ map set
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

  init = ->
    center = new qq.maps.LatLng(window.lat, window.lng)
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

  $(".refund").click ->
    $("#confirmModal").modal("show")

  $("#confirm-refund").click ->
    $.postJSON(
      '/user_mobile/courses/' + window.course_participate_id + '/request_refund',
      { },
      (data) ->
        if data.success
          $.mobile_page_notification("退款成功，正在跳转")
          $("#refundModal").modal('hide')
          setTimeout(->
            location.href="/user_mobile/courses/" + window.course_inst_id
          , 2000);
        else
          if data.code == REFUND_TIME_FAIL
            $.mobile_page_notification("该课程距开课不足24小时，已经不能退款！")
      )
