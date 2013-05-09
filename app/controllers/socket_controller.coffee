module.exports = (app) ->
  class app.SocketsController

    # channels
    STATUS = 'status'
    NODES = 'nodes'
    EDGES = 'edges'
    DISCONNECT = 'disconnect'

    @graph = new app.RandomGraph()
    @connectionCount = 0

    @graphUpdateInterval = null
    @cursors = {}

    @connection = (socket) =>
      console.log "\n\n\n\n\n NEW CONNECTION \n\n\n\n\n\n\n"
     
      # business logic in the clientConnected function generator
      @clientConnected(socket)

      # routes
      socket.on STATUS,     @statusRecieved
      socket.on NODES,      @nodesRecieved
      socket.on EDGES,      @edgesRecieved
      socket.on DISCONNECT, @clientDisconnected(socket)


    @updateClientGraph = (socket, graph) -> =>
      # get current position in queue
      pos = @cursors[socket.id]
      return if pos is undefined  # we disconnected

      # update nodes
      while pos.nodes < graph.node_update_queue.length
        socket.emit NODES, graph.node_update_queue[pos.nodes]
        pos.nodes += 1

      # update edges
      while pos.edges < graph.edge_update_queue.length
        socket.emit EDGES, graph.edge_update_queue[pos.edges]
        pos.edges += 1

    @statusRecieved = (data) ->
      console.log('Status from client:', data)
    @nodesRecieved = @edgesRecieved = (data) ->
      console.log("node/edge from client (?)", data)

    @clientConnected = (socket) ->
      @cursors[socket.id] = {nodes: 0, edges: 0, update: null}
      @connectionCount += 1
      socket.emit(STATUS, 'connected')
      
      # start generating graph updates
      if @graphUpdateInterval == null
        console.log("Starting graph changes")
        @graphUpdateInterval = setInterval (=> @graph.queueUpdates()), 200

      # periodically tell this client about our edges/nodes updates
      @cursors[socket.id].update = setInterval @updateClientGraph(socket, @graph), 200


    @clientDisconnected = (socket) => (data) =>
      # no more updates to this client
      clearInterval(@cursors[socket.id].update)

      # delete client information
      delete @cursors[socket.id]
      @connectionCount -= 1

      # stop generating graph updates if this is the last client
      if @graphUpdateInterval and @connectionCount == 0
        console.log("Pausing graph changes")
        clearInterval(@graphUpdateInterval)

      

