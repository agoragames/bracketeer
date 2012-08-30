class Bracketeer.Routers.BracketsRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '' : 'new'

  new: ->
    @bracket = new Bracketeer.Models.Bracket
    @bracket.render('#bracket')
    
    window.bracket = @bracket
