# console.log './scape2'

# screw typing THREE
window.T = window.THREE

# global constants
exports = {}
exports.WIDTH =  window.innerWidth
exports.HEIGHT = window.innerHeight

exports.VIEW_ANGLE = 45
exports.ASPECT = exports.WIDTH / exports.HEIGHT
exports.NEAR = 0.1
exports.FAR = 10000

exports.ORANGERED = 0x862104
exports.ORANGE    = 0xe89206

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

# copies all properties of obj onto window
exportAll = (obj) ->
    for k, v of obj
        window[k] = v

exportAll(exports)
