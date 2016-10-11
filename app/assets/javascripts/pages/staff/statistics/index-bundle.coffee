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
        text: null
      xAxis: 
        title:
          text: '周数'
      yAxis:
        title: text: '儿童数量(千)'
        max: 10
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
