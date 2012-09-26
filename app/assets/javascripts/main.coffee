require.config
  baseUrl: '/assets/javascripts'

require ['editor'], (Editor) ->  
  class Project extends Backbone.Model
    defaults:
      name: ''

  class ProjectList extends Backbone.Collection
    model: Project
    url:   routes.controllers.Projects.listProjects('martinring').url

  class ProjectView extends Backbone.View
    tagName: 'li'
    initialize: ->
      _.bindAll @
      @model.bind 'change', @render
      @model.bind 'remove', @unrender
    render: ->
      $(@el).html("#{ @model.get 'name' }")
      return @
    unrender: ->
      $(@el).remove()

  class Backstage extends Backbone.View    
    el: $ '#backstage'
    events: ->
      'click #backstage': 'refresh'
    initialize: ->
      _.bindAll @
      @files = new ProjectList      
      @files.bind 'add', @add          
      @refresh()
    refresh: ->
      console.log('refreshing')
      @files.fetch success: => @render()      
    render: ->
      $(@el).empty()
      for file in @files.models
        view = new ProjectView model: file  
        $(@el).append(view.render().el)      
      return @
    add: (file) ->
      view = new ProjectView model: file
      $(@el).append view.render().el
    show: ->
      $(@el).removeClass 'hide'
    hide: ->
      $(@el).addClass 'hide'
    toggle: ->
      $(@el).toggleClass 'hide'
    isVisible: ->
      $(@el).hasClass 'hide'

  class AppRouter extends Backbone.Router
    initialize: ->
        @currentApp = new Tasks
            el: $("#main")
    routes:
        ""                          : "index"
        "/projects/:project/tasks"   : "tasks"
    index: ->
        # show dashboard
        $("#main").load "/ #main"
    tasks: (project) ->
        # load project || display app
        currentApp = @currentApp
        $("#main").load "/projects/" + project + "/tasks", (tpl) ->
            currentApp.render(project)          

  #backstage = new Backstage
  #backstage.show()  
  editor = new Editor 
    user: 'martinring'
    project: 'test'
    path: 'ex.thy'
  $('body').append editor.render().el