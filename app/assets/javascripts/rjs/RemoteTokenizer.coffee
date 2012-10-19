define ["ace/lib/event_emitter","ace/range"], (EventEmitter,Range) ->
  Range = Range.Range
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
    history: []
    lines: []
    annotations: []

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

    $updateRemote: (e) => switch e.action
      when 'markup'
        console.log(e)
      when 'LineUpdate'
        diff = @current_version - e.version        
        console.error('version > current') if diff < 0        
        if diff is 0
          @lines[e.line] = e.tokens
          @fireUpdateEvent(e.line,e.line)
        else if diff <= @history.length
          console.warn('todo: integrate older versions')
          # lines = @history[diff-1].lines
          # lines[e.line] = e.tokens
          # for i in [diff ... 0]
          #   for delta in @history[i].deltas
          #     @applyDelta(delta)
          # @history = @history.slice(0, diff)
      when 'Marker'
        if e.version is @current_version
          console.log(e)
          console.log(@session.addMarker(
            new Range(e.range.start.row,e.range.start.column,e.range.end.row,e.range.end.column),
            e.clazz,
            "line",
            false)
          )
        else 
          console.log("ignoring marker for version #{e.version} (actual: #{@current_version})")
      when 'Annotation'
        if e.version is @current_version          
          @annotations.push(e)
          @session.setAnnotations(@annotations)
        else
          console.log("ignoring annotation for version #{e.version} (actual: #{@current_version})")
    $pushChanges: =>
      console.log("version #{ @current_version }")
      @socket.send JSON.stringify @deltas
      @history.unshift
        lines: @lines
        deltas: @deltas
      @deltas = []      

    $applyDelta: (delta) =>
      range = delta.range
      startRow = range.start.row
      startColumn = range.start.column
      endColumn = range.end.column
      len = range.end.row - startRow

      if len is 0
        if delta.action is "insertText"
          if startColumn is 0
            (@lines[startRow] or []).unshift
              type: 'text'
              value: delta.text              
          else 
            pos = 0            
            for token in @lines[startRow]
              nextPos = pos + token.value.length
              if pos < startColumn and startColumn <= nextPos
                token.value = token.value.substr(0,startColumn - pos) + delta.text + token.value.substr(startColumn - pos) 
              pos = nextPos              
        else if delta.action is "removeText"
          pos = 0          
          for token in @lines[startRow]
            start = startColumn - pos
            end = endColumn - pos
            nextPos = pos + token.value.length
            if start >= 0 or end < token.length
              token.value = token.value.substr(0,start) + token.value. substr(end, token.value.length - end)
            pos = nextPos            
        else console.error("insert/removeLines with len 0")
      else if delta.action is "removeText"         
        @lines.splice(startRow, len + 1, false);
      else if delta.action is "removeLines"
        @lines.splice(startRow, len + 1, false);
      else
        args = Array(len + 1)
        args.unshift(startRow, 1)
        @lines.splice.apply(this.lines, args)

    $updateOnChange: (delta) =>
      @$applyDelta(delta)
      @session.addMarker(
        new Range(1, 1, 1, 5),
        'ace_error',
        'text',
        false)
      @fallback.$updateOnChange(delta)
      if @deltas.length is 0
        @current_version += 1
        @annotations = []
        @session.setAnnotations []
      @deltas.push(delta)
      clearTimeout(@$pushTimeout)
      @$pushTimeout = setTimeout(@$pushChanges, @pushDelay)