

$ ->
	$("#book-borrow").click ->
    location.href = "/staff_mobile/books?v=" + new Date().getTime()

  $("#book-transfer").click ->
    location.href = "/staff_mobile/transfers"