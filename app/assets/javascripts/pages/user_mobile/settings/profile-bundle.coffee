
$ ->
	
	$( "#datepicker" ).datepicker({
	      # changeMonth: true,
	      # changeYear: true
	    })
	$( "#datepicker" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
	$( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" )