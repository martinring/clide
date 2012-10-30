define ["ScalaConnector","ace/range"], (ScalaConnector,Range) ->
  Range = Range.Range
  # the remote tokenizer synchronizes with a websocket to
  # let a server do the tokenization
  class IsabelleConnection
  	constructor: (@session, @route) ->      
      # connect to scala layer      
      @fallback = @session.bgTokenizer
      @scala = new ScalaConnector @route.webSocketURL(), @, =>
        console.log 'init'
        @scala.call
          action: 'getContent'
          callback: (e) =>
            console.log e
            @version = e.version
            @session.setValue(e.content)
            @session.bgTokenizer = this
            @session.on 'changeScollTop', (e) =>
              console.log e            
            @doc = @session.getDocument()

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

    updateLine: (e) =>
      diff = @current_version - e.version
      console.error('version > current') if diff < 0        
      if diff is 0
        @lines[e.line] = e.tokens
        @fireUpdateEvent(e.line,e.line)
      else if diff <= @history.length
        console.warn('todo: integrate older versions')

    $pushChanges: =>
      console.log("version #{ @current_version }")
      @scala.call
        action: 'edit'
        data: @deltas
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
            if @lines[startRow] then for token in @lines[startRow]
              nextPos = pos + token.value.length
              if pos < startColumn and startColumn <= nextPos
                token.value = token.value.substr(0,startColumn - pos) + delta.text + token.value.substr(startColumn - pos)
              pos = nextPos
        else if delta.action is "removeText"
          pos = 0
          if @lines[startRow]? then for token in @lines[startRow]
            start = startColumn - pos
            end = endColumn - pos
            nextPos = pos + token.value.length
            if start >= 0 or end < token.length
              token.value = token.value.substr(0,start) + token.value. substr(end, token.value.length - end)
            pos = nextPos            
        else console.error("insert/removeLines with len 0")
      else if delta.action is "removeText"
        @lines.splice(startRow, len + 1, if @lines[startRow]? then @lines[startRow].concat(@lines[startRow+1]) else false);
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
        #for marker in @markers 
        #  @session.removeMarker(marker)
        #@markers = []
        @annotations = []
        @session.setAnnotations []
      @deltas.push(delta)
      clearTimeout(@$pushTimeout)
      @$pushTimeout = setTimeout(@$pushChanges, @pushDelay)

    annotate: (version, position, type, message) =>
      if version is @current_version
        @annotations.push
          type: type
          row: position.row
          column: position.column
          type: type
          text: message
        @session.setAnnotations(@annotations)
        return true
      else
        console.log("ignoring annotation for version #{version} (actual: #{@current_version})")
        return false

    markup: (version, markup) =>      
      if version is @current_version
        for entry in markup
          start = entry.range.start
          end = entry.range.end
          console.log(entry)