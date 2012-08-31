class Bracketeer.Views.Bracket extends Backbone.View
  el: '#nav'
  initialize: (@bracket) ->

  events:
    'click #match_mode'     : 'enter_match_mode'
    'click #node_mode'     : 'enter_node_mode'

  set_active_tab: (tab) ->
    $(".nav li").removeClass('active')
    $(tab).parent().addClass('active')
    @bracket.reset_dispatch()

  enter_match_mode: (e) ->
    @set_active_tab('#match_mode')
    Bracketeer.router.match()
    e.preventDefault()

  enter_node_mode: (e) ->
    @set_active_tab('#node_mode')
    Bracketeer.router.index()
    e.preventDefault()
    
  render: ->
    $('#bracketeer').html(@template())
    @bracket.render('#bracket')
    @
