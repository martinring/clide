define ->
  class Tab extends Backbone.Model
    defaults:
      active: false
      title: 'unnamed'
      content: $('<div></div>')
    activate: =>
      @set active: true
    deactivate: =>
      @set active: false
    close: (silent) =>
      @deactivate()
      @get('content')?.remove?()
      @trigger 'close' unless silent