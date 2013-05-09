module.exports = (app) ->
  # nice utility function
  randomInRange = (min, max) ->
    min + Math.floor(Math.random() * (max - min + 1))

  getFromTo = (nc) ->
    from = to = randomInRange(0, nc - 1)
    to = randomInRange(0, nc - 1) until to != from
    return [from, to]

  generateNode = (i) ->
    {id: i, name: "Example #{i}", classes: [], data: {activity: randomInRange(-200, 200)}}

  class app.RandomGraph
    node_count = 15
    edge_count = 15

    constructor: ->
      @node_update_queue = []
      @edge_update_queue = []


      @active_nodes = []
      @active_edges = []
      @inactive_nodes = [100, 101, 102, 103, 104, 105]
      @inactive_edges = []

      first_node_updates = {}
      first_edge_updates = {}

      for i in [0..node_count]
        first_node_updates[i] = generateNode(i)
        @active_nodes.push i

      for i in [0..edge_count]
        [from, to] = getFromTo(node_count)
        first_edge_updates[i] = {id: i, from: from, to: to, classes: [], data: {}}
        @active_edges.push i

      # push updates into update queue
      @node_update_queue.push(first_node_updates)
      @edge_update_queue.push(first_node_updates)

    # pushes random updates into the update queues
    queueUpdates: ->
      node_updates = {}

      # randomly delete one node
      n = randomInRange(0, @active_nodes.length - 1)
      id_to_delete = @active_nodes[n]
      node_updates[id_to_delete] = null
      # remove from active, add to inactive
      @active_nodes.splice(n, 1)
      @inactive_nodes.push(id_to_delete)

      # update 4 nodes
      for _ in [0..3]
        n = randomInRange(0, @active_nodes.length - 1)
        id = @active_nodes[n]
        node_updates[id] = {id: id, data: {activity: randomInRange(-200, 200)}}

      # add one node back
      n = randomInRange(0, @inactive_nodes.length - 1)
      id_to_add = @inactive_nodes[n]
      node_updates[id_to_add] = generateNode(id_to_add)
      # remove from inactive, add to active
      @inactive_nodes.splice(n, 1)
      @active_nodes.push(id_to_add)

        # submit node updates to queue
      @node_update_queue.push(node_updates)
