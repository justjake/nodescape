# requires constants.coffee be loaded first

#### Class library.
# We may want to move classes into thier own files eventually

# Gaussian function
# a = height of curve
# b = curve position on X axis
# c = width of standard deviation
# TODO: oops this doesn't work the way i expect
window.gaussian = gaussian = (a, b, c) -> (x) ->
  a * Math.pow(Math.E, -1 * Math.pow(x - b, 2) / (2 * c*c))

# returns a height from 0 to 1 for x from 0..length



# manage add/removing nodes from the graph. HASHMAP - the class

class Graph

    circle = (theta, r) ->
        return [r * Math.cos(theta), r * Math.sin(theta)]

    # I'm unsure if this is the right approach vs keeping a count
    # property updated
    # Doesn't work in IE8
    count = (hash) ->
        Object.keys(hash).length


    @RandomGraph = (scene, node_count, edge_count) ->
      graph = new Graph(scene)
      for i in [0..node_count]
          graph.addNode(new Scape.Node(i, 'Example', [], {activity: 200 * Math.random()}))
          
      # create some edges!
      for i in [0..edge_count]
          to = graph.nodes[ randomInRange(0, node_count) ]
          from = to
          # choose different end point
          from = graph.nodes[ randomInRange(0, node_count) ] until from != to
          graph.addEdge(new Scape.Edge(i, to, from, [], {}))
      return graph

    constructor: (@scene)  ->
        @nodes = {}
        @edges = {}
        @_cnodes = 0
        @_cedges = 0


    # Tears down the graph by deleting all the edges then all the nodes
    # also nullifies the onRender method by replacing it with a no-op
    # function
    destroy: ->
      for id, _ of @edges
        @deleteEdge(id)

      for id, _ of @nodes
        @deleteNode(id)

      @onRender = (->)


    # Create/Update/Delete based on a JSON node data structure
    # node_data is a map[int]Object as defined in format.js
    # TODO: is this class the right place to have the updateElements
    # functionality? Or should that be a function performed on the
    # class?
    _updateElements: (store, datas, updater, creator) ->
        for id, data of datas
            if store[id]?
                if data == null or typeof data isnt "object"
                    # sent id: null or id: reason_string, delete element with id
                    @_delFrom(store, id)
                    break
                # update existing node
                updater(store[id], data, this)
            else
                # create new element using passed creator function
                # Node.NewFromData will return undefined if data does not have the required fields
                @_addTo(store, creator(data, this))

    updateNodes: (datas) ->
        @_updateElements(@nodes, datas, Node.UpdateFromData, Node.NewFromData)

    updateEdges: (datas) ->
        @_updateElements(@nodes, datas, Edge.UpdateFromData, Edge.NewFromData)

    # adding and removing graph members
    # behavior is mostly the same for edges and nodes
    _addTo: (hash, obj) ->
        hash[obj.id] = obj
        @scene.add(obj.mesh)
        @_cnodes = count(@nodes) # not pretty :(
        @_cedges = count(@edges) # TODO: make pretty
        obj

    _delFrom: (hash, id) ->
        obj = hash[id]
        @scene.remove(obj.mesh)
        delete hash[id]
        @_cnodes = count(@nodes)
        @_cedges = count(@edges)
        obj

    addNode: (node) ->
        @_addTo(@nodes, node)

    deleteNode: (id) ->
        @_delFrom(@nodes, id)

    addEdge: (edge) ->
        @_addTo(@edges, edge)

    deleteEdge: (id) ->
        @_delFrom(@edges, id)

    onRender: ->
        scene = @scene

        # render each node
        # circle gets bigger based on how many nodes we have
        r = @radius = @_cnodes * Node.SIZE / 2 + Node.SIZE
        idx = 0
        for _, node of @nodes
            node.onRender(scene)
            # lay out in circle
            [x, y] = circle(idx / (@_cnodes) * 2 * Math.PI, r)
            # animate into position
            node.mesh.position.x += animateTo(x, node.mesh.position.x, MOVEMENT_RATE)
            node.mesh.position.y += animateTo(y, node.mesh.position.y, MOVEMENT_RATE)
            idx += 1

        # render each edge
        for _, edge of @edges
            edge.onRender(scene)


