define ["ace/lib/event_emitter"], (EventEmitter) ->
  # the remote tokenizer synchronizes with a websocket to
  # let a server do the tokenization  
  class RemoteTokenizer extends EventEmitter.EventEmitter
  	constructor: (@session, @route) ->
      @fallback = @session.bgTokenizer
      @session.bgTokenizer = this
      @doc = @session.getDocument()
      @socket = new WebSocket(@route.webSocketURL())
      @socket.onmessage = (e) => @$updateRemote(JSON.parse(e.data))

    current_version: 0
    deltas: []
    lines: []

    pushDelay: 700

    setDocument: (document) =>
      @fallback.setDocument(document)

    setTokenizer: (tokenizer) =>
      @fallback.setTokenizer(tokenizer)

    fireUpdateEvent: (firstRow, lastRow) =>
      @session._emit "tokenizerUpdate",
        data:
          first: firstRow
          last: lastRow

    start: (startRow) =>
      @fallback.start(startRow)

    stop: =>
      @fallback.stop()

    getTokens: (row) =>
      @lines[row] or @fallback.getTokens(row)

    getState: (row) =>
      @fallback.getState(row)

    $pushTimeout: null

    $updateRemote: (e) => switch e.type
      when 'row'
        if e.version is @current_version 
          @lines[e.index] = e.row        
          @fireUpdateEvent(e.index,e.index)        
        else
          console.log("ignoring changes for version #{e.version} (actual: #{@current_version})")

    $pushChanges: =>
      console.log("version #{ @current_version }")
      @socket.send JSON.stringify @deltas      
      @deltas = []

    $updateOnChange: (delta) =>
      range = delta.range
      startRow = range.start.row
      len = range.end.row - startRow

      if len is 0
        @lines[startRow] = false
      else if delta.action is "removeText" or delta.action is "removeLines"
        @lines.splice(startRow, len + 1, false);        
      else
        args = Array(len + 1)
        args.unshift(startRow, 1)
        @lines.splice.apply(this.lines, args)        

      @fallback.$updateOnChange(delta)            
      @current_version += 1 if @deltas.length is 0
      @deltas.push(delta)
      clearTimeout(@$pushTimeout)
      @$pushTimeout = setTimeout(@$pushChanges, @pushDelay)