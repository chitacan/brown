module.exports = (spec) ->
  onReady = () ->
    clearTimeout timeout
    svg = document.getElementsByTagName('svg')[0]
    window.callPhantom svg.getBoundingClientRect()

  draw = () ->
    console.log 'onDraw'
    spec.dataTable = google.visualization.arrayToDataTable spec.dataTable, spec.firstRowIsData
    chart = new google.visualization.ChartWrapper spec
    google.visualization.events.addListener chart, 'ready', onReady
    chart.draw()

  timeout = setTimeout () ->
    console.error 'draw timeout'
    window.callPhantom()
  , 2000
  setTimeout draw, 0

