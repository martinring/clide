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

    deltas: []
    rows: []

    pushDelay: 250

    setDocument: (document) =>
      @fallback.setDocument(document)

    setTokenizer: (tokenizer) =>
      @fallback.setTokenizer(tokenizer)

    fireUpdateEvent: (firstRow, lastRow) =>
      @session._emit "tokenizerUpdate",
        data:
          first: firstRow
          last: lastRow

    start: =>
      @fallback.start()      

    getTokens: (row) =>
      @rows[row] or @fallback.getTokens(row)

    getState: (row) =>
      @fallback.getState(row)

    $pushTimeout: null

    $updateRemote: (e) => switch e.type
      when 'row'
        @rows[e.index] = e.row        
        @fireUpdateEvent(e.index,e.index)        

    $pushChanges: =>
      @socket.send(JSON.stringify @deltas)
      @deltas = []

    $updateOnChange: (delta) =>
      @fallback.$updateOnChange(delta)
      @deltas.push(delta)
      clearTimeout(@$pushTimeout)
      @$pushTimeout = setTimeout(@$pushChanges, @pushDelay)