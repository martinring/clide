define ['icons','contextMenu'], (icons,menu) ->   
  class TabView extends Backbone.View
    initialize: =>
      @$el.text(@model.get 'title')
      close = $("<a class='icon'>#{icons.close}</a>")
      @$el.append close
      close.on 'click', @close
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
    close: =>
      @model.trigger 'close'
      @trigger 'close', @
    contextMenu: (e) =>
      e.preventDefault()      
      menu.show(e.pageX,e.pageY,[          
          text: 'Close'
          command: @close
        ,
          text: 'Close Others'
          command: @close
        ,
          text: 'Close All'
          command: @close
        ])
      #@close()
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
      view.on 'close', (closed) =>
        closed.$el.remove()
        closed.content.remove()
        @current = null if @current is closed
      @content.append(view.content)
      @pane.append(view.el)
      tab.set active: true