class Bracketeer.Views.Index extends Bracketeer.Views.Bracket
  template: JST['backbone/templates/bracket']

  add_node_handles: ->
    self = @
    @bracket.dispatch.on 'enter_nodes', (onEnter) ->
      onEnter.append('text')
        .attr
          dy: 15
          dx: 5
          class: 'match-handler'
        .text('+')
        .on 'click', (d) =>
          self.toggle_children(d)

    @bracket.dispatch.on 'update_nodes', (onUpdate) ->
      onUpdate.select('.match-handler')
        .text (d) ->
          if d.left? || d.right?
            "-"
          else
            "+"


  toggle_children: (d) ->
    parent = @bracket.tree.at(d.position)

    if parent.left? || parent.right?
      parent.left = null
      parent.right = null
      parent.children = null
      parent.x = null
      parent.y = null

      @bracket.tree.depth.total = 0
      @bracket.tree.depth.left = 0
      @bracket.tree.depth.right = 0

    else
      parent.left =
        left: null,
        right: null,
        payload: {}
      parent.right =
        left: null,
        right: null,
        payload: {}

    @bracket.tree.recalculate_positions()
    @bracket.prepare_layout()
    @bracket.update()

  render: ->
    @add_node_handles()
    super
    @
