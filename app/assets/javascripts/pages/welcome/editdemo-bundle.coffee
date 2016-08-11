#= require wangEditor.min

$(document).ready ->
	# editor = new wangEditor("div1")

	# editor.create()
	# $("#btn1").click ->
 #    html = editor.$txt.html()
 #    console.log html


  editor = new wangEditor("area1")
  # editor.config.uploadImgUrl = '/assets'
  editor.create()
  $("#btn1").click ->
    html = editor.$txt.html()
    console.log html



