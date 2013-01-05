define ->
  class Tab extends Backbone.Model
    defaults:
      active: false
      title: 'unnamed'
      content: $('<div></div>')
    activate: =>
      console.log "activate #{@get 'title'}"
      @set active: true
    deactivate: =>
      @set active: false
    close: =>
      @deactivate()
      @get('content')?.remove?()
      @trigger 'close'