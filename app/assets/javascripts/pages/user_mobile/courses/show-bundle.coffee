$ ->

  $(".smallheart").click ->
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
            $(".smallheart").attr("src", window.concern_path)
            $(".smallheart").attr("data-fav", "false")
          else
            $(".smallheart").attr("src", window.unconcern_path)
            $(".smallheart").attr("data-fav", "true")
        else
          $.page_notification "服务器出错，请稍后重试"
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

  $("#refund").click ->
    $("#refundModal").modal("show")

  $("#confirm-refund").click ->
    $.postJSON(
      '/user_mobile/courses/' + window.course_participate_id + '/request_refund',
      { },
      (data) ->
        if data.success
          $.mobile_page_notification("申请已提交，工作人员将在5个工作日内审核")
          $("#refundModal").modal('show')
        else
          $.mobile_page_notification("该课程不允许退款")
          $("#refundModal").modal('show')
      )
