

$ ->
	# $("#signup-signin").click ->
	# location.href = "/staff/books/+修改"


  $(".bookadd-btn").click ->
    location.href = "/staff/books/new"

  $(".details").click ->
  	location.href = "/staff/books/show"

# search-btn press
  search = ->
    value = $("#appendedInputButton").val()
    location.href = "/staff/books?keyword=" + value + "&page=1"

  $("#search-btn").click ->
    search()

  $("#appendedInputButton").keydown (event) ->
    code = event.which
    if code == 13
      search()