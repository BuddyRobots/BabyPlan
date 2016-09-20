

$(document).ready (e) ->
  i
  # 设定每一行的宽度=屏幕宽度+按钮宽度
  $('.line-scroll-wrapper').width $('.line-wrapper').width() + $('.line-btn-delete').width()
  # 设定常规信息区域宽度=屏幕宽度
  $('.line-normal-wrapper').width $('.line-wrapper').width()
  # 设定文字部分宽度（为了实现文字过长时在末尾显示...）
  $('.line-normal-msg').width $('.line-normal-wrapper').width() - 280
  # 获取所有行，对每一行设置监听
  lines = $('.line-normal-wrapper')
  len = lines.length
  lastX = undefined
  lastXForMobile = undefined
  # 用于记录被按下的对象
  pressedObj = undefined
  # 当前左滑的对象
  lastLeftObj = undefined
  # 上一个左滑的对象
  # 用于记录按下的点
  start = undefined
  # 网页在移动端运行时的监听
  i = 0
  while i < len
    lines[i].addEventListener 'touchstart', (e) ->
      lastXForMobile = e.changedTouches[0].pageX
      pressedObj = this
      # 记录被按下的对象 
      # 记录开始按下时的点
      touches = event.touches[0]
      start =
        x: touches.pageX
        y: touches.pageY
      return
    lines[i].addEventListener 'touchmove', (e) ->
      # 计算划动过程中x和y的变化量
      touches = event.touches[0]
      delta =
        x: touches.pageX - (start.x)
        y: touches.pageY - (start.y)
      # 横向位移大于纵向位移，阻止纵向滚动
      if Math.abs(delta.x) > Math.abs(delta.y)
        event.preventDefault()
      return
    lines[i].addEventListener 'touchend', (e) ->
      if lastLeftObj and pressedObj != lastLeftObj
        # 点击除当前左滑对象之外的任意其他位置
        $(lastLeftObj).animate { marginLeft: '0' }, 500
        # 右滑
        lastLeftObj = null
        # 清空上一个左滑的对象
      diffX = e.changedTouches[0].pageX - lastXForMobile
      if diffX < -150
        $(pressedObj).animate { marginLeft: '-160px' }, 500
        # 左滑
        lastLeftObj and lastLeftObj != pressedObj and $(lastLeftObj).animate({ marginLeft: '0' }, 500)
        # 已经左滑状态的按钮右滑
        lastLeftObj = pressedObj
        # 记录上一个左滑的对象
      else if diffX > 150
        if pressedObj == lastLeftObj
          $(pressedObj).animate { marginLeft: '0' }, 500
          # 右滑
          lastLeftObj = null
          # 清空上一个左滑的对象
      return
    ++i
  # 网页在PC浏览器中运行时的监听
  i = 0
  while i < len
    $(lines[i]).bind 'mousedown', (e) ->
      lastX = e.clientX
      pressedObj = this
      # 记录被按下的对象
      return
    $(lines[i]).bind 'mouseup', (e) ->
      if lastLeftObj and pressedObj != lastLeftObj
        # 点击除当前左滑对象之外的任意其他位置
        $(lastLeftObj).animate { marginLeft: '0' }, 500
        # 右滑
        lastLeftObj = null
        # 清空上一个左滑的对象
      diffX = e.clientX - lastX
      if diffX < -150
        $(pressedObj).animate { marginLeft: '-160px' }, 500
        # 左滑
        lastLeftObj and lastLeftObj != pressedObj and $(lastLeftObj).animate({ marginLeft: '0' }, 500)
        # 已经左滑状态的按钮右滑
        lastLeftObj = pressedObj
        # 记录上一个左滑的对象
      else if diffX > 150
        if pressedObj == lastLeftObj
          $(pressedObj).animate { marginLeft: '0' }, 500
          # 右滑
          lastLeftObj = null
          # 清空上一个左滑的对象
      return
    ++i
  return