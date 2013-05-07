# console.log './scape2'

# screw typing THREE
window.T = window.THREE

class Node
    # these are local variables, and are not accessable outside
    # of THIS class closure
    baseGeometry = new T.CubeGeometry(40, 40, 40)
    baseMaterial = new T.MeshLambertMaterial(color: 0x333333)

    # a static class property
    # this is a bad idea, and should be handled elsewhere
    # currently just an illustrative example
    @Instances = {}

    # id, classes, properties auto-saved to those object properties
    constructor: (@id, @classes, @properties) ->
        if ! @id?
            throw "All nodes must have an ID"

        # this.constructor is the class accessor
        @constructor.Instances[@id] = this
        @mesh = new T.Mesh(baseGeometry, baseMaterial)

debounce = (fn, wait, immediate) ->
    timeout = null
    return ->
        ctx = this
        args = arguments
        later = ->
            timeout = null
            if not immediate
                fn.apply ctx, args
        callNow = immediate and not timeout
        window.clearTimeout timeout
        timeout = window.setTimeout later, wait
        if callNow
            func.apply ctx, args

# config
WIDTH =  window.Inner
HEIGHT = 400

VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

# control creation
$container = $('#container')
renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
scene = new THREE.Scene()

# object creation
node = new Node('Example', [], {})
cube = node.mesh
light = new T.PointLight(0xFFFFFF)

# initial setup
for obj in [cube, light, camera]
    scene.add(obj)

cube.rotation.z = 100
light.position.x = 10
light.position.y = 50
light.position.z = 130

camera.position.z = 300
renderer.setSize WIDTH, HEIGHT
$container.append renderer.domElement

#### Window Resize Events
# ...
on_resize = ->
    renderer.setSize window.innerWidth, window.innerHeight
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()

# manually trigger...
on_resize()

# and bind event handler
window.addEventListener("resize", debounce(on_resize, 100), false)

#### Rendering loop
render = ->
    requestAnimationFrame(render)

    cube.rotation.y += 0.1


    # pull the trigger
    renderer.render(scene, camera)
render()
