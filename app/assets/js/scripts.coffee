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

#class MouseCamera
    #constructor: (view_angle, z) ->
        #@camera = new T.PerspectiveCamera(view_angle, ASPECT, NEAR, FAR)
        #@camera.position.z = z

        #@mouseX: 0
        #@mouseY: 0

        #@windowHalfX: window.innerWidth / 2
        #@windowHalfY: window.innerHeight / 2

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

registartion = (width, stroke) ->
    t = new T.Vector3(width / 2, 0, 0)
    b = new T.Vector3(width / 2, width, 0)
    l = new T.Vector3(0, width / 2, 0)
    r = new T.Vector3(width, width / 2, 0)
    geo = new T.Geometry()
    geo.vertices.push t, b, l, r
    mat = new T.LineBasicMaterial
        linewidth: stroke
        linecap: 'butt'
        color: 0xffcc00

    return new T.Line(geo, mat, T.LinePieces)

reg_field = (min, max, spacing, size) ->
    group = new T.Object3D
    count = Math.floor((max - min) / spacing)
    for y in [min..max] by spacing
        for x in [min..max] by spacing
            reg = registartion(size, 2)
            group.add(reg)
            reg.position.y = y
            reg.position.x = x
            # reg.position.z = Math.random() * size

    return group



# control creation
$container = $('#container')
renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
scene = new THREE.Scene()

# object creation
reg = reg_field(-500, 500, 70, 10)
node = new Node('Example', [], {})
cube = node.mesh
light = new T.PointLight(0xFFFFFF)

# initial setup
for obj in [cube, light, camera, reg]
    scene.add(obj)

cube.rotation.z = 100
light.position.x = 10
light.position.y = 50
light.position.z = 130
reg.position.x = 15
reg.position.z = -40

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
