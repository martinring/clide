define ->
  class AppRouter extends Backbone.Router
    initialize: ->
        @currentApp = new Tasks
            el: $("#main")
    routes:
        ""                         : "index"
        "/projects/:project/tasks" : "tasks"
    index: ->
        # show dashboard
        $("#main").load "/ #main"
    tasks: (project) ->
        # load project || display app
        currentApp = @currentApp
        $("#main").load "/projects/" + project + "/tasks", (tpl) ->
            currentApp.render(project)    