define ->
  class Tab extends Backbone.Model
    defaults:
      active: false
      title: 'unnamed'
      content: $('<div></div>')
    activate: =>
      @set active: true