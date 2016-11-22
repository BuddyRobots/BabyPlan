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
          colors: ['#90c5fc', '#ffa1a1', '#ED561B', '#DDDF00',
                          '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
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
            name: '性别比例'
            data: data.stat.gender
          } ]

        $('#age-statistics').highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          colors: ['#90c5fc', '#7fbaf7', '#67aaef', '#4898e7',
                          '#3388df', '#227dda', '#FF9655', '#FFF263', '#6AF9C4']
          title: text: null
          tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
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
            name: '年龄比例'
            data: data.stat.age
          } ]

        $('#nums-statistics').highcharts
            title:
              text: null
            xAxis: 
              title:
                text: '周数'
            yAxis:
              title: text: '儿童数量'
              max: 10
            # tooltip: valueSuffix: '千'
            credits:
                 enabled: false
            legend:
              enabled: false
            series: [
              {
                data: data.stat.num
              }
            ]
      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_client_stat()

  refresh_course_stat = ->
    duration = $("#quick-choice").val()
    $.getJSON "/staff/statistics/client_stats?duration=" + duration, (data) ->
      if data.success
      else
        $.page_notification "服务器出错，请稍后再试"

  refresh_course_stat()

  $('#borrow-statistics').highcharts
      title:
        text: null
      xAxis: 
        tickInterval: 5
        title:
          text: '周数'
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
          data: [
            1.0
            2.3
            2.8
            3.2
            4.5
            6.0
            6.6
            7.5
            8.5
            15.3
            32
            55
          ]
        }
      ]

  $('#collect-statistics').highcharts
      title:
        text: null
      xAxis: 
        tickInterval: 5
        title:
          text: '周数'
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
          data: [
            1.0
            2.3
            2.8
            3.2
            4.5
            6.0
            6.6
            7.5
            8.5
            15.3
            32
            55
          ]
        }
        {
          name: '借出绘本'
          color: '#227dda'
          data: [
            5
            8
            11
            15
            20
            23
            26
            32
            40
            49
            55
            70
          ]
        }
      ]

  $('#register-statistics').highcharts
      title:
        text: null
      xAxis: 
        tickInterval: 5
        title:
          text: '周数'
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
          data: [
            1.0
            2.3
            2.8
            3.2
            4.5
            6.0
            6.6
            7.5
            8.5
            15.3
            32
            55
          ]
        }
      ]

  $('#bonu-statistics').highcharts
    chart:
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false
    colors: ['#90c5fc', '#227dda', '#ED561B', '#DDDF00',
                    '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
    title: text: null
    tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
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
      data: [
        [
          '个人支付'
          90
        ]
        [
          '政府补贴'
          10
        ]
      ]
    } ]

  $('#income-statistics').highcharts
    chart: type: 'column'
    title: text: null
    xAxis:
      title:
        text: '周数' 
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
        data: [
          2
          2
          3
          2
          1
        ]
      }
      {
        name: "个人支付"
        color: '#90c5fc'
        data: [
          5
          6
          7
          9
          5
        ]
      }
    ]


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