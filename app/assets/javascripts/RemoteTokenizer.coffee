define ->
  # the remote tokenizer synchronizes with a websocket to
  # let a server do the tokenization  
  class RemoteTokenizer
  	constructor: (@session, @route) ->
      @doc = @session.getDocument()
      @socket = new WebSocket(@route.webSocketURL())
      @socket.onmessage = (e) => @$updateRemote(JSON.parse(e.data))

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

    $updateOnChange: (delta) ->
      offset = 0
      offset += @doc.getLine(row).length + 1 for row in [0 ... delta.range.start.row]
      offset += delta.range.start.column
      delta.offset = offset
      @socket.send(JSON.stringify delta)