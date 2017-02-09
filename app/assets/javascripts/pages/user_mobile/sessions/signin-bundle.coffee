#= require jquery.event.drag
#= require jquery.touchSlider

$(document).ready ->
  $('.img_gallery').hover (->
    $('#btn_prev,#btn_next').fadeIn()
    return
  ), ->
    $('#btn_prev,#btn_next').fadeOut()
    return
  $dragBln = false
  $('.main_img').touchSlider
    flexible: true
    speed: 200
    btn_prev: $('#btn_prev')
    btn_next: $('#btn_next')
    paging: $('.point a')
    counter: (e) ->
      $('.point a').removeClass('on').eq(e.current - 1).addClass 'on'
      #图片顺序点切换
      $('.img_font span').hide().eq(e.current - 1).show()
      #图片文字切换
      return
  $('.main_img').bind 'mousedown', ->
    $dragBln = false
    return
  $('.main_img').bind 'dragstart', ->
    $dragBln = true
    return
  $('.main_img a').click ->
    if $dragBln
      return false
    return
  timer = setInterval((->
    $('#btn_next').click()
    return
  ), 5000)
  $('.img_gallery').hover (->
    clearInterval timer
    return
  ), ->
    timer = setInterval((->
      $('#btn_next').click()
      return
    ), 5000)
    return
  $('.main_img').bind('touchstart', ->
    clearInterval timer
    return
  ).bind 'touchend', ->
    timer = setInterval((->
      $('#btn_next').click()
      return
    ), 5000)
    return


  $(".notice-div").click ->
    window.location.href = "/user_mobile/announcements/" + $(this).attr("data-id")