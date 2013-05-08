# requires constants.coffee be loaded first

#### Class library.
# We may want to move classes into thier own files eventually

# manage add/removing nodes from the graph. HASHMAP - the class
class Graph

    RADIUS = 200
    MOVEMENT_RATE = 3
    circle = (theta, r) ->
        return [r * Math.cos(theta), r * Math.sin(theta)]


    constructor: (@scene)  ->
        @nodes = {}
        @edges = {}
        @_cnodes = 0
        @_cedges = 0

    # Create/Update/Delete based on a JSON node data structure
    # node_data is a map[int]Object as defined in format.js
    updateNodes: (node_data) ->
        for id, data of node_data
            if @nodes[id]?
                if data is null
                    # sent id: null, delete node with id
                    @deleteNode(id)
                    break
                # update existing node
                @nodes[id].name =       data.name if data.name?
                @nodes[id].classes =    data.classes if data.classes?
                @nodes[id].properties = data.properties if data.properties?
                @nodes[id].update() # signal ending update transaction
            else
                # create new node
                # Node.NewFromData will return undefined if data does not have the required fields
                @addNode(Node.NewFromData(data))


    addNode: (node) ->
        @nodes[node.id] = node
        @scene.add(node.mesh)
        @_cnodes += 1

    deleteNode: (id) ->
        n = @nodes[id]
        @scene.remove(n.mesh)
        delete @nodes[id]
        @_cnodes -= 1

    onRender: ->
        scene = @scene
        # render each node
        idx = 0
        # circle gets bigger based on how many nodes we have
        r = @_cnodes * Node.SIZE / 2 + Node.SIZE
        for _, node of @nodes
            node.onRender(scene)
            # lay out in circle
            [x, y] = circle(idx / (@_cnodes) * 2 * Math.PI, r)
            # animate into position
            node.mesh.position.x += animateTo(x, node.mesh.position.x, MOVEMENT_RATE)
            node.mesh.position.y += animateTo(y, node.mesh.position.y, MOVEMENT_RATE)
            idx += 1

        for _, edge of @edges
            edge.onRender(scene)


# Basic scene camera that looks in the direction of the mouse
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

    onRender: (scene) ->
        @camera.position.x += (@mouseX - @camera.position.x) * transform
        @camera.position.y += (- @mouseY + offset - @camera.position.y) * transform
        @camera.lookAt(scene.position)


# a node in a Graph
# represented in a Three.js scene by node.mesh
class Node
    # these are local variables, and are not accessable outside
    # of THIS class closure
    baseGeometry = new T.CubeGeometry(40, 40, 40)
    baseMaterial = new T.MeshLambertMaterial
        color: 0x333333
        ambient: 0x000000
        emissive: ORANGE
        refractionRatio: 0

    @SIZE = 40 #TODO: make this dynamic vs baseGeometry

    # FACTORY1111!!!!!
    @NewFromData = (data) ->
        return new Node(data.id, data.name, data.classes, data.properties)

    
    # id, classes, properties auto-saved to those object properties
    constructor: (@id, @name, @classes, @properties) ->
        if ! @id?
            throw "All nodes must have an ID"

        @mesh = new T.Mesh(baseGeometry, baseMaterial)
        @mesh.rotation.x = 100

    onRender: (scene) ->
        if @properties.activity?
            @mesh.rotation.y += @properties.activity / K

# returns bigger numbers.
class Successor
    constructor: (int) ->
        @val = int
    next: ->
        @val += 1

#### Three.js element creators
registration = (width,  mat) ->
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
            reg = registration(size, mat)
            group.add(reg)
            reg.position.y = y
            reg.position.x = x
            # reg.position.z = Math.random() * spacing
    return group


#### exports
Scape = Scape ? {}
Scape.Graph = Graph
Scape.Node = Node
Scape.Successor = Successor
Scape.MouseCamera = MouseCamera
Scape.registration = registration
Scape.reg_field = reg_field

window.Scape = Scape
