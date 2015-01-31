_ = require 'underscore'

module.exports = (qData) ->
  switch qData.cht
    when 'p', 'p3'
      pieChart qData
    when 'lc', 'ls', 'lxy'
      lineChart qData

###
  convert following query

    chd=50,100,300,20|10,30,20,90&chxl=0:|2001|2002|2003|2004|1:|year|sales|expense

  to

    ['year', 'sales', 'expenses'],
    ['2001',  50,     10],
    ['2002',  100,    30],
    ['2003',  300,    20],
    ['2004',  20,     90]
###
lineChart = (data) ->
  genTable = (data) ->

    # parse with https://developers.google.com/chart/image/docs/gallery/line_charts#axis_labels
    chxl = _.compact data.chxl?.split /\d:\|/
    chxl = chxl.map (i) -> i.split '|'
    xAxis = _.compact chxl[0]
    yAxis = _.compact chxl[1]
    chd = data.chd?.split('|').map (arr)->arr.split(',').map (i)->+i
    chd = _.zip.apply _, chd 

    result  = _(xAxis).reduce (row, firstColumn, i) ->
      row.push [firstColumn].concat chd[i]
      row
    , [yAxis]
  spec = 
    chartType   : 'LineChart'
    dataTable   : genTable data
    containerId : 'chart'
    firstRowIsData : false
    options :
      title  : data.chtt
      width  : data.chs?.split('x')[0]
      height : data.chs?.split('x')[1]
      colors : data.chco?.split '|'
      legend : 
        position : 'labeled'

###
  convert following query

    chd=50,100,300,20&chl=a|b|c|d|e

  to

    [a, 50]
    [b, 100]
    [c, 300]
    [d, 20]
###
pieChart = (data) ->
  spec = 
    chartType   : 'PieChart'
    dataTable   : _.zip(data.chl?.split('|'), data.chd?.split(',').map (i)-> +i)
    containerId : 'chart'
    firstRowIsData : true
    options :
      title  : data.chtt
      width  : data.chs?.split('x')[0]
      height : data.chs?.split('x')[1]
      is3D   : true if data.cht is 'p3'
      colors : data.chco?.split '|'
      legend : 
        position : 'labeled'
      pieSliceText  : 'none'
      pieStartAngle : if data.chp? then +data.chp * 180 / Math.PI else 0

