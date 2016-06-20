(($) ->

  $.fn.yxMobileSlider = (settings) ->
    defaultSettings = 
      width: 600
      height: 310
      during: 3000
      speed: 30
    settings = $.extend(true, {}, defaultSettings, settings)
    @each ->
      _this = $(this)
      s = settings
      startX = 0
      startY = 0
      #触摸开始时手势横纵坐标 
      temPos = undefined
      #滚动元素当前位置
      iCurr = 0
      #当前滚动屏幕数
      timer = null
      #计时器
      oMover = $('ul', _this)
      #滚动元素
      oLi = $('li', oMover)
      #滚动单元
      num = oLi.length
      #滚动屏幕数
      oPosition = {}
      #触点位置
      moveWidth = s.width
      #滚动宽度
      #初始化主体样式
      #自动运动

      autoMove = ->
        timer = setInterval(doMove, s.during)
        return

      #停止自动运动

      stopMove = ->
        clearInterval timer
        return

      #运动效果

      doMove = ->
        iCurr = if iCurr >= num - 1 then 0 else iCurr + 1
        doAnimate -moveWidth * iCurr
        oFocus.eq(iCurr).addClass('current').siblings().removeClass 'current'
        return

      #绑定触摸事件

      bindTochuEvent = ->
        oMover.get(0).addEventListener 'touchstart', touchStartFunc, false
        oMover.get(0).addEventListener 'touchmove', touchMoveFunc, false
        oMover.get(0).addEventListener 'touchend', touchEndFunc, false
        return

      #获取触点位置

      touchPos = (e) ->
        touches = e.changedTouches
        l = touches.length
        touch = undefined
        tagX = undefined
        tagY = undefined
        i = 0
        while i < l
          touch = touches[i]
          tagX = touch.clientX
          tagY = touch.clientY
          i++
        oPosition.x = tagX
        oPosition.y = tagY
        oPosition

      #触摸开始

      touchStartFunc = (e) ->
        clearInterval timer
        touchPos e
        startX = oPosition.x
        startY = oPosition.y
        temPos = oMover.position().left
        return

      #触摸移动 

      touchMoveFunc = (e) ->
        touchPos e
        moveX = oPosition.x - startX
        moveY = oPosition.y - startY
        if Math.abs(moveY) < Math.abs(moveX)
          e.preventDefault()
          oMover.css left: temPos + moveX
        return

      #触摸结束

      touchEndFunc = (e) ->
        `var moveX`
        `var moveX`
        touchPos e
        moveX = oPosition.x - startX
        moveY = oPosition.y - startY
        if Math.abs(moveY) < Math.abs(moveX)
          if moveX > 0
            iCurr--
            if iCurr >= 0
              moveX = iCurr * moveWidth
              doAnimate -moveX, autoMove
            else
              doAnimate 0, autoMove
              iCurr = 0
          else
            iCurr++
            if iCurr < num and iCurr >= 0
              moveX = iCurr * moveWidth
              doAnimate -moveX, autoMove
            else
              iCurr = num - 1
              doAnimate -(num - 1) * moveWidth, autoMove
          oFocus.eq(iCurr).addClass('current').siblings().removeClass 'current'
        return

      #移动设备基于屏幕宽度设置容器宽高

      mobileSettings = ->
        moveWidth = $(window).width()
        iScale = $(window).width() / s.width
        _this.height(s.height * iScale).width $(window).width()
        oMover.css left: -iCurr * moveWidth
        return

      #动画效果

      doAnimate = (iTarget, fn) ->
        oMover.stop().animate { left: iTarget }, _this.speed, ->
          if fn
            fn()
          return
        return

      #判断是否是移动设备

      isMobile = ->
        if navigator.userAgent.match(/Android/i) or navigator.userAgent.indexOf('iPhone') != -1 or navigator.userAgent.indexOf('iPod') != -1 or navigator.userAgent.indexOf('iPad') != -1
          true
        else
          false

      _this.width(s.width).height(s.height).css
        position: 'relative'
        overflow: 'hidden'
        margin: '0 auto'
      #设定容器宽高及样式
      oMover.css
        position: 'absolute'
        left: 0
      oLi.css
        float: 'left'
        display: 'inline'
      $('img', oLi).css
        width: '100%'
        height: '100%'
      #初始化焦点容器及按钮
      # _this.append '<div class="focus"><div></div></div>'
      # oFocusContainer = $('.focus')
      # i = 0
      # while i < num
      #   $('div', oFocusContainer).append '<span></span>'
      #   i++
      # oFocus = $('span', oFocusContainer)
      # oFocusContainer.css
      #   minHeight: $(this).find('span').height() * 2
      #   position: 'absolute'
      #   bottom: 0
      #   background: 'rgba(0,0,0,0.5)'
      # $('span', oFocusContainer).css
      #   display: 'block'
      #   float: 'left'
      #   cursor: 'pointer'
      # $('div', oFocusContainer).width(oFocus.outerWidth(true) * num).css
      #   position: 'absolute'
      #   right: 10
      #   top: '50%'
      #   marginTop: -$(this).find('span').width() / 2
      # oFocus.first().addClass 'current'
      #页面加载或发生改变
      $(window).bind 'resize load', ->
        if isMobile()
          mobileSettings()
          bindTochuEvent()
        oLi.width(_this.width()).height _this.height()
        #设定滚动单元宽高
        oMover.width num * oLi.width()
        # oFocusContainer.width(_this.width()).height(_this.height() * 0.15).css zIndex: 2
        #设定焦点容器宽高样式
        _this.fadeIn 300
        return
      #页面加载完毕BANNER自动滚动
      autoMove()
      #PC机下焦点切换
      # if !isMobile()
      #   oFocus.hover (->
      #     iCurr = $(this).index() - 1
      #     stopMove()
      #     doMove()
      #     return
      #   ), ->
      #     autoMove()
      #     return
      # return

  return
) jQuery