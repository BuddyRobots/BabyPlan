#= require ./_templates/notification
(($) ->
  $.widget "efei.notification",
    options:
      delay: 2000
      content: ""

    _create: ->
      this.element.append(this.hbs(this.options))
      this.element.addClass("notification")
      width = this.element.width()
      that = this
      if width <= 0
        this.element.css "visibility", "hidden"
      else
        this.element.css "visibility", "visible"
        this.element.css "margin-left", - width / 2
        this.element.show()
        if this.options.delay > 0
          timer = window.setTimeout(->
            that.element.fadeOut "slow"
          , that.options.delay)

      this.element.hover (->
        return if !that.element.is(":visible")
        window.clearTimeout timer
      ), ->
        timer = undefined
        return if !that.element.is(":visible")
        if this.options.delay > 0
          timer = window.setTimeout(->
            that.element.fadeOut "slow"
            that.element.css "visibility", "visible"
          , that.options.delay)

    set_delay: (delay) ->
      that = this
      if delay > 0
        timer = window.setTimeout(->
          that.element.fadeOut "slow"
        , delay)
        this.element.hover (->
          return if !that.element.is(":visible")
          window.clearTimeout timer
        ), ->
          timer = undefined
          return if !that.element.is(":visible")
          if this.options.delay > 0
            timer = window.setTimeout(->
              that.element.fadeOut "slow"
              that.element.css "visibility", "visible"
            , delay)

    hbs: (content) ->
      $(HandlebarsTemplates["notification"](content))
) jQuery
