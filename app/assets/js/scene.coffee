# requires classes.coffee and constants.coffee to be already loaded

# good for unique IDs
ID = new Scape.Successor(0)

#### Scene setup
scene = new THREE.Scene()
mouse_cam = new Scape.MouseCamera(VIEW_ANGLE, MAX_ZOOM, SNAP_DISTANCE)
camera = window.camera = mouse_cam.camera

#### Graph set-up

# create node graph
create_graph = ->
  if window.graph?
    window.graph.destroy()
  node_count = randomInRange(6, 20)
  edge_count = randomInRange(node_count, node_count * 2)
  window.graph = Scape.Graph.RandomGraph(scene, node_count, edge_count)

create_graph()



# create non-graph scene objects
size = 900
spacing = 80
reg_red = Scape.reg_field(-1 * size, size, spacing, 10, ORANGERED, false)
reg_oj = Scape.reg_field(-1 * size, size, spacing * 2, 10, ORANGE, true)
bg = window.bg =  Scape.grid(30, 40, spacing, 0x220000, 1)
light = new T.PointLight(0xFFFFFF)
# add objs to scene so they can be displayed
for obj in [light, camera,bg, reg_red, reg_oj]
    scene.add(obj)


# set properties on non-graph scene objects
camera.position.z = (node_count ? 15) * 80
light.position.x = 0
light.position.y = 0
light.position.z = 500
reg_oj.position.z = 50
reg_red.position.z = -50
bg.position.x = -1935
bg.position.y = -895
bg.position.z = -55
# bg.rotation.x = 2 * Math.PI - (Math.PI / 4)





#### Rendering effects
# set up renderer
renderer = new THREE.WebGLRenderer(clearColor: 0x0e0000)
# required for effects to function. (?) not well documented
renderer.autoClear = false

renderer.setSize(WIDTH, HEIGHT)
$('#container').append(renderer.domElement)

# composer, for our effect passes
composer = window.composer = new T.EffectComposer(renderer)
composer.addPass(new T.RenderPass(scene, camera))

# bloom effect
# params: (strength = 1, kernelSize = 26, sigma = 4.0, resolution = 256)
bloomEffect = new T.BloomPass(.9, 25, 4.0, 256)
composer.addPass(bloomEffect)

# copy - required for bloom (?) - no documentation
copyEffect = new T.ShaderPass(T.CopyShader)
composer.addPass(copyEffect)

# last effect should render to screen
composer.passes[composer.passes.length - 1].renderToScreen = true


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
window.addEventListener("DOMMouseScroll", mouse_cam.boundMouseScroll, false)
document.addEventListener("mousedown", ((evt) -> mouse_cam.onMouseDown(evt)), false)
$(window).on 'keyup', (evt) ->
  console.log('keypress', evt)
  if evt.which == 49  # the '1' key
    create_graph() # rebuild the graph with new params!

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

# oh, and also animate CRAZYTUDE
# (prop_name, range, mid, step = 0.04, rate = 40)
window.animate_constant('CRAZYTUDE', 0.07, 0.01, 0.01)
# window.animate_constant('LINE_MIDPOINT', 0.2, 0.5)
