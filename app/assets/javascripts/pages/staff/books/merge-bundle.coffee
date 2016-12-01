$ ->
  window.books_id_ary = window.books_id_str.split(',')

  $("#merge-btn").click ->
    $.postJSON(
      '/staff/books/auto_merge',
      { },
      (data) ->
        console.log data
        if data.success == true
          # show the auto merge result
          if (data.book_num != data.group_num)
            $("#auto-merge-book-num").text(data.book_num)
            $("#auto-merge-group-num").text(data.group_num)
            $("#auto-merge-result").removeClass("hide")
            $("#auto-merge-none").addClass("hide")
          else
            $("#auto-merge-result").addClass("hide")
            $("#auto-merge-none").removeClass("hide")
          $.page_notification "操作完成"
        else
          $.page_notification "服务器出错，请稍后重试"
      )

  search = ->
    keyword = $("#search-input").val()
    window.location.href = "/staff/books/merge?keyword=" + keyword + "&books_id_str=" + window.books_id_ary.join(',')

  $(".search-btn").click ->
    search()

  $("#search-input").keydown (event) ->
    code = event.which
    if code == 13
      search()

  $(".add").click ->
    window.books_id_ary.push($(this).closest('tr').attr("data-id"))
    window.location.href = "/staff/books/merge?keyword=" + window.keyword +
                           "&page=" + window.page +
                           "&books_id_str=" + window.books_id_ary.join(',')

  $(".delete").click ->
    id = $(this).closest('tr').attr("data-id")
    index = window.books_id_ary.indexOf(id)
    if index > -1
      window.books_id_ary.splice(index, 1)
    window.location.href = "/staff/books/merge?keyword=" + window.keyword +
                           "&page=" + window.page +
                           "&books_id_str=" + window.books_id_ary.join(',')

  $("input[type=radio").click ->
    if $('input[type=radio]').length > 1
      $("#merge").attr('disabled', false)

  $("#merge").click ->
    default_id = $('input[name=select_default]:checked').closest('tr').attr("data-id")
    $.postJSON(
      '/staff/books/mannual_merge',
      {
        books_id_ary: window.books_id_ary,
        default_id: default_id
      },
      (data) ->
        if data.success == true
          # show the auto merge result
          if (data.book_num != data.group_num)
            $("#auto-merge-book-num").text(data.book_num)
            $("#auto-merge-group-num").text(data.group_num)
            $("#auto-merge-result").removeClass("hide")
            $("#auto-merge-none").addClass("hide")
          else
            $("#auto-merge-result").addClass("hide")
            $("#auto-merge-none").removeClass("hide")
          $.page_notification "操作完成"
        else
          $.page_notification "服务器出错，请稍后重试"
      )