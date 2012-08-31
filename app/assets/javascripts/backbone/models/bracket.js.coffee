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
    @width = (@tree.depth.total) * (125+15) # node width + connector space

    @layout = d3.layout.tree().size([500,@width])
    @layout.children (d) ->
      if d?
        children = []

        if d.left?
          children.push d.left

        if d.right?
          children.push d.right

        return children
      else
        return null

    @layout.nodes @tree._root

  children: (d) ->
    if d?
      children = []

      if d.left?
        children.push d.left

      if d.right?
        children.push d.right

      return children
    else
      return null

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
    nodes = @tree.toArray()
    @svg.attr 'width', Math.max(@width + 400, 1000)
    @draw_nodes nodes
    @draw_connections nodes

    nodes

  draw_nodes: (nodes) ->
    node = @svg.selectAll('g.node').data nodes, (d,i) ->
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

    onUpdate.select('.match-handler')
      .text (d) ->
        if d.left? || d.right?
          "-"
        else
          "+"

    node.exit().remove()

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
        class: 'match-handler'
      .text('+')
      .on 'click', @toggle_children
        
  draw_connections: (nodes) ->
    link = @svg.selectAll('path.link')
      .data @layout.links(nodes), (d, i) ->
        d.target.id

    link.enter().insert('path', 'g')
      .attr
        class: 'link'
        id: (d) ->
          "line#{d.source.position}-#{d.target.position}"
        d: (d) =>
          o =
            x: nodes[0].x,
            y: nodes[0].y

          result = @connector
            source: o,
            target: o

    link.transition()
      .duration(25)
      .attr
        d: (d) =>
          @connector(d)
        id: (d) ->
          "line#{d.source.position}-#{d.target.position}"
        
    link.exit().remove()

  connector: (d) =>
    source = @join_nodes(d.source)
    target = @join_nodes(d.target)

    hy = (target.y + @box_width - source.y) / 2
    hv = target.x+(@box_height/2)
    x = source.x+(@box_height/2)

    if d.target.parent? && d.target.parent.children?
     if d.target.parent.children[0] == d.target
       hv += (@box_height / 2)
     else
       hv -= (@box_height / 2)
    
    return "M#{source.y},#{x}H#{source.y+hy}V#{hv}H#{target.y}"

  toggle_children: (d) =>
    parent = @tree.at(d.position)

    if parent.left? || parent.right?
      parent.left = null
      parent.right = null
      parent.children = null
      parent.x = null
      parent.y = null

      @tree.depth.total = 0
      @tree.depth.left = 0
      @tree.depth.right = 0

    else
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
    l = @width - d.y + 250
    return { x: d.x, y: l }

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
