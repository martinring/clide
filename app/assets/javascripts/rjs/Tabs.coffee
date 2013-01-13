####################################################################################################
#
# Copyright (c) 2012, 2013 All Right Reserved, Martin Ring
#
# This source is subject to the General Public License (GPL).
# Please see the License.txt file for more information.
# All other rights reserved.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# author:  Martin Ring
# email:   martinring@live.de
# summary: Tabs control
#
####################################################################################################

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
      close.on 'click', =>         
        @model.close()
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
      @trigger('close')
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