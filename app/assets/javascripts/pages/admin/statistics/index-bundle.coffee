#= require highcharts
$ ->

  refresh_client_stat = ->
    $.getJSON "/admin/statistics/client_stats/", (data) ->
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
            
            # data: [
            #   [
            #     '男生'
            #     60
            #   ]
            #   [
            #     '女生'
            #     40
            #   ]
            # ]

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
            # data: [
            #   [
            #     '0-3岁'
            #     10
            #   ]
            #   [
            #     '3-6岁'
            #     15
            #   ]
            #   [
            #     '6-9岁'
            #     20
            #   ]
            #   [
            #     '9-12岁'
            #     25
            #   ]
            #   [
            #     '12-15岁'
            #     20
            #   ]
            #   [
            #     '15-18岁'
            #     10
            #   ]
            # ]
          } ]

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
                data: data.stat.num
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
                #   9.7
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
    $.getJSON "/admin/statistics/course_stats?duration=" + duration + "&start_date=" + start_date + "&end_date=" + end_date, (data) ->
      if data.success
        $("#total-signup").text(data.stat.total_signup)
        $("#total-money").text(data.stat.total_money)


        $('#register-statistics').highcharts
            title:
              text: null
            xAxis: 
              tickInterval: 5
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

        # $('#bonu-statistics').highcharts
        #   chart:
        #     plotBackgroundColor: null
        #     plotBorderWidth: null
        #     plotShadow: false
        #   colors: ['#90c5fc', '#227dda', '#ED561B', '#DDDF00',
        #                   '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
        #   title: text: null
        #   tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        #   plotOptions: pie:
        #     allowPointSelect: true
        #     cursor: 'pointer'
        #     dataLabels: enabled: false
        #     showInLegend: true
        #   credits:
        #        enabled: false
        #   legend:
        #     itemStyle:
        #         color: '#969696'
        #   series: [ {
        #     type: 'pie'
        #     data: [
        #       [
        #         '个人支付'
        #         data.stat.total_income
        #       ]
        #       # [
        #       #   '政府补贴'
        #       #   data.stat.total_allowance
        #       # ]
        #     ]
        #   } ]

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
            # {
            #   name: "政府补贴"
            #   color: '#227dda'
            #   data: data.stat.allowance
            #   pointStart: 1
            # }
            {
              name: "个人支付"
              color: '#90c5fc'
              data: data.stat.income
              pointStart: 1
            }
          ]
      
        previousPoint = null
        $('#center-income-statistics').highcharts
          chart:
            type: 'column'
          title: text: null
          xAxis:
            type: 'category'
          yAxis:
            min: 0
            title: text: '课程收入(元)'
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
            name: '课程收入'
            data: data.stat.income_center
          } ]

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
    $.getJSON "/admin/statistics/book_stats?duration=" + duration + "&start_date=" + start_date + "&end_date=" + end_date, (data) ->
      if data.success
        $("#total-borrow").text(data.stat.total_borrow)
        console.log data.stat.borrow_num
        $('#borrow-statistics').highcharts
            title:
              text: null
            xAxis: 
              type: 'datetime'
              tickInterval: 0
              title:
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
                pointStart: Date.UTC(2016, 9, 1),
                pointInterval: 24 * 3600 * 1000
              }
            ]

        $('#collect-statistics').highcharts
            title:
              text: null
            xAxis: 
              tickInterval: 5
              title:
                # text: '周数'
                text: data.stock_time_unit
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
                pointStart: 1
                data: data.stat.stock_num
              }
              {
                name: '借出绘本'
                color: '#227dda'
                pointStart: 1
                data: data.stat.off_shelf_num
              }
            ]
      
        previousPoint = null
        $('#center-statistics').highcharts
          chart: type: 'column'
          title: text: null
          xAxis:
            type: 'category'
          yAxis:
            min: 0
            title: text: '借阅数量(人次)'
          legend: enabled: false
          tooltip: valueSuffix: '人次'
          credits:
               enabled: false
          plotOptions: series: point: events: click: (event) ->
            # if $(".click-show-div")
            #   $(".click-show-div").slideUp(1000)
            if previousPoint
              previousPoint.update color: '#90c5fc'
            previousPoint = this
            this.update color: '#227dda'
            # $(".click-show-div").slideDown(1000)
            return
          series: [ {
            name: '借阅数量'
            data: data.stat.borrow_center
            # data: [
            #   [
            #     '海淀区'
            #     3.9
            #   ]
            #   [
            #     '昌平区'
            #     16.1
            #   ]
            #   [
            #     '朝阳区'
            #     14.2
            #   ]
            #   [
            #     '大兴区'
            #     14.0
            #   ]
            #   [
            #     '东城区'
            #     12.5
            #   ]
            #   [
            #     '西城区'
            #     12.1
            #   ]
            #   [
            #     '朝阳区'
            #     11.8
            #   ]
            #   [
            #     '西城区'
            #     11.7
            #   ]
            #   [
            #     '东城区'
            #     11.1
            #   ]
            #   [
            #     '大兴区'
            #     11.1
            #   ]
            #   [
            #     '其他'
            #     10.5
            #   ]
            # ]
          } ]
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

  # $('#center-borrow-statistics').highcharts
  #     title:
  #       text: null
  #     xAxis: 
  #       type: 'datetime'
  #       tickInterval: 0
  #       title:
  #         text: '日期'
  #     yAxis:
  #       title: text: '借阅数量(人次)'
  #     tooltip: valueSuffix: '人次'
  #     credits:
  #          enabled: false
  #     legend:
  #       enabled: false
  #     series: [
  #       {
  #         color: '#90c5fc'
  #         data: [
  #           1.0
  #           2.3
  #           2.8
  #           3.2
  #           4.5
  #           6.0
  #           6.6
  #           7.5
  #           8.5
  #           15.3
  #           32
  #           55
  #         ]
  #         pointStart: Date.UTC(2016, 9, 1),
  #         pointInterval: 24 * 3600 * 1000
  #       }
  #     ]

  # $('#center-collect-statistics').highcharts
  #     title:
  #       text: null
  #     xAxis: 
  #       tickInterval: 5
  #       title:
  #         text: '周数'
  #     yAxis:
  #       title: text: '书籍数量(本)'
  #     tooltip: valueSuffix: '本'
  #     credits:
  #          enabled: false
  #     legend:
  #       enabled: true
  #       verticalAlign: 'top'
  #       itemStyle:
  #         color: '#969696'
  #     series: [
  #       {
  #         name: '全部绘本'
  #         color: '#90c5fc'
  #         data: [
  #           1.0
  #           2.3
  #           2.8
  #           3.2
  #           4.5
  #           6.0
  #           6.6
  #           7.5
  #           8.5
  #           15.3
  #           32
  #           55
  #         ]
  #       }
  #       {
  #         name: '借出绘本'
  #         color: '#227dda'
  #         data: [
  #           5
  #           8
  #           11
  #           15
  #           20
  #           23
  #           26
  #           32
  #           40
  #           49
  #           55
  #           70
  #         ]
  #       }
  #     ]

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
