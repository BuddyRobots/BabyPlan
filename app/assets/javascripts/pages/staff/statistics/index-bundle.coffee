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
        text: 'Monthly Average Temperature'
        x: -20
      subtitle:
        text: 'Source: WorldClimate.com'
        x: -20
      xAxis: categories: [
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
        title: text: 'Temperature (°C)'
        plotLines: [ {
          value: 0
          width: 1
          color: '#808080'
        } ]
      tooltip: valueSuffix: '°C'
      legend:
        layout: 'vertical'
        align: 'right'
        verticalAlign: 'middle'
        borderWidth: 0
      series: [
        {
          name: 'Tokyo'
          data: [
            7.0
            6.9
            9.5
            14.5
            18.2
            21.5
            25.2
            26.5
            23.3
            18.3
            13.9
            9.6
          ]
        }
        {
          name: 'New York'
          data: [
            -0.2
            0.8
            5.7
            11.3
            17.0
            22.0
            24.8
            24.1
            20.1
            14.1
            8.6
            2.5
          ]
        }
        {
          name: 'Berlin'
          data: [
            -0.9
            0.6
            3.5
            8.4
            13.5
            17.0
            18.6
            17.9
            14.3
            9.0
            3.9
            1.0
          ]
        }
        {
          name: 'London'
          data: [
            3.9
            4.2
            5.7
            8.5
            11.9
            15.2
            17.0
            16.6
            14.2
            10.3
            6.6
            4.8
          ]
        }
      ]
