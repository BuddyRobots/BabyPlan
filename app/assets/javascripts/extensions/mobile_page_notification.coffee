(($) ->
  $.mobile_page_notification = (content, delay) ->
    mobile_notification = $("<div />").appendTo($("body").children()[0]) 
    mobile_notification.mobile_notification
      delay: delay
      content: content
) jQuery
