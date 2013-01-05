define ['ScalaConnector'], (ScalaConnector) ->
  class Command extends Backbone.Model
    defaults:
      version: 0
      name: "undefined"
      range:
        start: 0
        stop: 0
      body: null
      state: "no information"

  class Commands extends Backbone.Collection
    model: Command    
    getCommandAt: (line) => 
      all = @filter (x) ->
        range = x.get 'range'
        range.start <= line && range.end >= line
      sorted = _.sortBy(all, (c) -> c.get 'version')
      return sorted[sorted.length - 1]
    getTokenAt: (line,column) =>
      cmd = @getCommandAt(line)
      if (cmd?)
        range = cmd.get('range')
        tokens = cmd.get('tokens')
        tokenLine = tokens[line - range.start]
        i = 0
        token = tokenLine[i]
        pos = tokenLine[i].value.length          
        while pos < column
          i += 1
          token = tokenLine[i]
          pos += tokenLine[i].value.length
        return token

  class Theory extends Backbone.Model
    constructor: (args...) ->      
      super(args...)
      @set commands: new Commands
    defaults:
      name:           "unnamed"
      currentVersion: 0
      remoteVersion:  0
    open: =>
      @trigger 'open', @
    close: =>      
      @set 
        opened: false
        active: false
        progress: 0
      @trigger 'close', @    

  class Theories extends Backbone.Collection
    model: Theory

  class Session extends Backbone.Model    
    theories: new Theories
    openFiles: new Theories

    ready: false

    start: (@user,@project) =>
      @theories.on 'add', (thy) =>
        thy.on 'open', (x) => @open(x)
        thy.on 'change:active', (t,a) => if a then @scala.call
          action: 'setCurrentDoc'
          data: t.get 'path'
        thy.on 'change:perspective', (t,p) =>           
          @scala.call
            action: 'changePerspective'
            data: 
              path: t.get 'path'
              start: p.start
              end: p.end
        thy.on 'change:cursor', (t,p) =>
          cmd = t.get('commands').getCommandAt(p.line)
          old = thy.get 'currentCommand'
          if old? then old.set current: false
          if cmd? 
            cmd.set current: true
            thy.set currentCommand: cmd
          @set output: cmd?.get 'output' or ''
      @route = routes.controllers.Projects.getSession(@user,@project)
      @scala = new ScalaConnector(@route.webSocketURL(),@,@getTheories)
      @scala.socket.onclose = =>
        @set phase: 'failed'   

    check: (nodeName, version, content) =>      
      thy = @theories.get(nodeName)
      if version is thy.get 'currentVersion'        
        thy.trigger 'check', content
      else
        console.log "check failed for #{nodeName} due to different version numbers (remote: #{version}, local: #{thy.get 'currentVersion'})"        

    setPhase: (phase) =>
      @set
        phase: phase

    addTheory: (thy) =>
      @theories.add(thy)

    setFiles: (files) =>      
      @addTheory(thy) for thy in files              
      unless @ready
        @trigger 'ready' 
        @ready = true

    setLogic: (logic) =>
      @set logic: logic

    println: (msg) =>
      @trigger 'println', msg

    states: (node, states) =>      
      @theories.get(node).set
        states: states

    status: (node, unprocessed, running, finished, warned, failed) =>
      total = unprocessed + running + finished + warned + failed
      # unprocessed = 100.0 * unprocessed / total
      running = 100.0 * running / total      
      finished = 100.0 * finished / total
      warned = 100.0 * warned / total
      failed = 100.0 * warned / total      
      @theories.get(node).set status:
        finished: finished
        running: running
        warned: warned
        failed: failed
        done: (running + unprocessed is 0)

    dependency: (thy, dep) =>
      #console.log "theory #{thy} depends on #{dep}"

    commandChanged: (node, command) =>    
      #console.log "change ", command
      node = @theories.get(node)
      p = node.get 'cursor'      
      if p? and p.line >= command.range.start and p.line <= command.range.end
        @set
          output: command.output
      cmds = node.get('commands')
      node.set 
        remoteVersion: Math.max(node.get 'remoteVersion', command.version)
      old = cmds.get(command.id)
      if old?
        old.set(command)
      else
        node.get('commands').add(command)

    removeCommand: (node, command) =>
      node = @theories.get(node)
      cmds = node.get('commands')
      cmd = cmds.get(command)
      if cmd? 
        cmds.remove(cmd)

    open: (thy) =>
      @scala.call
        action: 'open'
        data:   thy.get('path')
        callback: (text) =>  
          thy.set
            opened: true        
          thy.trigger 'opened', text

    delete: (thy) =>
      @scala.call
        action: 'delete'
        data:   thy.get('path')
        callback: (done) =>
          if done
            @theories.remove(thy)

    new: (name) =>      
      if @theories.get(name)?
        return false
      else 
        @scala.call
          action: 'new'
          data:   name

    save: (all) =>
      alert(if all then "save all" else "save active")       


  session = new Session
  
  return session