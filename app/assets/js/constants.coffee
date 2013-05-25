# console.log './scape2'

# screw typing THREE
window.T = window.THREE

# global constants
exports = {}
exports.WIDTH =  window.innerWidth
exports.HEIGHT = window.innerHeight


# global camera control
exports.MAX_ZOOM = 1700
exports.SNAP_DISTANCE = 25
exports.camera = "derp"

# camera related stuff, don't change
exports.VIEW_ANGLE = 45
exports.ASPECT = exports.WIDTH / exports.HEIGHT
exports.NEAR = 0.1
exports.FAR = 10000

# graph
exports.MOVEMENT_RATE = 9

# colors
exports.ORANGERED = 0x862104
exports.ORANGE    = 0xe89206
exports.CYAN      = 0x00ffff
exports.COOL      = 30617 # i forget the hex !

# Edges
exports.LINE_COLOR = exports.COOL
exports.LINE_MIDPOINT = 0.5 # changing animates line coloration
exports.LINE_WIDTH = 1
# THE BEST CONSTANT IN THE WORLD RIGHT HERE
###########################################
exports.CRAZYTUDE = 0.002
###########################################

# text setup
exports.TEXT_SIZE = 7

# edge setup

exports.K = 1000

##### Utility functions
# debounce calls returns a function that calls fn at most once 
# every `wait` miliseconds.
# if immediate is true, fn will be run on the first call.
exports.debounce = (fn, wait, immediate) ->
    timeout = null
    return ->
        ctx = this
        args = arguments
        later = ->
            timeout = null
            fn.apply(ctx, args) unless immediate
        callNow = immediate and not timeout
        window.clearTimeout timeout
        timeout = window.setTimeout later, wait
        if callNow
            func.apply ctx, args

# positive/negative multiplier
exports.pos = (n) ->
    return 1  if n > 0
    return -1 if n < 0
    return 0  if n == 0

# calculate animation deltas
exports.animateTo = (target, current, rate) ->
    if rate >= Math.abs(target - current)
        rate = Math.abs((target - current) / 2)
    return pos(target - current) * rate

exports.randomInRange = (min, max) ->
    min + Math.floor(Math.random() * (max - min + 1))

# copies all properties of obj onto window
exportAll = (obj) ->
    for k, v of obj
        window[k] = v

exportAll(exports)

window.animate_constant = (name, range, mid, step = 0.04, rate = 40) ->
  forwards = true
  min = mid - range
  max = mid + range
  timeout_name = "_#{name}_aniamte_interval"
  window[name + '_ORIGINAL'] = window[name]
  set_next_constant = ->
    STEP = step
    mp = window[name]
    mp += STEP if forwards
    mp -= STEP if not forwards

    if mp > max
      mp = max
      forwards = false

    if mp < min
      mp = min
      forwards = true

    window[name] = mp
  clearInterval window[timeout_name]
  window[timeout_name] = setInterval(set_next_constant, rate)

# the former animate constant was a horrible beast. New idea:
# TODO: make this actually work
# high math is hard :((((((((
class window.ConstantAnimator
  constructor: (@const_name, @from, @to, @time, @step_smoothness = 0.01,  @reverse_at_end = true) ->
    # abstracted because we want to recalculate the @interval on changes to object fields
    # and we can't recall @constructor because of all the parameter setting that goes on
    @build()

  # increment or decrement the @const_value, then set the global property to @const_value.
  # run by setInterval bound in @start
  intervalFunc: =>
    # increment
    if @go_forwards 
      @const_value += @actual_step_smoothness
    else
      @const_value -= @actual_step_smoothness

    # max bound
    if @const_value > @to
      if @reverse_at_end
        @const_value = @to
        @go_forwards = false
      else
        @const_value = @from

    # min bound - only run when @reverse_at_end = true, and we were @go_forwards = false
    if @const_value <= @from
      @go_forwards = true

    # set global
    window[@const_name] = @const_value
    
  # control a setInterval on the window to run the incrementor @intervalFunc
  # TODO: implement in a thread that uses time callbacks in a WebWorker
  start: ->
    @interval_id = window.setInterval( (=> @intervalFunc() ), @interval)

  stop: ->
    window.clearInterval(@interval_id)

  build: ->
    # reset step smoothnes from user provided value. In case it gets adjusted based on minimum interval
    @actual_step_smoothness = @step_smoothness

    # becomes false in @reverse_at_end functions, when animation reaches @to
    @go_forwards = true
    @const_value = @from

    # calculate the interval required to increment @const_value until it is equal to @to
    # in exacly `time` milliseconds
    # TODO: this is really friggin broken
    steps_needed = (@to - @from) / @actual_step_smoothness
    @interval = steps_needed / @time

    # there is a minimum allowed interval delay in browsers, see [MDN][1] on the subject
    # The min delay is 4ms in the HTML 5 spec, but differse between browsers.
    # WE support only Chrome Canary, so the value for Chrome/Blink is used. which is 4ms 
    #
    # [1]: https://developer.mozilla.org/en-US/docs/Web/API/window.setTimeout?redirectlocale=en-US&redirectslug=DOM%2Fwindow.setTimeout#Notes
    
    if @interval < 4
      console.log("Interval #{@interval}ms is too small, pinning to 4ms (calculated from step size #{@step_smoothness})")
      # set steps needed based on interval
      # intervcal * steps_needed = time
      # steps_needed = time / interval
      @interval = 4
      steps_needed = @time / @interval
      @actual_step_smoothness = (@to - @from) / steps_needed

    console.log("Selected #{@interval}ms interval, step size  #{@actual_step_smoothness}.")
    return this


  # if you changed class constants around and want to recalculate the @interval
  # so your new animation plays correctly
  restart: (new_time) ->
    # convinience setting of time -- for easily adjusting the most-changed parameter
    if new_time?
      @time = new_time

    @stop()
    @build()
    @start()