# a node in a Graph
# represented in a Three.js scene by node.mesh
class Node
    # these are local variables, and are not accessable outside
    # of THIS class closure
    baseGeometry = new T.CubeGeometry(40, 40, 40)
    baseMaterial = new T.MeshLambertMaterial
        color: ORANGE
        # ambient: 0x000000
        emissive: 0x220000
        shininess: 40
        # refractionRatio: 0

    @SIZE = 40 #TODO: make this dynamic vs baseGeometry

    # FACTORY1111!!!!!
    @NewFromData = (data) ->
        return new Node(data.id, data.name, data.classes, data.data)

    @UpdateFromData = (node, data) ->
        node.name =    data.name if data.name?
        node.classes = data.classes if data.classes?
        node.data =    data.data if data.data?
        node.update() # signal ending update transaction

    
    # id, classes, properties auto-saved to those object properties
    constructor: (@id, @name, @classes, @data) ->
        if ! @id?
            throw "All nodes must have an ID"

        @mesh = new T.Mesh(baseGeometry, baseMaterial)
        @mesh.rotation.x = 100

    onRender: (scene) ->
        if @data.activity?
            @mesh.rotation.y += @data.activity / K

    update: ->
        # nothing.
        # TODO: change appearance based on @classes

# a directional connection between two nodes
# right now just represented by a two-point line
# TODO: allow for different line types
class Edge
    baseMaterial = ->  new T.LineBasicMaterial(
        color: 0xffffff
        linewidth: window.LINE_WIDTH
        linecap: "round"
        vertexColors: T.VertexColors
    )

    # FACTORY1111!!!!!
    @NewFromData = (data, graph) ->
        return new Edge(data.id, graph.nodes[data.to], graph.nodes[data.from], data.classes, data.data)

    @UpdateFromData = (edge, data, graph) ->
        # Don't update from/to - destroy the edge and create a new one
        # instead, bro
        # edge.to =      graph.nodes[data.to] if data.to?
        # edge.from =    graph.nodes[data.from] if data.from?
        if data.from? or data.to?
            throw "Cannot update edge's nodes: create a new edge instead"

        edge.classes = data.classes if data.classes?
        edge.data =    data.data if data.data?
        edge.update() # signal ending update transaction

    # actually draw a line
    # see http://workshop.chromeexperiments.com/projects/armsglobe/js/visualize_lines.js
    @DLG = (start, end) ->
      start = start.clone()
      end = end.clone()

      POINTS_WANTED = 50 # over the whole curve

      distance = start.clone().sub(end).length()
      height = 0.3 * distance
      width = distance / 2 # where the STD dev is

      color = new T.Color(ORANGE)
      hsl = color.getHSL()
      geo = new T.Geometry()
      f = window.latest_f = gaussian(height, 0.5, Math.sqrt(0.05))
      for i in [0..POINTS_WANTED]
        p = start.clone().lerp(end, i / POINTS_WANTED)
        p.z = f(i / POINTS_WANTED)
        c = new T.Color(0xffffff)
        c.setHSL(hsl.h, hsl.s, (p.z / height) / 2)
        geo.vertices.push(p)
        geo.colors.push(c)

      return geo

    @DrawLine = (start, end, rotation) ->
      start = start.clone()
      end = end.clone()

      # length between start and end points
      distance = start.clone().sub(end).length()
      # how high we want to arc the line
      height = 0.2 * distance

      # midpoint
      mid = start.clone().lerp(end, 0.5)
      mid.z = height

      # the normal (?) i should read a book
      normal = (new T.Vector3()).subVectors(start, end)
      normal.normalize()

      #         The curve looks like this:
      #         
      #         midStartAnchor---- mid ----- midEndAnchor
      #         /                                       \
      #        /                                         \
      #       /                                           \
      #   start/anchor                                 end/anchor
      #           splineCurveA              splineCurveB
      # 

      distanceHalf = distance / 2

      startAnchor = start
      midStartAnchor = mid.clone().add(normal.clone().multiplyScalar(distanceHalf))
      midEndAnchor = mid.clone().add(normal.clone().multiplyScalar(-1 * distanceHalf))
      endAnchor = end

      # make bezier curve
      splineA = new T.CubicBezierCurve3 start, startAnchor, midStartAnchor, mid
      splineB = new T.CubicBezierCurve3 mid, midEndAnchor, endAnchor, end

      # number of points desired, per side
      vertexCount = Math.floor(distance * 0.02 + 6) * 2
     
      # collect points
      points = splineA.getPoints(vertexCount)
      points = points[0...-1] # remove last point because it will be duplicated
      points = points.concat(splineB.getPoints(vertexCount))

      # create colors
      i = 0
      len = points.length
      colors = []
      color = new T.Color(window.LINE_COLOR)
      hsl = color.getHSL()
      # gaussian color distribution along the points
      # shrinking values of C (the Math.sqrt para) gives more contrast
      # LINE_MIDPOINT is 0.5 usually, but can be adjusted to
      # animate all lnes at the same time!
      f = window.latest_f = gaussian(0.5, window.LINE_MIDPOINT, Math.sqrt(0.02))
      for v in points
        colors[i] = new T.Color(0xFFFFFF)
        # color is half of gaussian because the bloom filter
        # seems to double lightness values!
        colors[i].setHSL(hsl.h, hsl.s, f(i/len)) 
        # derp the point a bit, sometimes
        if Math.random() > (1 - window.CRAZYTUDE)
          v.z += Math.random() * v.z / 4 
          colors[i].offsetHSL(Math.random() / 2, 0, 0.4)
        i += 1

      # create geometry
      geo = new T.Geometry()
      geo.vertices = points
      geo.colors = colors
      geo.verticesNeedUpdate = true
      return geo

    constructor: (@id, @to, @from, @classes, @data) ->
        if ! @id?
            throw "All edges must have an ID"

        # nodes must be active in-engine
        for node in [@from, @to]
            if node.mesh is undefined
                throw "All nodes must be fully initialized"
            
        @start = @from.mesh.position.clone()
        @end =  @to.mesh.position.clone()
        geo = @constructor.DrawLine(@start, @end)
        @mesh = new T.Line(geo, baseMaterial())

    onRender: (scene) ->
        # TODO
        # move verticies
        scene.remove(@mesh)
        @end.copy(@to.mesh.position)
        @start.copy(@from.mesh.position)
        geo = @constructor.DrawLine(@start, @end)
        @mesh = new T.Line(geo, baseMaterial())
        scene.add(@mesh)


    update: ->
        # TODO

  
