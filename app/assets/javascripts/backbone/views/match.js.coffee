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
            $("#bracket").append(JST['backbone/templates/modal'](d: d))
            $(".state-end").attr('class', 'state-end')
            $(".progression").attr('class','progression invisible')

      onEnter.append('circle')
        .attr
          class: 'state-end invisible'
          cy: 10
          cx: 10
          r: 6

        .on 'click', (d) =>
          if self.selection_in_progress
            selection_end = d.position
            $("#modal").remove()

            $("#node#{selection_end} .progression").text(self.selection_start)
            self.bracket.add_progression self.selection_type, self.selection_start, selection_end
            self.selection_in_progress = false
            self.selection_start = null
            self.selection_type = null
            $(".state-end").attr('class', 'state-end invisible')
            $(".progression").attr('class','progression')

      onEnter.append('text')
        .attr
          class: 'progression'
          dx: 5
          dy: 15
    @bracket.dispatch.on 'update_nodes', (onUpdate) =>
      tree = @bracket.tree
      onUpdate.select('.progression').text (d) ->
        match = _.find tree.matches, (match) ->
          match.winner_to == d.position || match.loser_to == d.position

        if match?
          return match.nodes[0]

        return ""




  render: ->
    @add_match_handlers()
    super

    @
