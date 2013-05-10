# console.log './scape2'

# screw typing THREE
window.T = window.THREE

# global constants
exports = {}
exports.WIDTH =  window.innerWidth
exports.HEIGHT = window.innerHeight

# THE BEST CONSTANT IN THE WORLD RIGHT HERE
###########################################
exports.CRAZYTUDE = 0.002
###########################################

# global camera control
exports.MAX_ZOOM = 1700
exports.SNAP_DISTANCE = 25
exports.camera = "derp"

# camera related stuff, don't change
exports.VIEW_ANGLE = 45
exports.ASPECT = exports.WIDTH / exports.HEIGHT
exports.NEAR = 0.1
exports.FAR = 10000

# colors
exports.ORANGERED = 0x862104
exports.ORANGE    = 0xe89206
exports.CYAN      = 0x00ffff
exports.COOL      = 30617 # i forget the hex !

exports.LINE_COLOR = exports.COOL
exports.LINE_MIDPOINT = 0.5 # changing animates line coloration
exports.LINE_WIDTH = 1

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

window.stop_animating = (name) ->
  timeout_name = "_#{name}_aniamte_interval"
  clearInterval window[timeout_name]
  window[name] = window[name + '_ORIGINAL']
