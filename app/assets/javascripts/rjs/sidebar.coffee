define ['isabelle','settings','commands','icons','contextMenu'], (isabelle,settings,commands,icons,menu) ->
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
      'keyup #searchBox': 'changeSearch'
      'change #searchBox': 'changeSearch'
    startSearch: =>
      $('body').addClass('sidebar')
      setTimeout((-> $('#searchBox').focus()), 200)
    changeSearch: (e) =>
      commands.search.execute($('#searchBox').val())      

  class FileItemView extends Backbone.View
    tagName: 'li'
    className: 'theory'
    initialize: =>
      icon = $("<div class='icon'>#{icons.file}</div>")
      title = $("<div class='title'><span class='name'>#{@model.get 'path'}</span></div>")      
      message = $("<span class='message'>#{@model.get 'path'}</span>")
      progress = $("<div class = 'progress'></div>")
      f = $("<div class='finished'></div>")
      r = $("<div class='running'></div>")
      w = $("<div class='warned'></div>")
      fl = $("<div class='failed'></div>")
      progress.append f, r, w, fl
      title.append progress
      @model.on 'change:status', (m,s) ->
        f.animate width: (s.finished + "%")
        if s.failed > 0
          icon.text(icons.minus)
        if s.warned > 0
          icon.text(icons.shield)        
        else if s.running > 0
          icon.text(icons.clock)          
        else
          icon.text(icons.check)
          
        r.animate width: s.running + "%"
        w.animate width: s.warned + "%"

        fl.animate width: s.failed + "%"
      @model.on 'change:active', (m,active) =>
        @$el.toggleClass 'selected', active
      @$el.append icon, title
    events:
      'click'       : 'open'      
      'contextmenu' : 'contextMenu'
    open: =>
      commands.open.execute(@model)
    contextMenu: (e) =>
      e.preventDefault()
      menu.show(e.pageX,e.pageY,[                  
          text: 'Open'
          command: @open
        ,
          text: 'Delete'
          command: => if confirm("Do you really want to delete theory '#{@model.get 'id'}'?")
            isabelle.delete(@model)
        ,
          text: 'Rename'
          command: => prompt('Enter new name',@model.get 'id')        
        ])

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
      if @options.buttons?
        @buttons = $("<div class='buttons'></div>")
        @$el.append @buttons        
        for button in @options.buttons        
          bv = $("<div class='button'>#{button.icon}</div>")
          bv.on 'click', => @options.content[button.action]()
          @buttons.append bv
      if @options.content.length        
        @$el.append x.$el for x in @options.content
      else 
        @content = @options.content
        @$el.append @content.$el      
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

  class CommandGroup extends Backbone.View
    tagName: 'ul'
    className: 'commandGroup'
    initialize: =>
      @render()
    render: =>      
      @$el.append x for x in @options.content

  class Command extends Backbone.View
    tagName: 'li'
    className: 'command'
    initialize: =>
      @a = $("<a title='#{@options.text}'>#{@options.text}</a>")
      @a.attr('data-icon',@options.icon)
      @$el.append(@a)
      @a.on 'click', @options.command.execute

  class CheckBox extends Backbone.View
    tagName: 'li'
    className: 'checkBox'

  class DropBox extends Backbone.View
    tagName: 'li'
    className: 'dropBox'

  class TheoriesView extends Backbone.View
    tagName: 'ul'
    className: 'treeview'
    initialize: =>
      @collection = isabelle.theories      
      @collection.on 'add', @render
      @collection.on 'remove', @render
      @render()
    render: =>
      @$el.html('')
      @collection.forEach (theory) =>        
        view = new FileItemView model: theory
        @$el.append(view.el)
    new: (again) =>
      name = prompt(if again then "Invalid name. Enter different name" else "Enter name")
      if /^[a-zA-Z0-9]+$/.test(name)
        unless isabelle.new(name)
          @new(true)        
      else if name?
        @new(true)
        
    save: =>
      isabelle.save()

  class HelpView extends Backbone.View
    tagName: 'div'
    initialize: =>
      #isabelle.on 'change:output', (m,out) => @$el.html(out)
      @render()
    render: =>
      @$el.text('Copyright 2012 by Martin Ring')

  class Sidebar extends Backbone.View
    el: '#sidebar'    
    search: new Search
    ribbon: new Ribbon   
    theories: new Section
      title: 'Theories'
      icon: icons.list
      content: new TheoriesView
      buttons: [
        icon: icons.save
        action: "save"
      ,
        icon: icons.plus
        action: "new"      
      ]
    edit: new Section
      title: 'Edit'
      icon: icons.edit
      content: [
        new CommandGroup 
          content: [
            new Command
              text: 'Cut'
              icon: icons.cut
              command: commands.cut
            new Command
              text: 'Copy'
              icon: icons.copy
              command: commands.copy
            new Command
              text: 'Paste'
              icon: icons.paste
              command: commands.paste
          ]
      ]
    view: new Section
      title: 'View'
      icon: icons.view
      content: [
        new Command
          text: 'Show Linenumbers'
          icon: icons.checkbox.checked
          command: commands.copy
      ]

    settings: new Section
      title: 'Settings'
      icon: icons.settings
      content: [
        new Command
          text: 'Copy'
          icon: 'c'
          command: commands.copy
      ]

    help: new Section
      title: 'Help'
      icon: icons.help
      content: new HelpView    

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
      @theories.activate()
      
  return new Sidebar