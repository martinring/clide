define ['session'], (session) ->
  class Ribbon extends Backbone.View    
    el: '#ribbon'
    events:
      'click #sidebarButton': 'toggleSidebar'
    toggleSidebar: =>
      $('body').toggleClass('sidebar')
    append: (e) =>
      @$('.menu').append(e)

  class Search extends Backbone.View
    el: '#search'
    events:
      'click #searchButton': 'startSearch'
      'change #searchBox': 'changeSearch'
    startSearch: =>
      $('body').addClass('sidebar')
      setTimeout((-> $('#searchBox').focus()), 200)
    changeSearch: (e) =>
      #

  class FileItemView extends Backbone.View
    tagName: 'li'
    initialize: ->
      @$el.append "<a>#{@model}</a>"
    events: 
      'dblclick': 'open'
    open: =>
      @trigger 'open', @model

  class Section extends Backbone.View    
    tagName: 'li'
    className: 'section'    
    events:
      "click": "activate"      
    active: false
    timeout: null
    initialize: ->
      @ribbonIcon = $("<li>#{@options.icon}</li>")
      @ribbonIcon.on 'click', => 
        if @active
          @deactivate()
        else
          @activate()
          @center()
      @$el.append "<h1>#{@options.title}</h1>"
      @$el.append @options.content
      # @$el.on 'mouseenter', =>        
      #   @timeout = setTimeout(@activate,2000)
      # @$el.on 'mouseleave', =>
      #   clearTimeout(@timeout) if @timeout?
    center: =>
      top = @$el.position().top - 8
      currentST = $('#sidebarContent').scrollTop()
      $('#sidebarContent').animate
        scrollTop: currentST + top
    activate: => 
      if not @active 
        @active = true
        @$el.addClass 'active'      
        @ribbonIcon.addClass 'active'
        @trigger 'activate'
    deactivate: =>
      if @active
        @active = false
        @ribbonIcon.removeClass 'active'
        @$el.removeClass 'active'
        @trigger 'deactivate'

  class Sidebar extends Backbone.View
    el: '#sidebar'    
    search: new Search
    ribbon: new Ribbon         
    theories: new Section
      title: 'Theories'
      icon: 'l'
      content: $("<ul class='treeview'></ul>")
    edit: new Section
      title: 'Edit'
      icon: 'e'
      content: $("<ul class='treeview'></ul>")
    view: new Section
      title: 'View'
      icon: 'V'
      content: $("<ul class='treeview'></ul>")
    settings: new Section
      title: 'Settings'
      icon: 'S'
      content: $("<ul class='treeview'></ul>")
    help: new Section
      title: 'Help'
      icon: '?'
      content: $("<ul class='treeview'></ul>")
    currentSection: null
    addSection: (section) =>      
      section.on 'activate', =>
        if @currentSection?
          @currentSection.deactivate()
        $('body').addClass('sidebar')  
        @currentSection = section
      section.on 'deactivate', =>
        if @currentSection is section
          $('body').removeClass('sidebar')
          @currentSection = null
      @$('#sidebarContent').append(section.$el)
      @ribbon.append(section.ribbonIcon)
    initialize: ->
      @addSection(@theories)
      @addSection(@edit)
      @addSection(@view)
      @addSection(@settings)
      @addSection(@help)
      @model.on 'change:files', (model,files) =>
        treeview = $('.treeview')
        treeview.html('')
        for file in files
          view = new FileItemView model: file
          view.on 'open', (e) => @model.trigger 'open', e  
          treeview.append view.el

  class SidebarModel extends Backbone.Model
    defaults:
      files: []

  sidebar = new Sidebar 
    model: new SidebarModel

  return sidebar.model