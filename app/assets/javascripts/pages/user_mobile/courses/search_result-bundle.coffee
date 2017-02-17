
$ ->

  $(".content-div").on "click", ".item", ->
    cid = $(".item").attr("data-id")
    location.href = "/user_mobile/courses/" + cid

    