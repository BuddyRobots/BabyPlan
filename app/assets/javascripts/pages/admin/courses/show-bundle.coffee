#= require wangEditor.min

$ ->

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