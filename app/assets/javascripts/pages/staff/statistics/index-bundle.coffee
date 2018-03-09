#= require highcharts

$ ->

  refresh_client_stat = ->
    $.getJSON "/staff/statistics/client_stats/", (data) ->
      if data.success
        $('#gender-statistics').highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          colors: ['#90c5fc', '#ffa1a1', '#a1aeff', '#DDDF00',
                          '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
          plotOptions: pie:
            allowPointSelect: true
            cursor: 'pointer'
            dataLabels: enabled: false
            showInLegend: true
          credits:
               enabled: false
          legend:
            itemStyle:
                color: '#969696'
          series: [ {
            type: 'pie'
            name: '人数'
            data: data.stat.gender
          } ]

        $('#age-statistics').highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          colors: ['#90c5fc', '#7fbaf7', '#67aaef', '#4898e7',
                          '#3388df', '#a1aeff', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
          plotOptions: pie:
            allowPointSelect: true
            cursor: 'pointer'
            dataLabels: enabled: false
            showInLegend: true
          credits:
            enabled: false
          legend:
            layout: 'vertical'
            align: 'right'
            verticalAlign: 'middle'
            itemStyle:
                color: '#969696'
          series: [ {
            type: 'pie'
            name: '人数'
            data: data.stat.age
          } ]
        console.log data.stat.num
        $('#nums-statistics').highcharts
            title:
              text: null
            xAxis: 
              title:
                text: '周数'
            yAxis:
              title: text: '儿童数量'
            # tooltip: valueSuffix: '千'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                pointStart: 1
                data: data.stat.num
                # data: [
                #   11
                #   15
                #   15
                #   94
                #   147
                #   179
                #   210
                #   258
                #   310
                #   328
                # ]
              }
            ]
      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_client_stat()

  refresh_course_stat = ->
    duration = $("#course-quick-choice").val()
    start_date = $("#datepicker-1").val()
    end_date = $("#datepicker-2").val()
    $.getJSON "/staff/statistics/course_stats?duration=" + duration + "&start_date=" + start_date + "&end_date=" + end_date, (data) ->
      if data.success
        $("#total-signup").text(data.stat.total_signup)
        $("#total-money").text(data.stat.total_income)

        $('#register-statistics').highcharts
            title:
              text: null
            xAxis: 
              tickInterval: 1
              title:
                text: data.stat.signup_time_unit
            yAxis:
              title: text: '报名数量(人次)'
            tooltip: valueSuffix: '人次'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                color: '#90c5fc'
                data: data.stat.signup_num
                pointStart: 1
              }
            ]

        $('#income-statistics').highcharts
          chart: type: 'column'
          title: text: null
          xAxis:
            title:
              text: data.stat.income_time_unit
          yAxis:
            min: 0
            title: text: '课程收入(元)'
          tooltip: formatter: ->
            '<b>' + @x + '</b><br/>' + @series.name + ': ' + @y + '<br/>' + 'Total: ' + @point.stackTotal
          plotOptions: column:
            stacking: 'normal'
          credits:
               enabled: false
          legend:
            enabled: false
          series: [
            {
              name: "政府补贴"
              color: '#227dda'
              data: data.stat.allowance
              pointStart: 1
            }
            {
              name: "个人支付"
              color: '#90c5fc'
              data: data.stat.income
              pointStart: 1
            }
          ]

        $('#school-income-statistics').highcharts
          chart:
            type: 'column'
          title: text: null
          xAxis:
            type: 'category'
          yAxis:
            min: 0
            title: text: '授课单位收入(元)'
          legend: enabled: false
          tooltip: valueSuffix: '元'
          credits:
               enabled: false
          plotOptions: series: point: events: click: (event) ->
            if previousPoint
              previousPoint.update color: '#90c5fc'
            previousPoint = this
            this.update color: '#227dda'
            return
          series: [ {
            name: '授课单位收入'
            data: data.stat.income_school
          } ]
      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_course_stat()

  $("#course-quick-choice").change ->
    $("#datepicker-1").val("")
    $("#datepicker-2").val("")
    refresh_course_stat()
  $("#course-search-btn").click ->
    $("#course-quick-choice").val(-1)
    refresh_course_stat()

  refresh_book_stat = ->
    duration = $("#book-quick-choice").val()
    start_date = $("#datepicker-3").val()
    end_date = $("#datepicker-4").val()
    $.getJSON "/staff/statistics/book_stats?duration=" + duration + "&start_date=" + start_date + "&end_date=" + end_date, (data) ->
      if data.success
        $("#total-borrow").text(data.stat.total_borrow)
        $('#borrow-statistics').highcharts
            title:
              text: null
            xAxis: 
              tickInterval: 1
              title:
                # text: '周数'
                text: data.stat.borrow_time_unit
            yAxis:
              title: text: '借阅数量(人次)'
            tooltip: valueSuffix: '人次'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                color: '#90c5fc'
                data: data.stat.borrow_num
                pointStart: 1
                # data: [
                #   1.0
                #   2.3
                #   2.8
                #   3.2
                #   4.5
                #   6.0
                #   6.6
                #   7.5
                #   8.5
                #   15.3
                #   32
                #   55
                # ]
              }
            ]

        $('#collect-statistics').highcharts
            title:
              text: null
            xAxis: 
              tickInterval: 1
              title:
                # text: '周数'
                text: data.stat.stock_time_unit
            yAxis:
              title: text: '书籍数量(本)'
            tooltip: valueSuffix: '本'
            credits:
                 enabled: false
            legend:
              enabled: true
              verticalAlign: 'top'
              itemStyle:
                color: '#969696'
            series: [
              {
                name: '全部绘本'
                color: '#90c5fc'
                data: data.stat.stock_num
                pointStart: 1
                # data: [
                #   1.0
                #   2.3
                #   2.8
                #   3.2
                #   4.5
                #   6.0
                #   6.6
                #   7.5
                #   8.5
                #   15.3
                #   32
                #   55
                # ]
              }
              {
                name: '借出绘本'
                color: '#227dda'
                data: data.stat.off_shelf_num
                pointStart: 1
                # data: [
                #   5
                #   8
                #   11
                #   15
                #   20
                #   23
                #   26
                #   32
                #   40
                #   49
                #   55
                #   70
                # ]
              }
            ]
      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_book_stat()

  $("#book-quick-choice").change ->
    $("#datepicker-3").val("")
    $("#datepicker-4").val("")
    refresh_book_stat()
  $("#book-search-btn").click ->
    $("#book-quick-choice").val(-1)
    refresh_book_stat()


  $( "#datepicker-1" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+10'
      })
  $( "#datepicker-1" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-1" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-2" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+10'
      })
  $( "#datepicker-2" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-2" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-3" ).datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange : '-20:+10'
    })
  $( "#datepicker-3" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-3" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-4" ).datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange : '-20:+10'
    })
  $( "#datepicker-4" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-4" ).datepicker( "option", "dateFormat", "yy-mm-dd" ) 

  $("#cash-statistics").on 'shown.bs.tab', (e) ->
    $("#datepicker-5").focus ->
      $(".ui-datepicker-calendar").hide()
      $("#ui-datepicker-div").css("padding-bottom", "0.2em")

  $( "#datepicker-5" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+10',
        dateFormat: "yy-mm"
        # only month search
        onChangeMonthYear: (year, month, inst) ->
          $(this).val($.datepicker.formatDate('yy-mm', new Date(year, month - 1, 1)))
        onClose: (dateText, inst) ->
          $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 1))
          $(".ui-datepicker-calendar").hide()
      })
  $( "#datepicker-5" ).datepicker( $.datepicker.regional[ "zh-TW" ] )

  date_5 = null
  if window.start_time == ""
    date_5 = null
  else
    date_5 = new Date(window.start_time)
  $( "#datepicker-5" ).datepicker( "setDate", date_5 )

  $("#cash-statistics").on 'shown.bs.tab', (e) ->
    $("#datepicker-6").focus ->
      $(".ui-datepicker-calendar").hide()
      $("#ui-datepicker-div").css("padding-bottom", "0.2em")

 
  $( "#datepicker-6" ).datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange : '-20:+10',
        dateFormat: "yy-mm"
        # only month search
        onChangeMonthYear: (year, month, inst) ->
          $(this).val($.datepicker.formatDate('yy-mm', new Date(year, month - 1, 1)))
        onClose: (dateText, inst) ->
          $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 1))
          $(".ui-datepicker-calendar").hide()
      })
  $( "#datepicker-6" ).datepicker( $.datepicker.regional[ "zh-TW" ] )

  date_6 = null
  if window.end_time == ""
    date_6 = null
  else
    date_6 = new Date(window.end_time)
  $( "#datepicker-6" ).datepicker( "setDate", date_6 )
  
  if window.profile == "amount"
    $('.nav-tabs a[href="#tab4"]').tab('show')

  $("#bill-search-btn").click ->
    $("#bill-quick-choice").val(-1)
    start_time = $("#datepicker-5").val()
    if start_time == ""
      $.page_notification("请正确输入查询时间", 1000)
      return
    end_time = $("#datepicker-6").val()
    if end_time == ""
      $.page_notification("请正确输入查询时间", 1000)
    else
      location.href = "/staff/statistics?start_time=" + start_time + "&end_time=" + end_time + "&profile=amount"

  
