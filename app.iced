express = require 'express'
http = require 'http'
path = require 'path'
fs = require 'fs'
client = require './client'

app = express favicon: false
app.locals.info = client = require './client'
app.use express.static path.join __dirname, 'components'
app.locals.pretty = true
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'
app.use express.bodyParser()
app.use (req, res, next)->
  req.body[k] = v for k, v of req.query
  next()
app.use express.methodOverride()

client.startCron()
autorefresh = ->
  client.queue.tasks.updateTasklist()
  setTimeout autorefresh, 60000 * (1 + Math.random() * 3)
autorefresh()


app.get '/', (req, res, n)->
  return res.redirect '/login' if client.stats.requireLogin
  res.render 'tasks'

app.all '*', (req, res, n)->
  return n null if req.method is 'GET'
  ip = req.header('x-forwarded-for') || req.connection.remoteAddress
  ip = ip.split(',')[0].trim()
  return n 403 if process.env.ONLYFROM && -1 == process.env.ONLYFROM.indexOf ip
  n null
app.post '/refresh', (req, res, n)->
  client.queue.tasks.updateTasklist()
  res.redirect 'back'

app.post '/', (req, res, n)->
  if req.files && req.files.bt && req.files.bt.path && req.files.bt.length
    bt = req.files.bt
    await fs.rename bt.path, "#{bt.path}.torrent", defer e 
    return cb e if e
    client.queue.tasks.addBtTask bt.name, "#{bt.path}.torrent"
  else
    client.queue.tasks.addTask req.body.url
  res.redirect '/'

app.get '/login', (req, res)-> res.render 'login'
app.post '/login', (req, res, n)-> 
  client.stats.requireLogin = false
  client.queue.tasks.login req.body.username, req.body.password
  res.redirect '/'

app.delete '/tasks/:id', (req, res, n)->
  if client.stats.retrieving?.task.id
    client.stats.retrieving.kill()
  client.queue.tasks.deleteTask req.params.id
  res.redirect '/'
        

app.use (e, req, res, next)->
  res.render 'error',
    error: e

(server = http.createServer app).listen (Number process.env.PORT or 3000), ->
  console.log "portal ready on http://#{server.address().address}:#{server.address().port}/"