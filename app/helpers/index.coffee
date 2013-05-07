fs = require 'fs'
livereload = require "livereload"

# Recursively require a folder’s files
exports.autoload = autoload = (dir, app) ->
  fs.readdirSync(dir).forEach (file) ->
    path = "#{dir}/#{file}"
    stats = fs.lstatSync(path)

    # Go through the loop again if it is a directory
    if stats.isDirectory()
      autoload path, app
    else
      require(path)?(app)

# Return last item of an array
# ['a', 'b', 'c'].last() => 'c'
Array::last = ->
  this[this.length - 1]

# Capitalize a string
# string => String
String::capitalize = () ->
    this.replace /(?:^|\s)\S/g, (a) -> a.toUpperCase()

# Classify a string
# application_controller => ApplicationController
String::classify = (str) ->
  classified = []
  words = str.split('_')
  for word in words
    classified.push word.capitalize()

  classified.join('')

exports.livereload = (app, dirs...) -> 
  config =
      port: 35729
      exts: [
          "js"
          "coffee"
          "jade"
          "styl"
      ]
      watchDir: dirs[0]

  if app.settings.env is 'production'
      app.locals.LRScript = ""
  else
      app.locals.LRScript = "<script>document.write('<script src=\"http://' + (location.host || 'localhost').split(':')[0] + ':#{config.port or 35729}/livereload.js\"></' + 'script>')</script>"
      server = livereload.createServer(config)
      for dir in dirs
          console.log "watching #{dir}"
          server.watch(dir)
