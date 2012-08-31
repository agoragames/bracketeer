class Bracketeer.Routers.BracketsRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '' : 'index'

  index: ->
    @bracket = new Bracketeer.Models.Bracket
    view = new Bracketeer.Views.Index @bracket
    view.render()
    
    Bracketeer.view = view
    Bracketeer.bracket = @bracket
  match: ->
    view = new Bracketeer.Views.Match @bracket
    view.render()
