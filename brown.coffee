system = require 'system'
qs     = require 'qs'
_      = require 'underscore'
fs     = require 'fs'
H      = require 'jshashes'
page   = require('webpage'  ).create()
server = require('webserver').create()
sha1   = new H.SHA1()
template = """
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
  <script src="https://www.google.com/jsapi"></script>
  <script type="text/javascript">google.load("visualization", "1.0", {"packages":["corechart"]});</script>
</head>
<body>
  <div id="chart">Chart did not generated</div>
</body>
</html>
"""

onSandbox = (spec) ->
  onReady = () ->
    clearTimeout timeout
    svg = document.getElementsByTagName('svg')[0]
    window.callPhantom svg.getBoundingClientRect()

  draw = () ->
    console.log 'onDraw'
    spec.dataTable = google.visualization.arrayToDataTable spec.dataTable
    chart = new google.visualization.ChartWrapper spec
    google.visualization.events.addListener chart, 'ready', onReady
    chart.draw()

  timeout = setTimeout () ->
    console.error 'draw timeout'
    window.callPhantom()
  , 2000
  setTimeout draw, 0

render = (data, cb) ->
  page.content = template
  page.onLoadFinished   = ()     -> page.evaluate onSandbox, data
  page.onConsoleMessage = (msg ) -> console.log msg
  page.onError          = (msg ) -> console.log msg
  page.onCallback       = (data) -> cb data

responseImg = (res, name) ->
  fi = fs.open "./cache/#{name}.png", 'rb'
  res.statusCode = 200
  res.setEncoding 'binary'
  res.setHeader 'Content-Type', 'image/png'
  res.write fi.read()
  res.close();

responseErr = (res) ->
  res.statusCode = 500
  res.write 'cannot load image'
  res.close()

server.listen 9500, (req, res) ->
  lineChart = (data) ->
    genTable = (data) ->
      # parse with https://developers.google.com/chart/image/docs/gallery/line_charts#axis_labels
      makeColumn = (first, arr) ->
        [first].concat arr
      chxl = _.compact data.chxl?.split /\d:\|/
      chxl = chxl.map (i) -> i.split '|'
      x = chxl[0]
      y = chxl[1]
      chd  = data.chd?.split('|').map (arr)->arr.split(',').map (i)->+i

      _.zip makeColumn(y[0], x), makeColumn(y[1], chd[0]), makeColumn(y[2], chd[1])
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
      options :
        title  : data.chtt
        width  : data.chs?.split('x')[0]
        height : data.chs?.split('x')[1]
        is3D   : true if data.type is 'p3'
        colors : data.chco?.split '|'
        legend : 
          position : 'labeled'
        pieSliceText  : 'none'
        pieStartAngle : if data.chp? then +data.chp * 180 / Math.PI else 0

  createSpec = (qData) ->
    switch qData.cht
      when 'p', 'p3'
        pieChart qData
      when 'lc', 'ls', 'lxy'
        lineChart qData

  console.log req.url
  fs.makeDirectory './cache' unless fs.exists './cache'
  url   = req.url.split('?')[1]
  qData = qs.parse url
  name  = sha1.hex url
  return responseImg res, name if fs.exists "./cache/#{name}.png"

  render createSpec(qData), (result) ->
    return responseErr res unless result
    page.clipRect = result
    page.render "./cache/#{name}.png"
    responseImg res, name
