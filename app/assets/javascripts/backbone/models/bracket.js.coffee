class Bracketeer.Models.Bracket extends Backbone.Model
  initialize: ->
    @tree = new BracketTree()
    @tree.add(2, {
      player: 'player1',
      seed_value: 1
    })
    @tree.add(1, {
      player: 'player1',
      seed_value: 1,
      match_wins: 3,
      round: 1
    })
    @tree.add(3, {
      player: 'player2',
      seed_value: 2,
      match_wins: 0,
      round: 1
    })

    @box_width = 125
    @box_height = 20
    @width = 1000
    @height = 600


  prepare_layout: ->
    # h/w transposed to rotate 90'
    width = (@tree.depth.total - 1) * (@box_width + 15) # node width + connector space
    @tree._root.x0 = 0
    @tree._root.y0 = 0

    layout = d3.layout.tree().size([700,width])
    layout.children (d) ->
      if d?
        children = []

        if d.left?
          children.push d.left

        if d.right?
          children.push d.right

        return children
      else
        return null

    layout.nodes @tree._root

  render: (selector) ->
    @selector = selector
    @svg = d3.select(selector).append('svg')
      .attr
        id: 'bracket_svg'
        width: @width
        height: @height

    @prepare_layout()
    @update()

  update: ->
    @draw_nodes()

  draw_nodes: ->
    node = @svg.selectAll('g.node').data @tree.toArray(), (d,i) ->
      parent_position = if d.parent?
       d.parent.position
      else
        -1
      d.id = "#{parent_position}:#{d.depth}:#{d.position}"
      return d.id

    onEnter = node.enter().append('g')
      .attr
        class: 'node'
        transform:  (d, i) =>
          "translate(0,#{i * 50})" # render to initial location, will update later
    
    @draw_box onEnter
    @draw_position onEnter
    @draw_handlers onEnter

    onUpdate = node.transition()

    onUpdate.each (d) =>
      # calculates the coordinate transposition. trees start L->R, we want to
      # flip it around
      p = @calc_left(d)
      d.x1 = p.x

      d

    .duration(150)
    .attr 'transform', (d) =>
      p = @join_nodes(d) # moves nodes to their new position
      "translate(#{p.y},#{p.x})"

    onUpdate.select('.position')
      .text (d) ->
        d.position

    onUpdate.attr 'id', (d) ->
      "node#{d.position}"

    node.exit().remove() # not calling? WTF?

  draw_box: (handler) ->
    handler.append('rect')
      .attr
        width: @box_width
        height: @box_height

  draw_position: (node) ->
    node.append('text')
      .attr
        dy: 15
        dx: 60
        class: 'position'
        'text-anchor': 'middle'
      .text (d) ->
        d.position

  draw_handlers: (node) ->
    node.append('text')
      .attr
        dy: 15
        dx: 5
        class: 'add-match-handle'
      .text('+')
      .on 'click', (d) =>
        @add_match_to_tree d.position

  add_match_to_tree: (position) ->
    # This part sucks. BracketTree is based on positions within the tree, and
    # we are throwing a monkey-wrench in that by appending in a weird spot.
    # we have to use some re-calculation code after adding the nodes.
    #
    # In addition, we have a depth bug because we aren't going through the
    # normal channels of addition via position.  This poses a problem on a
    # number of levels
    parent = @tree.at(position)
    unless parent.left? || parent.right?
      parent.left =
        left: null,
        right: null,
        payload: {}
      parent.right =
        left: null,
        right: null,
        payload: {}

      @tree.recalculate_positions()
      @prepare_layout()
      @update()

  calc_left: (d) ->
    y = (@width / 2) - d.y - 125
    return { x: d.x, y: y }

  join_nodes: (d) ->
    me = @calc_left d
    differential = 0
    x = d.x1 || d.x

    if d.parent?
      round = if d.payload.round
        d.payload.round
      else
        @tree.depth.total - d.depth - 2

      if d.parent.children[0] == d
        sibling = d.parent.children[1]
        differential = ((sibling.x1 - d.x1) / 2) - (@box_height / 2)
      else
        sibling = d.parent.children[0]
        differential = 0 - ((d.x1 - sibling.x1) / 2) + (@box_height / 2)

    return { x: x + differential, y: me.y }

class Bracketeer.Collections.BracketsCollection extends Backbone.Collection
  model: Bracketeer.Models.Bracket
  url: '/brackets'
