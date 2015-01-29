system      = require 'system'
qs          = require 'qs'
fs          = require 'fs'
H           = require 'jshashes'
page        = require('webpage'  ).create()
server      = require('webserver').create()
renderChart = require './render'
spec        = require './spec'

sha1 = new H.SHA1()
tmpl = fs.read './index.html'

CACHE_DIR = './cache'

render = (data, cb) ->
  page.content = tmpl
  page.onLoadFinished   = ()     -> page.evaluate renderChart, data
  page.onConsoleMessage = (msg ) -> console.log msg
  page.onError          = (msg ) -> console.log msg
  page.onCallback       = (data) -> cb data

responseImg = (res, name) ->
  fi = fs.open "#{CACHE_DIR}/#{name}.png", 'rb'
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
  fs.makeDirectory CACHE_DIR unless fs.exists CACHE_DIR
  url   = req.url.split('?')[1]
  qData = qs.parse url
  name  = sha1.hex url
  return responseImg res, name if fs.exists "#{CACHE_DIR}/#{name}.png"

  render spec(qData), (result) ->
    return responseErr res unless result
    page.clipRect = result
    page.render "#{CACHE_DIR}/#{name}.png"
    responseImg res, name
