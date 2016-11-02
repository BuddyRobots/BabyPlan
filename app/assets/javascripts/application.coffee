# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ui
#= require datepicker-zh-TW
#= require jquery.timepicker
#= require jquery_ujs
#= require bootstrap-sprockets
#= require utility/ajax
#= require utility/console
#= require utility/regex
#= require utility/err_code
#= require handlebars.runtime
#= require ui/widgets/notification
#= require ui/widgets/mobile_notification
#= require extensions/page_notification
#= require extensions/mobile_page_notification
#= require "jweixin-1.0.0"

$ ->
  window.weixin_jsapi_authorize = (api_list) ->
    $.getJSON "/weixin_js_signature?url=" + encodeURIComponent(window.location.href.split('#')[0]), (retval) ->
      if retval.success
        data = retval.data
        wx.config
          debug: false # 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
          appId: data.appid # 必填，公众号的唯一标识
          timestamp: data.timestamp # 必填，生成签名的时间戳
          nonceStr: data.noncestr # 必填，生成签名的随机串
          signature: data.signature # 必填，签名，见附录1
          jsApiList: api_list # 必填，需要使用的JS接口列表，所有JS接口列表见附录2
      else
        $.page_notification "服务器出错"