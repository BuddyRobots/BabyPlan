
$ ->
	$("#borrow-book").click ->
    location.href = "/staff_mobile/books/borrow"

  $("#book-transfer").click ->
    location.href = "/staff_mobile/transfers"

  $("#book-borrow").click ->
    location.href = "/staff_mobile/books?v=" + new Date().getTime()


