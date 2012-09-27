define ->
  # the remote tokenizer synchronizes with a websocket to
  # let a server do the tokenization  
  class RemoteTokenizer
  	constructor: (@session, @route) ->
      @doc = @session.getDocument()
      @session.setAnnotations [
        type: 'error'
        text: 'what the hell?'
        row:  5  
      ,
        type: 'warning'
        text: 'really?'
        row:  7
      ]
      @socket = new WebSocket(@route.webSocketURL())
      @socket.onmessage = (e) => @$updateRemote(JSON.parse(e.data))

    deltas: []
    pushTimeout: null

    rows: []

    fireUpdateEvent: (firstRow, lastRow) ->      
      @session._emit "tokenizerUpdate",
        data:
          first: firstRow
          last: lastRow

    start: ->
      console.log('start tokenizer')

    getTokens: (row) ->
      @rows[row] or [
        type: 'text'
        value: @doc.getLine(row)
      ]

    getState: (row) -> 'default'

    $updateRemote: (e) => switch e.type
      when 'row'
        @rows[e.index] = e.row        
        @fireUpdateEvent(e.index,e.index)        

    $pushChanges: =>
      @socket.send(JSON.stringify @deltas)
      @deltas = []

    $updateOnChange: (delta) ->
      @deltas.push(delta)
      clearTimeout(@pushTimeout)
      @pushTimeout = setTimeout(@$pushChanges, 250)      