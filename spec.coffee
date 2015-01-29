_ = require 'underscore'

module.exports = (qData) ->
  switch qData.cht
    when 'p', 'p3'
      pieChart qData
    when 'lc', 'ls', 'lxy'
      lineChart qData

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
    ###
    ['Year', 'Sales', 'Expenses'],
    ['2004',  1000,      400],
    ['2005',  1170,      460],
    ['2006',  660,       1120],
    ['2007',  1030,      540]

    [chxl[0][0], chxl[0][1], chxl[0[2]],
    [chxl[1][0], chd[0][0], chd[1][0]],
    [chxl[1][1], chd[0][1], chd[1][1]],
    [chxl[1][2], chd[0][2], chd[1][2]],
    [chxl[1][3], chd[0][3], chd[1][3]],
    ###
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

pieChart = (data) ->
  spec = 
    chartType   : 'PieChart'
    ###
    ['Task', 'Hours per Day'],
    [chl[0], chd[0]]
    [chl[1], chd[1]]
    [chl[2], chd[2]]
    [chl[3], chd[3]]
    ###
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

