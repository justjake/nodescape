# requires classes.coffee and constants.coffee to be already loaded

# good for unique IDs
ID = new Scape.Successor(0)

#### Scene setup

# control creation
$container = $('#container')
renderer = new THREE.WebGLRenderer()
mouse_cam = new Scape.MouseCamera(VIEW_ANGLE, 700)
camera = window.camera = mouse_cam.camera
scene = new THREE.Scene()

# create non-graph scene objects
size = 900
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


#### Mouse wheel zoom

# create a normalized mouse-wheel-scroll event function for future
# binding
handleWheelEvent = (handler) ->
    return (event) ->
        delta = 0
        # do we really need to support so many browsers?
        if !event # IE
            event = window.event
        if event.wheelDelta? # IE/opera
            delta = event.wheelDelta / 120
        else if event.detail # mozilla
            delta = -1 * event.detail / 3

        # call user CB when wheel is moving
        if delta != 0
            handler(delta)

        if event.preventDefault
            event.preventDefault()
        event.returnValue = false


# high code right here

        # scroll_speed = 0
        # scroll_delta = 0
        # 
        # always_accelerate_in_scroll_speed_direction = ->
        #     camera.position.z += scroll_speed
        # 
        # reset_scroll_delta =  debounce((->
        #     scroll_delta = 0), 12, false)
        # 
        # scroll_speed_fn = ->
        #     console.log('scroll speed window mover', scroll_speed, scroll_delta)
        #     # accell if scroll_delta
        #     scroll_speed += scroll_delta * 4
        # 
        #     # deaccell
        #     scroll_speed += (-1 * pos(scroll_speed)) if scroll_speed != 0
        #     scroll_delta += (-1 * pos(scroll_speed)) if scroll_speed != 0
        # 
        # 
        # scroll_camera_handler = handleWheelEvent (delta) ->
        #     console.log('scroll delta')
        #     scroll_delta = pos(delta)
        #     # debounce reset scroll speed
        #     reset_scroll_delta()

# start derping this system of equations
# window.setInterval(scroll_speed_fn, 1)
# window.setInterval(always_accelerate_in_scroll_speed_direction, 1)

prev_distance = false
scroll_camera_handler = handleWheelEvent (delta) ->
    camera.position.z += -1 * pos(delta) * 35
    prev_distance = false
    if Math.abs(camera.position.z) >= MAX_ZOOM
        camera.position.z = MAX_ZOOM * pos(camera.position.z)

on_mouse_down = (evt) ->
    if evt.button == 1 # middle mouse button
        if prev_distance != false
            camera.position.z = prev_distance
            prev_distance = false
        else
            prev_distance =  camera.position.z
            camera.position.z = 25 # zoom to a dramatic angle


#### Event Handlers

# window resize - reformat renderer to correct size, and scale camera
# accordingly while looking via the mouse
on_resize = ->
    renderer.setSize window.innerWidth - 10, window.innerHeight - 10
    mouse_cam.onResize()

# manually trigger...
on_resize()

# bind event handlers
window.addEventListener("resize", debounce(on_resize, 100), false)
document.addEventListener("mousemove", ((evt) ->  mouse_cam.mouseMove(evt)), false)
window.addEventListener("mousewheel", scroll_camera_handler, false)
document.addEventListener("mousedown", on_mouse_down, false)


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
