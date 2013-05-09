# requires classes.coffee and constants.coffee to be already loaded

# good for unique IDs
ID = new Scape.Successor(0)

#### Scene setup

# control creation
$container = $('#container')
scene = new THREE.Scene()
renderer = new THREE.WebGLRenderer
    alpha: false
    clearColor: 0x110000
    antialias: true
    clearApha: 1
renderer.autoClear = false

mouse_cam = new Scape.MouseCamera(VIEW_ANGLE, MAX_ZOOM, SNAP_DISTANCE)
camera = window.camera = mouse_cam.camera

#### Graph set-up
# create node graph
window.graph = new Scape.Graph(scene)
# and add 1-10 nodes to it
node_count = randomInRange(6, 20)
edge_count = randomInRange(node_count, node_count * 2)
for i in [0..node_count]
    graph.addNode(new Scape.Node(i, 'Example', [], {activity: 200 * Math.random()}))
# create some edges!
for i in [0..edge_count]
    to = graph.nodes[ randomInRange(0, node_count) ]
    from = to
    # choose different end point
    from = graph.nodes[ randomInRange(0, node_count) ] until from != to
    graph.addEdge(new Scape.Edge(i, to, from, [], {}))

# create non-graph scene objects
size = 900
spacing = 80
reg_red = Scape.reg_field(-1 * size, size, spacing, 10, ORANGERED, false)
reg_oj = Scape.reg_field(-1 * size, size, spacing * 2, 10, ORANGE, true)
light = new T.PointLight(0xFFFFFF)
# add objs to scene so they can be displayed
for obj in [light, camera, reg_red, reg_oj]
    scene.add(obj)


# set properties on non-graph scene objects
camera.position.z = node_count * 80
light.position.x = 0
light.position.y = 0
light.position.z = 500
reg_oj.position.z = 50
reg_red.position.z = -50

# set up renderer
renderer.setSize WIDTH, HEIGHT
$container.append(renderer.domElement)

#### Rendering effects
pipeline = window.pipeline = {
    render: new T.RenderPass(scene, camera)
    # fxaa: new T.ShaderPass(T.FXAAShader)
    bloom:  new T.BloomPass(0.9)
    copy:   new T.ShaderPass(T.CopyShader)
}
# pipeline.fxaa.uniforms['resolution'].value.set(1/WIDTH, 1/HEIGHT)
pipeline.copy.renderToScreen = true

composer = window.composer = new T.EffectComposer(renderer)
for pass in [pipeline.render,  pipeline.bloom, pipeline.copy]
    composer.addPass(pass)


#### Event Handlers
# Mouse wheel zoom
# create a normalized mouse-wheel-scroll event function for future
# binding

# window resize - reformat renderer to correct size, and scale camera
# accordingly while looking via the mouse
on_resize = ->
    renderer.setSize window.innerWidth, window.innerHeight
    # pipeline.fxaa.uniforms['resolution'].value.set(1/window.innerWidth, 1/window.innerHeight)
    mouse_cam.onResize()
    composer.reset()

# manually trigger...
on_resize()

# bind event handlers
window.addEventListener("resize", debounce(on_resize, 100), false)
document.addEventListener("mousemove", ((evt) ->  mouse_cam.mouseMove(evt)), false)
window.addEventListener("mousewheel", mouse_cam.boundMouseScroll, false)
document.addEventListener("mousedown", ((evt) -> mouse_cam.onMouseDown(evt)), false)

animate = ->
    requestAnimationFrame(animate)
    render()

render = ->
    # move camera about
    mouse_cam.onRender(scene)

    # render graph
    graph.onRender(scene)

    # pull the trigger
    renderer.clear()
    composer.render()
   
# start render loop
animate()
