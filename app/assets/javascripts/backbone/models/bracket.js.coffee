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

    layout = d3.layout.tree().size([600,width])
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
    node = @svg.selectAll('g.node').data @tree.toArray(), (d,i) ->
      return d.position

    onEnter = node.enter().append('g')
      .attr
        class: 'node'
        id: (d) ->
          "node#{d.position}"
        transform:  (d, i) =>
          "translate(0,#{i * 50})" # render to initial location, will update later

    onEnter.append('rect')
      .attr
        width: @box_width
        height: @box_height
    
    node.transition()
      .each (d) =>
        # calculates the coordinate transposition. trees start L->R, we want to
        # flip it around
        p = @calcLeft(d)
        d.x1 = p.x

        d

      .duration(25)
      .attr 'transform', (d) =>
        p = @joinNodes(d) # moves nodes to their new position
        "translate(#{p.y},#{p.x})"

  calcLeft: (d) ->
    y = (@width / 2) - d.y - 125
    return { x: d.x, y: y }

  joinNodes: (d) ->
    me = @calcLeft d
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
