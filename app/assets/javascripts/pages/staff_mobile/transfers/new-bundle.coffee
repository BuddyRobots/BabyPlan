$ ->
	$(".next-btn").click ->
		out_center_id = window.cid
		in_center_id = $("#center-choice").val()
		if (out_center_id == in_center_id)
			$.mobile_page_notification("不能迁至本儿童中心", 3000)
