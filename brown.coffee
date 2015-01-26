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

onSandbox = (chartData) ->
  drawChart = () ->
    data = google.visualization.arrayToDataTable chartData.table, true
    opt  =
      title  : chartData.title
      width  : chartData.size[0]
      height : chartData.size[1]
      is3D   : true if chartData.type is 'p3'
      colors : ['1f77b4', 'ff7f0e', '2ca02c', 'd62728', '9467bd', '8c564b', 'e377c2', '7f7f7f', 'bcbd22', '17becf']
      legend : 'none'
      # pieSliceText : 'label'

    el      = document.getElementById 'chart'
    chart   = new google.visualization.PieChart el
    console.log 'ondraw'
    timeout = setTimeout () ->
      console.error 'chart draw timeout'
      window.callPhantom()
    , 2000
    google.visualization.events.addListener chart, 'ready', () ->
      clearTimeout timeout
      svg = el.getElementsByTagName('svg')[0]
      window.callPhantom svg.getBoundingClientRect()

    chart.draw data, opt

  setTimeout drawChart, 0

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
  console.log req.url
  fs.makeDirectory './cache' unless fs.exists './cache'
  url   = req.url.split('?')[1]
  qData = qs.parse url
  name  = sha1.hex url
  return responseImg res, name if fs.exists "./cache/#{name}.png"

  data = {}
  data.type   = qData.cht
  data.table  = _.zip(qData.chl.split('|'), qData.chd.split(',').map (i)-> +i)
  data.size   = qData.chs.split 'x'
  data.title  = qData.chtt
  data.colors = qData.chco.split '|'

  render data, (result) ->
    return responseErr res unless result
    page.clipRect = result
    page.render "./cache/#{name}.png"
    responseImg res, name

