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
      # legent: 'none'
      # pieSliceText : 'label'

    el    = document.getElementById 'chart'
    chart = new google.visualization.PieChart el
    google.visualization.events.addListener chart, 'ready', () -> window.callPhantom chart.getImageURI()

    chart.draw data, opt

  setTimeout drawChart, 100

render = (data, cb) ->
  page.content = template
  page.onLoadFinished   = ()     -> page.evaluate onSandbox, data
  page.onConsoleMessage = (msg ) -> console.log msg
  page.onCallback       = (data) -> cb atob data.split(',')[1]

server.listen 9500, (req, res) ->
  url = req.url.split('?')[1]
  qData = qs.parse url

  data = {}
  data.table = _.zip(qData.chl.split('|'), qData.chd.split(',').map (i)-> +i)
  data.size  = qData.chs.split 'x'
  data.title = qData.chtt

  render data, (result) ->
    res.statusCode = 200
    res.setEncoding 'binary'
    res.setHeader 'Content-Type', 'image/png'
    res.write result
    res.close();
