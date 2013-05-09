module.exports = (app) ->
  # Index
  app.get '/', app.ApplicationController.index

  # WebSockets
  # all further routing done in app.SocketsController
  app.io.sockets.on 'connection', app.SocketsController.connection

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res

  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'
