

$ ->
	$("#book-borrow").click ->
    location.href = "/staff_mobile/books?v=" + new Date().getTime()

  $("#book-transfer").click ->
    location.href = "/staff_mobile/transfers"

  $("#transfer_out").click ->
  	location.href = "/staff_mobile/transfers/out_list"

  $("#transfer_in").click ->
  	location.href = "/staff_mobile/transfers/in_list"

  $("#transfer_record").click ->
  	location.href = "/staff_mobile/transfers/list"