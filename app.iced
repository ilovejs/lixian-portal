express = require 'express'
http = require 'http'
path = require 'path'
fs = require 'fs'
{
  exec
  execFile
  spawn
} = require 'child_process'
lazy = require 'lazy'


cli = path.join __dirname, 'xunlei-lixian', 'lixian_cli.py'

app = express favicon: false

app.use express.static path.join __dirname, 'components'
app.locals.pretty = true
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'
app.use express.bodyParser()
app.use (req, res, next)->
  req.body[k] = v for k, v of req.query
  next()
app.use express.methodOverride()

statusMap = 
  completed: 'success'
  failed: 'error'
  waiting: 'warn'
  downloading: 'info'
statusMapLabel = 
  completed: '完成'
  failed: '失败'
  waiting: '等待'
  downloading: '下载中'

regexMG = /^([^ ]+) +(.+) +(completed|downloading|waiting|failed) *(http\:\/\/.+)?$/mg
regexQ = /^([^ ]+) +(.+) +(completed|downloading|waiting|failed) *(http\:\/\/.+)?$/m

app.locals.retrieving = null
app.locals.error = {}
app.locals.speed = 'NaN'

updateTasklist = (cb)->
  await exec "#{cli} list --no-colors --download-url", defer e, out, err
  return cb 403 if e && err.match /user is not logged in/
  return cb e if e
  tasks = []
  if out.match regexMG 
    for task in out.match regexMG
      task = task.match regexQ
      tasks.push
        id: task[1]
        filename: task[2]
        status: statusMap[task[3]]
        statusLabel: statusMapLabel[task[3]]
        url: task[4]
  app.locals.tasks = 
    version: Date.now()
    tasks: tasks
  
  for task in tasks
    if task.status=='success' && !app.locals.retrieving? && !app.locals.error[task.id]?

      console.log "started #{task.id}"
      app.locals.retrieving = download = spawn cli, ['download', '--continue', '--no-hash', '--delete', task.id], stdio: 'pipe'
      download.errBuffer = []
      download.task = task
      new lazy(download.stderr).lines.forEach (line)->
        line ?= []
        line = line.toString 'utf8'
        download.errBuffer.push line
        line = line.match /\s+(\d?\d%)\s+([^ ]{1,10})\s+([^ ]{1,10})\r?\n?$/
        [dummy, download.progress, app.locals.speed, download.time] = line if line

      download.on 'exit', (e)->
        console.log "finished #{task.id}"
        if e
          app.locals.error[task.id] = download.errBuffer.join ''
        app.locals.retrieving = null
        updateTasklist ->
  cb()


app.get '/', (req, res, cb)->
  if !app.locals.tasks? || (Date.now() - app.locals.tasks.version) > 3600 * 1000
    await updateTasklist defer e
    return res.redirect '/login' if e is 403
    return cb e if e
  res.render 'tasks'
app.post '/', (req, res, n)->
  if req.files && req.files.bt && req.files.bt.path
    req.body.url = req.files.bt.path + '.torrent'
    await fs.rename req.files.bt.path, req.files.bt.path + '.torrent', defer e 
    return n e if e
  await exec "#{cli} add #{req.body.url}", defer e, out, err
  return n e if e
  await updateTasklist defer e
  return n e if e
  res.redirect '/'

app.get '/login', (req, res)-> res.render 'login'
app.post '/login', (req, res, n)-> 
  await exec "#{cli} config username #{req.body.username}", defer e, out, err
  return n e if e
  await exec "#{cli} config password #{req.body.password}", defer e, out, err
  return n e if e
  await exec "#{cli} login", defer e, out, err
  return n e if e
  res.redirect '/'

app.delete '/tasks/:id', (req, res, n)->
  if app.locals.retrieving && req.params.id == app.locals.retrieving.task.id
    app.locals.retrieving.kill 'SIGINT'
  await exec "#{cli} delete #{req.params.id}", defer e, out, err
  return n e if e
  await updateTasklist defer e
  return n e if e
  res.redirect '/'
        

app.use (e, req, res, next)->
  res.render 'error',
    error: e

(server = http.createServer app).listen (Number process.env.PORT or 3000), ->
  console.log "portal ready on http://#{server.address().address}:#{server.address().port}/"