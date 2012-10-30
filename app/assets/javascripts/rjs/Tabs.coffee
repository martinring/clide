define ->   
  class TabView extends Backbone.View
    initialize: =>
      @$el.text(@model.get 'title')
      @model.on 'change:active', (model,active) =>
        @$el.toggleClass 'active', active
        if active 
          @trigger 'activate', @
      @activate
    tagName: 'li'
    events:
      'click': 'activate'
      'contextmenu': 'contextMenu'
    activate: =>
      @model.set active: true      
    deactivate: =>
      @model.set active: false      
    contextMenu: (e) =>
      e.preventDefault()
      console.log('context menu')

  class Tabs extends Backbone.View
    constructor: (@el) ->
      super()
    initialize: ->
      @$el.addClass 'tabs'
      @pane = $ "<ul class='tabpane'></ul>"
      @content = $ "<div class='tabcontent'></div>"
      @$el.append(@pane).append(@content)
    current: null
    render: => @
    add: (tab) =>
      view = new TabView model: tab
      view.content = $(tab.get 'content')
      view.on 'activate', (activated) =>
        if @current?
          @current.deactivate()
          @current.content.removeClass('active')
        @current = activated
        activated.content.addClass('active')
      @content.append(view.content)
      @pane.append(view.el)
      tab.set active: true