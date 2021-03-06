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
# summary: The sidebar
#
####################################################################################################

define ['isabelle','settings','commands','icons','contextMenu','Dialog'], (isabelle,settings,commands,icons,menu,Dialog) ->
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
      'click': 'startSearch'      
    startSearch: =>      
      commands.search.execute()

  class FileItemView extends Backbone.View
    tagName: 'li'
    className: 'theory'
    initialize: =>
      icon = $("<div class='icon'>#{icons.file}</div>")
      name = $("<span class='name'>#{@model.get 'path'}</span>")
      title = $("<div class='title'></div>")      
      message = $("<span class='message'>#{@model.get 'path'}</span>")
      progress = $("<div class = 'progress'></div>")
      f = $("<div class='finished'></div>")
      r = $("<div class='running'></div>")
      w = $("<div class='warned'></div>")
      fl = $("<div class='failed'></div>")
      progress.append f, r, w, fl
      title.append name, progress
      @model.on 'change:status', (m,s) ->
        f.animate width: (s.finished + "%")
        if s.failed > 0
          icon.text(icons.minus)
        if s.warned > 0
          icon.text(icons.shield)        
        else if s.running > 0
          icon.text(icons.clock)          
        else if s.finished == 100
          icon.text(icons.check)
        else
          icon.text(icons.minus)
        r.animate width: s.running + "%"
        w.animate width: s.warned + "%"

        fl.animate width: s.failed + "%"
      @model.on 'change:active', (m,active) =>
        @$el.toggleClass 'selected', active
      @model.on 'change:clean', (m,clean) =>
        name.text((if clean then '' else '*') + (@model.get 'path'))
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
          command: => 
            new Dialog
              title: "Delete Theory"
              message: "Do you really want to delete theory '#{@model.get 'id'}'?"
              buttons: ['Yes','No']
              defaultAction: 'Yes'
              done: (e) => if e.action is 'Yes' then isabelle.delete(@model)
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
          bv.on 'click', @options.content[button.action]
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
      @$el.append x.$el for x in @options.content

  class Command extends Backbone.View
    tagName: 'li'
    className: 'command'
    initialize: =>
      @icon = $("<div class='icon'>#{@options.icon}</div>")
      @a = $("<div class='title'><a class='name' title='#{@options.text}'>#{@options.text}</a></div>")
      @$el.append(@icon,@a)
      @a.on 'click', @options.command.execute

  class CheckBox extends Backbone.View
    tagName: 'li'
    className: 'command'
    initialize: =>
      @isChecked = settings.get(@options.setting) or false
      @icon = $("<div class='icon'>#{icons.checkbox.fromBool(@isChecked)}</div>")
      @a = $("<div class='title'><a class='name' title='#{@options.text}'>#{@options.text}</a></div>")
      @$el.append(@icon,@a)
      @$el.on 'click', =>
        @isChecked = not @isChecked
        attrs = {}
        attrs[@options.setting] = @isChecked
        settings.set attrs        
      settings.on "change:#{@options.setting}", (m,v) =>
        @isChecked = v
        @icon.text(icons.checkbox.fromBool(@isChecked))


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
      dia = new Dialog
        title: 'New Theory'
        message: if again is true
            '<p>You entered an invalid name which is either taken or not supported</p><p>Please enter a valid name</p>'
          else 
            'Please enter a name for the new theory file (without the .thy-extension)'
        defaultText: ''
        buttons: ['Ok','Cancel']
        defaultAction: 'Ok'
        done: (e) => switch e.action
          when 'Ok'           
            if /^[a-zA-Z0-9]+$/.test(e.text)
              unless isabelle.new(e.text)
                @new(true)
            else
              @new(true)          
    save: =>
      isabelle.save()

  class HelpView extends Backbone.View
    tagName: 'div'
    className: 'content'
    initialize: =>
      #isabelle.on 'change:output', (m,out) => @$el.html(out)
      @render()
    render: =>
      @$el.append($ """
          <span>
            clide is a diploma thesis project, copyright 2012 by Martin Ring.</br>
            Have a look at the <a href="/assets/thesis.pdf">documentation</a>.</br>            
          </span>
          """)

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
        new CommandGroup
          content: [
            new Command
              text: 'Insert Symbol'
              icon: icons.symbol
              command: commands.insertSym          
            new Command
              text: 'Bold'
              icon: icons.bold
              command: commands.bold
           new Command
              text: 'Superscript'
              icon: icons.sup
              command: commands.sup
            new Command
              text: 'Subscript'
              icon: icons.sub
              command: commands.sub
            new Command
              text: 'Superscript (Identifiers)'
              icon: icons.isup
              command: commands.isup
            new Command
              text: 'Subscript (Identifiers)'
              icon: icons.isub
              command: commands.isub
          ]
        new CommandGroup
          content: [
            new Command
              text: 'Cancel Execution'
              icon: icons.cancel
              command: commands.cancel
          ]          
      ]
    view: new Section
      title: 'View'
      icon: icons.view
      content: [
        new CommandGroup
          content: [
            new CheckBox
              text: 'Linenumbers'
              setting: 'showLineNumbers'
            new CheckBox
              text: 'Inline States'
              setting: 'inlineStates'
            new CheckBox
              text: 'Inline Errors'
              setting: 'inlineErrors'
            new CheckBox
              text: 'Output Panel'
              setting: 'outputPanel'
          ]
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
      title: 'About'
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
      #@addSection(@settings)
      @addSection(@help)
      @theories.activate()
      
  return new Sidebar