define ['ScalaConnector'], (ScalaConnector) ->  
  class Session extends Backbone.Model
    constructor: (@route) ->
      @scala = new ScalaConnector(@route,@)
      super()            

    setPhase: (phase) =>
      @set
        phase: phase

    setFileTree: (fileTree) =>
      @set
        fileTree: fileTree

    commandChanged: (node, command) =>
      console.log("#{command} in #{node} changed")

    open: (path, callback) =>
      @scala.call
        action: 'open'
        data: path
        callback: callback

  route = routes.controllers.Projects.getSession('martinring','test')
  return new Session(route.webSocketURL())