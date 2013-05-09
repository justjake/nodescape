#### Connect to the server over socket.io
socket = window.socket = io.connect(window.location.origin)

socket.on 'status', (data) ->
  # status messages are simple strings to report user status
  console.log 'server status:', data

socket.on 'nodes', (data) ->
  # nodes messages are arrays of updates nodes
  window.graph.updateNodes(data)

socket.on 'edges', (data) ->
  console.log('edge update', data)
  window.graph.updateEdges(data)
