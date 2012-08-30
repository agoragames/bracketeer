class BracketTree
  constructor: (data) ->
    @load_data(data)

  load_data: (data) ->
    @_root = null
    @depth =
      total: 0
      left: 0
      right: 0

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

window.BracketTree = BracketTree
