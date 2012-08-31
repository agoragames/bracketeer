class BracketTree
  constructor: (data) ->
    @load_data(data)

  load_data: (data) ->
    @_root = null
    @depth =
      total: 0
      left: 0
      right: 0
    @matches = []

    @size = 0

    if data?
      for seat in data.seats
        @add seat.position, seat

  update: (data, redraw = true) ->
    @load_data(data)
    if redraw
      @renderer.prepare_layout()
      @renderer.update()

  add: (position, seat) ->
    current = null
    node =
      left: null,
      right: null,
      payload: seat
      position: position
      render: seat.render

    if !@_root?
      @_root = node
      @depth.total = 1
      @depth.left  = 1
      @depth.right = 1
    else
      current = @_root
      current_depth = 2
      while true
        if node.position < current.position
          if !current.left?
            node.depth = current_depth
            current.left = node
            @size += 1
            @depth_check current_depth, node.position
            break
          else
            current = current.left
            current_depth += 1
        else if node.position > current.position
          if !current.right?
            node.depth = current_depth
            current.right = node
            @size += 1
            @depth_check current_depth, node.position
            break
          else
            current = current.right
            current_depth += 1
        else
          break

  depth_check: (depth, position) ->
    @depth.total = Math.max(depth, @depth.total)
    if position < @_root.position
      @depth.left = Math.max(depth, @depth.left)
    else if position > @_root.position
      @depth.right = Math.max(depth, @depth.right)

  traverse: (iterator) ->
    self = @

    in_order = (node, depth) ->
      if node?
        if node.left?
          in_order node.left, depth+1

        iterator.call @, node, depth+1

        if node.right?
          in_order node.right, depth+1

    in_order @_root, 0

  at: (position) ->
    found = null
    current = @_root

    while true
      if position == current.position
        found = current
        break
      else if position < current.position
        if current.left?
          current = current.left
        else
          break
      else if position > current.position
        if current.right?
          current = current.right
        else
          break
      else
        break

    found

  top_down: (starting_point = @_root, iterator) ->
    self = @

    td = (node) ->
      iterator.call @, node

      td(node.left) if node.left?
      td(node.right) if node.right?

    td starting_point, 0

  depth: ->
    if !@maxDepth?
      @maxDepth = 0
      @traverse (node, depth) =>
        if @maxDepth < depth
          @maxDepth = depth
    @maxDepth

  toArray: ->
    result = []
    @traverse (node) ->
      result.push(node)

    return result

  recalculate_positions: ->
    counter = 1
    @match_nodes_updated = []
    @traverse (node, depth) =>
      node.old_position = node.position
      node.position = counter
      @update_match_positions node.old_position, node.position
      @depth_check(depth, counter)
      counter += 1


  add_match: (nodes) ->
    @matches.push
      nodes: nodes
      winner_to: null
      loser_to: null

  update_match_positions: (old_pos, new_pos) ->
    @matches.forEach (m) ->
      if m.nodes[0] == old_pos || m.nodes[1] == old_pos
        match = m
      else if m.winner_to == old_pos
        winner_match = m
      else if m.loser_to == old_pos
        loser_match = m

    if match?
      if match.nodes[0] == old_pos && @match_nodes_updated.indexOf(old_pos) == -1
        match.nodes[1] = new_pos
      else if match.nodes[1] == old_pos && @match_nodes_updated.indexOf(old_pos) == -1
        match.nodes[1] = new_pos
    
    if winner_match? && @match_nodes_updated.indexOf(old_pos) == -1
      winner_match.winner_to = new_pos

    if loser_match? && @match_nodes_updated.indexOf(old_pos) == -1
      loser_match.loser_to = new_pos

    @match_nodes_updated.push(old_pos)

  as_json: ->
    json =
      matches: @matches
      seats: []
      starting_seats: []

    @top_down @_root, (node) ->
      seat =
        position: node.position

      json.seats.push(seat)

    json

window.BracketTree = BracketTree
