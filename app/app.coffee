# Modules
express = require 'express'
http = require 'http'


# create app base
app = express()
server = http.createServer(app)
io = app.io = (require 'socket.io').listen(server)


# Boot setup
require("#{__dirname}/../config/boot")(app)


# Configuration
app.configure ->
  port = process.env.PORT || 3000
  if process.argv.indexOf('-p') >= 0
    port = process.argv[process.argv.indexOf('-p') + 1]

  # live reload
  app.helpers.livereload(app, 
      "#{__dirname}/assets", 
      "#{__dirname}/views",
      "#{__dirname}/../public")

  app.set 'port', port
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.static("#{__dirname}/../public")
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require('connect-assets')(src: "#{__dirname}/assets")
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()
  io.set 'loglevel', 10

# Routes
require("#{__dirname}/routes")(app)

# Server
server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'} in #{app.settings.env} mode"
