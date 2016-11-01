(($) ->
  $.mobile_page_notification = (content, delay) ->
    mobile_notification = $("<div />").appendTo(".content-area") 
    mobile_notification.mobile_notification
      delay: delay
      content: content
) jQuery
