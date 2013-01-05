define ['icons','contextMenu'], (icons,menu) ->   
  class TabView extends Backbone.View
    tagName: 'li'
    events:
      'click': 'activate'
      'contextmenu': 'contextMenu'
    initialize: =>
      @$el.text(@model.get 'title')
      close = $("<a class='icon'>#{icons.close}</a>")
      @$el.append close
      close.on 'click', @model.close
      @model.on 'change:active', (model,active) =>
        if active
          @$el.addClass 'active'
          @model.get('content').addClass 'active'
        else
          @$el.removeClass 'active'
          @model.get('content').removeClass 'active'
      @model.on 'close', @close
    activate: =>
      @model.set active: true
    deactivate: =>
      @model.set active: false
    close: =>
      @$el.remove()
    closeOthers: =>
      @options.tabs.closeOthers(@model)
    closeAll: => 
      @options.tabs.closeAll()
    contextMenu: (e) =>
      e.preventDefault()
      menu.show(e.pageX,e.pageY,[
          text: 'Close'
          command: @close
        ,
          text: 'Close Others'
          command: @closeOthers
        ,
          text: 'Close All'
          command: @closeAll
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
    stack: []        
    push: (tab) =>
      @remove(tab)
      @stack.unshift(tab)
    pop: =>
      @stack.shift()
    top: =>
      @stack[0]
    remove: (tab) =>
      @stack = _.filter(@stack, (x) -> x isnt tab)
    closeAll: () =>
      for tab in @stack 
        tab.close()
    closeOthers: (that) =>
      for tab in @stack when tab isnt that
        tab.close()
    render: => @
    add: (tab) =>
      view = new TabView 
        model: tab
        tabs: this
      tab.on 'change:active', (activated,active) => if active
        current = @top()        
        if current? and current isnt activated
          current.deactivate()
        @push(tab)
      tab.on 'close', =>
        if @top() is tab
          @remove(tab)
          @top()?.activate()
        else
          @remove(tab)
        tab.off()
      @content.append(view.model.get 'content')
      @pane.append(view.el)
      tab.set active: true