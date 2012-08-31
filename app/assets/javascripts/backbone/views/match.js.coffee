class Bracketeer.Views.Match extends Bracketeer.Views.Bracket
  template: JST['backbone/templates/match']

  add_match_handlers: ->
    self = @
    @bracket.dispatch.on 'enter_nodes', (onEnter) ->
      onEnter.append('text')
        .attr
          dy: 15
          dx: 110
          class: 'match-handler'
        .text (d) ->
          if d.parent?
            if d.parent.children[0] == d
              d.seed = 'top'
              "W"
            else
              d.seed = 'bottom'
              "L"

          else
            ""
        .on 'click', (d) =>
          if d.parent?
            self.selection_in_progress = true
            self.selection_start = d.position
            self.selection_type = d.seed
            $("#bracket").append("<div id='modal'>You have selected #{d.position}. Click on a node circle to map.</div>")

      onEnter.append('circle')
        .attr
          class: 'state-end'
          cy: 10
          cx: 10
          r: 6

        .on 'click', (d) =>
          if self.selection_in_progress
            selection_end = d.position
            $("#modal").remove()

            self.bracket.add_progression self.selection_type, self.selection_start, selection_end

  render: ->
    @add_match_handlers()
    super

    @
