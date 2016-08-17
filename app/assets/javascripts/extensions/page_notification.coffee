(($) ->
  $.page_notification = (content, delay) ->
    notification = $("<div />").appendTo("body") 
    notification.notification
      delay: delay
      content: content
) jQuery