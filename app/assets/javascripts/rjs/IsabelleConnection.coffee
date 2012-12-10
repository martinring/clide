define ["ScalaConnector",'isabelle'], (ScalaConnector,isabelle) ->
  Range = Range.Range
  # the remote tokenizer synchronizes with a websocket to
  # let a server do the tokenization
  class IsabelleConnection
  	constructor: (@session, @model) ->      
      # connect to scala layer      
      @fallback = @session.bgTokenizer
      @session.bgTokenizer = this
      @lines[i] = false for i in [0 .. @session.getLength()]
      @model.on 'change:states', (m,states) => 
        for state, i in states
          prev = m.previous('states')?[i]
          if prev? then @session.removeGutterDecoration(i,prev)
          @session.addGutterDecoration(i,state)
      @model.get('commands').forEach (cmd) => (includeCommand(cmd) if cmd.get 'version' is @current_version)
      @model.get('commands').on 'add', (cmd) =>
        if (cmd.get 'version') is @current_version
          @includeCommand(cmd)
      @model.get('commands').on 'change', (cmd) =>        
        if (cmd.get 'version') is @current_version
          @includeCommand(cmd)

    includeCommand: (cmd) =>
      range = cmd.get 'range'
      length = range.end - range.start
      @lines.splice(range.start, length + 1, (cmd.get 'tokens')...)
      @fireUpdateEvent(range.start,range.end)

    current_version: 0
    deltas: []
    lines: []
    annotations: []

    pushDelay: 500

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
      isabelle.scala.call
        action: 'edit'
        data: 
          path: @model.get 'path'
          version: @current_version
          deltas: @deltas.splice(0)      

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
      @fallback.$updateOnChange(delta)
      if @deltas.length is 0
        @model.get('commands').cleanUp(@current_version)
        @current_version += 1
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