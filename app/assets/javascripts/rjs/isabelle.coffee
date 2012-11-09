define ['ScalaConnector'], (ScalaConnector) ->
  class Command extends Backbone.Model
    defaults:
      name: ""
      body: null

  class Commands extends Backbone.Collection
    model: Command

  class Theory extends Backbone.Model
    constructor: (args...) ->
      @commands = new Commands
      super(args...)
    defaults:      
      name: "unnamed"
    open: =>
      @trigger 'open', @
    close: =>
      @set progress: 0
      @trigger 'close', @

  class Theories extends Backbone.Collection
    model: Theory

  class Session extends Backbone.Model    
    theories: new Theories
    openFiles: new Theories

    start: (@user,@project) =>
      console.log ("initializing session")
      @theories.on 'add', (thy) =>
        thy.on 'open', (x) => @open(x)
        thy.on 'change:perspective', (t,p) => @scala.call
          action: 'changePerspective'
          data: 
            path: t.get 'path'
            start: p.start
            end: p.end
        thy.on 'change:cursor', (t,p) => @scala.call
          action: 'moveCursor'
          data:
            path: t.get 'path'
            pos: p
      @route = routes.controllers.Projects.getSession(@user,@project)
      @scala = new ScalaConnector(@route.webSocketURL(),@,@getTheories)

    setPhase: (phase) =>
      @set
        phase: phase

    setFiles: (files) =>
      console.log(files)
      for thy in files        
        @theories.add(thy)        

    setLogic: (logic) =>
      @set logic: logic

    println: (msg) =>
      @trigger 'println', msg

    status: (node, unprocessed, running, finished, warned, failed) =>
      total = unprocessed + running + finished + warned + failed
      # unprocessed = 100.0 * unprocessed / total
      running = 100.0 * running / total      
      finished = 100.0 * finished / total
      warned = 100.0 * warned / total
      failed = 100.0 * warned / total
      console.log node, @theories.get(node)
      @theories.get(node).set 
        finished: finished
        running: running
        warned: warned
        failed: failed    

    commandChanged: (node, command, span) =>      
      #console.log("#{command} in #{node} changed: ", span)

    open: (thy) =>
      @scala.call
        action: 'open'
        data: thy.toJSON()
        callback: (text) =>
          console.log 'opened', thy
          thy.trigger 'opened', text

  session = new Session
  
  return session