# Basic scene camera that looks in the direction of the mouse
class MouseCamera
    transform = .05
    offset = 200
    MOUSE_SCROLL_DISTANCE = 35
    # converts a handler that understands deltas into a handler that
    # undertands cross-browser mousewheel events
    createWheelEventHandler = (handler) ->
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

    constructor: (view_angle, max_distance, quick_snap) ->
        @camera = new T.PerspectiveCamera(view_angle, ASPECT, NEAR, FAR)

        @mouseX = 0
        @mouseY = 0

        @windowHalfX = window.innerWidth / 2
        @windowHalfY = window.innerHeight / 2

        @prevScrollDistance = false
        @maxDistance = max_distance
        @snapDistance = quick_snap

        @boundMouseScroll = createWheelEventHandler (delta) =>
            @onMouseScroll(delta)

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

    onMouseScroll: (delta) ->
        @camera.position.z += -1 * pos(delta) * MOUSE_SCROLL_DISTANCE
        @prevScrollDistance = false
        if Math.abs(@camera.position.z) >= @maxDistance
            @camera.position.z = @maxDistance * pos(@camera.position.z)

    onMouseDown: (evt) ->
        if evt.button == 1 # middle mouse button
            if @prevScrollDistance != false
                camera.position.z = @prevScrollDistance
                @prevScrollDistance = false
            else
                @prevScrollDistance = camera.position.z
                camera.position.z = @snapDistance # zoom to a dramatic angle




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

grid = (w, h, spacing = 200, color, line_width) ->
  mat = new T.LineBasicMaterial
    color: color
    linewidth: line_width
  geo = new T.Geometry()
  min_x = 0
  max_x = w * spacing
  min_y = 0
  max_y = h * spacing
  for x_r in [0..w]
    x = x_r * spacing
    geo.vertices.push(new T.Vector3(x, min_y, 0))
    geo.vertices.push(new T.Vector3(x, max_y, 0))
  for y_r in [0..h]
    y = y_r * spacing
    geo.vertices.push(new T.Vector3(min_x, y, 0))
    geo.vertices.push(new T.Vector3(max_x, y, 0))
  return new T.Line(geo, mat, T.LinePieces)


reg_field = (min, max, spacing, size, color, txtify) ->
    group = new T.Object3D
    count = Math.floor((max - min) / spacing)
    mat = new T.LineBasicMaterial
        linewidth: 2
        linecap: 'butt'
        color: color
    txtmat = new T.MeshBasicMaterial
        color: color

    for y in [min..max] by spacing
            for x in [min..max] by spacing
                reg = registration(size, mat)
                group.add(reg)
                reg.position.y = y
                reg.position.x = x

                if txtify
                    generate_text = ->
                        txt_geo = new T.TextGeometry("#{x}, #{y}",
                            bevelEnabled: false
                            size: TEXT_SIZE
                            height: 0 # extrude distance
                            font: "droid sans"
                            curveSegments: 1
                            weight: "normal"
                            style: "normal"
                        )
                        txt = new T.Mesh(txt_geo, txtmat)
                        group.add(txt)
                        txt.position.x = x + size
                        txt.position.y = y - (TEXT_SIZE / 1.5)
                    # window.setTimeout(generate_text, y * 100 + x * 10)
                    generate_text()
        

            # reg.position.z = Math.random() * spacing
    return group


#### exports
Scape = Scape ? {}
Scape.Graph = Graph
Scape.Node = Node
Scape.Edge = Edge
Scape.Successor = Successor
Scape.MouseCamera = MouseCamera
Scape.registration = registration
Scape.reg_field = reg_field
Scape.grid = grid

window.Scape = Scape
