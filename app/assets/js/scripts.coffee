# console.log './scape2'

# screw typing THREE
window.T = window.THREE

# config
WIDTH =  window.innerWidth
HEIGHT = window.innerHeight

VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

ORANGERED = 0x862104
ORANGE    = 0xe89206

class MouseCamera
    transform = .05
    offset = 200
    constructor: (view_angle) ->
        @camera = new T.PerspectiveCamera(view_angle, ASPECT, NEAR, FAR)

        @mouseX = 0
        @mouseY = 0

        @windowHalfX = window.innerWidth / 2
        @windowHalfY = window.innerHeight / 2

    onResize: ->
        @windowHalfX = window.innerWidth / 2
        @windowHalfY = window.innerHeight / 2
        @camera.aspect = window.innerWidth / window.innerHeight
        @camera.updateProjectionMatrix()

    mouseMove: (evt) ->
        @mouseX = evt.clientX - @windowHalfX
        @mouseY = evt.clientY - @windowHalfY
        console.log("mm", this)

    onRender: (scene) ->
        @camera.position.x += (@mouseX - camera.position.x) * transform
        @camera.position.y += (- @mouseY + offset - camera.position.y) * transform
        @camera.lookAt(scene.position)


class Node
    # these are local variables, and are not accessable outside
    # of THIS class closure
    baseGeometry = new T.CubeGeometry(40, 40, 40)
    baseMaterial = new T.MeshLambertMaterial
        color: 0x333333
        ambient: 0x000000
        emissive: ORANGE
        refractionRatio: 0

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

registartion = (width,  mat) ->
    t = new T.Vector3(width / 2, 0, 0)
    b = new T.Vector3(width / 2, width, 0)
    l = new T.Vector3(0, width / 2, 0)
    r = new T.Vector3(width, width / 2, 0)
    geo = new T.Geometry()
    geo.vertices.push t, b, l, r

    return new T.Line(geo, mat, T.LinePieces)

reg_field = (min, max, spacing, size, color) ->
    group = new T.Object3D
    count = Math.floor((max - min) / spacing)
    mat = new T.LineBasicMaterial
        linewidth: 2
        linecap: 'butt'
        color: color
    for y in [min..max] by spacing
        for x in [min..max] by spacing
            reg = registartion(size, mat)
            group.add(reg)
            reg.position.y = y
            reg.position.x = x
            # reg.position.z = Math.random() * spacing

    return group



# control creation
$container = $('#container')
renderer = new THREE.WebGLRenderer()
mouse_cam = new MouseCamera(VIEW_ANGLE, 700)
camera = mouse_cam.camera
# camera = new T.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
scene = new THREE.Scene()

# object creation
#size = Math.max(window.innerWidth, window.innerHeight, 1000)
size = 500
spacing = 80
reg_red = reg_field(-1 * size, size, spacing, 10, ORANGERED)
reg_oj = reg_field(-1 * size, size, spacing * 2, 10, ORANGE)

node = new Node('Example', [], {})
cube = node.mesh
light = new T.PointLight(0xFFFFFF)

# initial setup
for obj in [cube, light, camera, reg_red, reg_oj]
    scene.add(obj)

camera.position.z = 500
cube.rotation.z = 100
light.position.x = 10
light.position.y = 50
light.position.z = 130
reg_oj.position.z = 50
reg_red.position.z = -50

renderer.setSize WIDTH, HEIGHT
$container.append renderer.domElement

#### Window Resize Events
# ...
on_resize = ->
    renderer.setSize window.innerWidth, window.innerHeight
    mouse_cam.onResize()

# manually trigger...
on_resize()

# and bind event handler
window.addEventListener("resize", debounce(on_resize, 100), false)
document.addEventListener("mousemove", ((evt) ->  mouse_cam.mouseMove(evt)), false)

#### Rendering loop
render = ->
    requestAnimationFrame(render)

    cube.rotation.y += 0.1

    # move camera about
    mouse_cam.onRender(scene)

    # pull the trigger
    renderer.render(scene, camera)
render()
