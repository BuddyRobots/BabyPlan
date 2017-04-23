#= require wangEditor.min
#= require tag-it.min

$ ->

  has_cover = false
  has_back = false

  editor = new wangEditor('edit-area')
 
  editor.config.menus = [
        'head',
        'img'
     ]
  editor.config.uploadImgUrl = '/materials'

  editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }

  editor.config.hideLinkImg = true

  editor.create()


  $('#type-tag').tagit
    fieldName: 'skills'
    availableTags: [
      'c++'
      'java'
      'php'
      'javascript'
      'ruby'
      'python'
      'c'
    ]
    autocomplete:
      delay: 0
      minLength: 2
    showAutocompleteOnFocus: false
    removeConfirmation: false
    caseSensitive: true
    allowDuplicates: false
    allowSpaces: false
    readOnly: false
    tagLimit: null
    singleField: false
    singleFieldDelimiter: ','
    singleFieldNode: null
    tabIndex: null
    placeholderText: null
    beforeTagAdded: (event, ui) ->
      console.log ui.tag
      return
    afterTagAdded: (event, ui) ->
      console.log ui.tag
      return
    beforeTagRemoved: (event, ui) ->
      console.log ui.tag
      return
    onTagExists: (event, ui) ->
      console.log ui.tag
      return
    onTagClicked: (event, ui) ->
      console.log ui.tag
      return
    onTagLimitExceeded: (event, ui) ->
      console.log ui.tag
      return
      
  $(".end-btn").click ->
    tags = $("#type-tag").tagit("assignedTags")
    name = $("#book-name").val().trim()
    type = $("#type-tag").val().trim()
    isbn = $("#book-isbn").val().trim()
    age_lower_bound = $("#age-lower-bound").val().trim()
    age_upper_bound = $("#age-upper-bound").val().trim()
    author = $("#book-author").val().trim()
    publisher = $("#book-publisher").val().trim()
    translator = $("#book-translator").val().trim()
    illustrator = $("#book-illustrator").val().trim()
    
    desc = editor.$txt.html()
    if name == "" || isbn == "" || desc == "" || author == "" || publisher == ""
      $.page_notification("请补全信息")
      return

    if !$.isNumeric(age_lower_bound) || !$.isNumeric(age_upper_bound) || parseInt(age_lower_bound) < 0 || parseInt(age_upper_bound) < 0 || parseInt(age_lower_bound) > parseInt(age_upper_bound)
      $.page_notification("请输入合法的年龄限制")
      return

    $.postJSON(
      '/operator/books',
      {
        book_template: {
          name: name
          type: type
          tags: tags
          isbn: isbn
          author: author
          publisher: publisher
          translator: translator
          illustrator: illustrator
          desc: desc
          age_lower_bound: age_lower_bound
          age_upper_bound: age_upper_bound
        }
      },
      (data) ->
        console.log data
        if data.success
          if !has_cover && !has_back
            window.location.href = "/operator/books/" + data.book_template_id
          else
            $("#has_cover").val(has_cover)
            $("#has_back").val(has_back)
            $("#upload-photo-form")[0].action = "/operator/books/" + data.book_template_id + "/upload_photo"
            $("#upload-photo-form").submit()
        else
          if data.code == BOOK_EXIST
            $.page_notification("该书号图书已经存在")
      )

#img upload
  $("#upload-cover").click ->
    $("#cover_file").trigger("click")
  $("#upload-back").click ->
    $("#back_file").trigger("click")

  $("#cover_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_cover = true
    photo = $("#cover-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])
  $("#back_file").change (event) ->
    if event.target.files[0] == undefined
      return
    has_back = true
    photo = $("#back-photo")[0]
    photo.src = URL.createObjectURL(event.target.files[0])
