system = require 'system'
qs     = require 'qs'
_      = require 'underscore'
fs     = require 'fs'
page   = require('webpage'  ).create()
server = require('webserver').create()
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
      colors : ['#e0440e', '#e6693e', '#ec8f6e', '#f3b49f', '#f6c7b6']
      legend : 'none'
      # pieSliceText : 'label'

    el    = document.getElementById 'chart'
    chart = new google.visualization.PieChart el
    google.visualization.events.addListener chart, 'ready', () ->
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

server.listen 9500, (req, res) ->
  url = req.url.split('?')[1]
  qData = qs.parse url

  data = {}
  data.type  = qData.cht
  data.table = _.zip(qData.chl.split('|'), qData.chd.split(',').map (i)-> +i)
  data.size  = qData.chs.split 'x'
  data.title = qData.chtt

  render data, (result) ->
    page.clipRect = result
    page.render 'captured.png'

    fi = fs.open './captured.png', 'rb'
    res.statusCode = 200
    res.setEncoding 'binary'
    res.setHeader 'Content-Type', 'image/png'
    res.write fi.read()
    res.close();
