#= require highcharts

Highcharts.setOptions lang:
  contextButtonTitle: '图表导出菜单'
  decimalPoint: '.'
  downloadJPEG: '下载JPEG图片'
  downloadPDF: '下载PDF文件'
  downloadPNG: '下载PNG文件'
  downloadSVG: '下载SVG文件'
  drillUpText: '返回 {series.name}'
  loading: '加载中'
  months: [
    '一月'
    '二月'
    '三月'
    '四月'
    '五月'
    '六月'
    '七月'
    '八月'
    '九月'
    '十月'
    '十一月'
    '十二月'
  ]
  noData: '没有数据'
  numericSymbols: [
    '千'
    '兆'
    'G'
    'T'
    'P'
    'E'
  ]
  printChart: '打印图表'
  resetZoom: '恢复缩放'
  resetZoomTitle: '恢复图表'
  shortMonths: [
    'Jan'
    'Feb'
    'Mar'
    'Apr'
    'May'
    'Jun'
    'Jul'
    'Aug'
    'Sep'
    'Oct'
    'Nov'
    'Dec'
  ]
  thousandsSep: ','
  weekdays: [
    '星期一'
    '星期二'
    '星期三'
    '星期三'
    '星期四'
    '星期五'
    '星期六'
    '星期天'
  ]

$ ->
  
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
      data: [
        [
          '男生'
          60
        ]
        [
          '女生'
          40
        ]
      ]
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
      name: '性别比例'
      data: [
        [
          '0-3岁'
          10
        ]
        [
          '3-6岁'
          15
        ]
        [
          '6-9岁'
          20
        ]
        [
          '9-12岁'
          25
        ]
        [
          '12-15岁'
          20
        ]
        [
          '15-18岁'
          10
        ]
      ]
    } ]

  $('#nums-statistics').highcharts
      title:
        text: null
      xAxis: 
        title:
          text: '月份'
        categories: [
              'Jan'
              'Feb'
              'Mar'
              'Apr'
              'May'
              'Jun'
              'Jul'
              'Aug'
              'Sep'
              'Oct'
              'Nov'
              'Dec'
            ]
      yAxis:
        title: text: '儿童数量(千)'
      tooltip: valueSuffix: '千'
      credits:
           enabled: false
      legend:
        enabled: false
      series: [
        {
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
            9.7
          ]
        }
      ]
  $('#borrow-statistics').highcharts
      title:
        text: null
      xAxis: 
        type: 'datetime'
        tickInterval: 0
        title:
          text: '日期'
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

  previousPoint = null
  $('#center-statistics').highcharts
    chart: type: 'column'
    title: text: null
    xAxis:
      type: 'category'
    yAxis:
      min: 0
      title: text: '借阅数量(万人次)'
    legend: enabled: false
    tooltip: valueSuffix: '万人次'
    credits:
         enabled: false
    plotOptions: series: point: events: click: (event) ->
      if $(".click-show-div")
        $(".click-show-div").slideUp(1000)
      if previousPoint
        previousPoint.update color: '#90c5fc'
      previousPoint = this
      this.update color: '#227dda'
      $(".click-show-div").slideDown(1000)
      return
    series: [ {
      name: '借阅数量'
      data: [
        [
          '海淀区'
          3.9
        ]
        [
          '昌平区'
          16.1
        ]
        [
          '朝阳区'
          14.2
        ]
        [
          '大兴区'
          14.0
        ]
        [
          '东城区'
          12.5
        ]
        [
          '西城区'
          12.1
        ]
        [
          '朝阳区'
          11.8
        ]
        [
          '西城区'
          11.7
        ]
        [
          '东城区'
          11.1
        ]
        [
          '大兴区'
          11.1
        ]
        [
          '其他'
          10.5
        ]
      ]
    } ]

  previousPoint = null
  $('#center-income-statistics').highcharts
    chart:
      type: 'column'
    title: text: null
    xAxis:
      type: 'category'
    yAxis:
      min: 0
      title: text: '课程收入(万元)'
    legend: enabled: false
    tooltip: valueSuffix: '万元'
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
      data: [
        [
          '海淀区'
          3.9
        ]
        [
          '昌平区'
          16.1
        ]
        [
          '朝阳区'
          14.2
        ]
        [
          '大兴区'
          14.0
        ]
        [
          '东城区'
          12.5
        ]
        [
          '西城区'
          12.1
        ]
        [
          '朝阳区'
          11.8
        ]
        [
          '西城区'
          11.7
        ]
        [
          '东城区'
          11.1
        ]
        [
          '大兴区'
          11.1
        ]
        [
          '其他'
          10.5
        ]
      ]
    } ]

  $( "#datepicker-1" ).datepicker({
        # changeMonth: true,
        # changeYear: true
      })
  $( "#datepicker-1" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-1" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-2" ).datepicker({
        # changeMonth: true,
        # changeYear: true
      })
  $( "#datepicker-2" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-2" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-3" ).datepicker({
      # changeMonth: true,
      # changeYear: true
    })
  $( "#datepicker-3" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-3" ).datepicker( "option", "dateFormat", "yy-mm-dd" )

  $( "#datepicker-4" ).datepicker({
      # changeMonth: true,
      # changeYear: true
    })
  $( "#datepicker-4" ).datepicker( $.datepicker.regional[ "zh-TW" ] )
  $( "#datepicker-4" ).datepicker( "option", "dateFormat", "yy-mm-dd" ) 

  $('#center-borrow-statistics').highcharts
      title:
        text: null
      xAxis: 
        type: 'datetime'
        tickInterval: 0
        title:
          text: '日期'
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
          pointStart: Date.UTC(2016, 9, 1),
          pointInterval: 24 * 3600 * 1000
        }
      ]

  $('#center-collect-statistics').highcharts
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