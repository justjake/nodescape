# requires classes.coffee and constants.coffee to be already loaded

# good for unique IDs
ID = new Scape.Successor(0)

#### Scene setup

# control creation
$container = $('#container')
renderer = new THREE.WebGLRenderer()
mouse_cam = new Scape.MouseCamera(VIEW_ANGLE, 700)
camera = mouse_cam.camera
scene = new THREE.Scene()

# create non-graph scene objects
size = 500
spacing = 80
reg_red = Scape.reg_field(-1 * size, size, spacing, 10, ORANGERED)
reg_oj = Scape.reg_field(-1 * size, size, spacing * 2, 10, ORANGE)
light = new T.PointLight(0xFFFFFF)
# add objs to scene so they can be displayed
for obj in [light, camera, reg_red, reg_oj]
    scene.add(obj)

# create node graph
window.graph = new Scape.Graph(scene)
# and add 1-10 nodes to it
node_count = Math.floor(Math.random() * 10)
for i in [0..node_count]
    graph.addNode(new Scape.Node(ID.next(), 'Example', [], {activity: 200 * Math.random()}))

# set properties on non-graph scene objects
camera.position.z = 500
light.position.x = 10
light.position.y = 50
light.position.z = 130
reg_oj.position.z = 50
reg_red.position.z = -50

# set up renderer
renderer.setSize WIDTH, HEIGHT
$container.append(renderer.domElement)



#### Event Handlers
on_resize = ->
    renderer.setSize window.innerWidth - 10, window.innerHeight - 10
    mouse_cam.onResize()

# manually trigger...
on_resize()

# bind event handlers
window.addEventListener("resize", debounce(on_resize, 100), false)
document.addEventListener("mousemove", ((evt) ->  mouse_cam.mouseMove(evt)), false)


#### Rendering loop
render = ->
    requestAnimationFrame(render)

    # move camera about
    mouse_cam.onRender(scene)

    # render graph
    graph.onRender(scene)

    # pull the trigger
    renderer.render(scene, camera)
render()
