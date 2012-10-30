define ->
  class ScalaConnector      
    constructor: (@url,@object,init) ->
      recieve = (e) =>        
        if e.action
          f = @object[e.action]
          if f
            result = f.apply(f,e.args) or null            
            if e.id then @socket.send JSON.stringify
              resultFor: e.id
              success: true
              data: result
          else
            if e.id then @socket.send JSON.stringify
              resultFor: e.id
              success: false
              message: "action '#{e.action}' does not exist"
            else console.error "action '#{e.action}' does not exist"
        else
          callback = @results[e.resultFor]
          if callback
            callback(e.data)
            @results[e.resultFor] = null
      ready = false
      @isReady = () -> ready
      @socket = new WebSocket(@url)      
      @socket.onmessage = (e) -> recieve(JSON.parse(e.data))
      if init? then @socket.onopen = (e) -> init()

    id: 0

    results: []

    call: (options) ->
      console.log(options)
      if options and options.action        
        if options.callback
          @results[@id] = options.callback
          options.id = @id
          @id += 1
        @socket.send JSON.stringify(options)
      else
        console.error 'no action defined'