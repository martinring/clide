define ['isabelle', 'commands', 'symbols', 'settings'], (isabelle, commands, symbols, settings) ->    
  # options: user, project, path to set the routes
  class Editor extends Backbone.View
    # tag for new editors is <div>
    tagName: 'div'

    initialize: ->
      @model.on 'opened', @initModel
      @model.on 'close', @close         

    changes: []

    pushTimeout: null

    pushChanges: =>
      isabelle.scala.call
        action: 'edit'
        data: 
          path:    @model.get 'path'
          version: @model.get 'currentVersion'
          changes: @changes.splice(0)          

    substitutions: []

    initModel: (text) =>
      currentLine = 0          

      @cm = new CodeMirror @el, 
        value: text
        indentUnit: 2
        lineNumbers: settings.get('showLineNumbers')
        gutters: ['CodeMirror-linenumbers','states']
        extraKeys: 
          'Ctrl-Space': 'autocomplete'
          'Ctrl-Down' : 'sub'
          'Ctrl-Up'   : 'sup'
          'Ctrl-B'    : 'bold'
        mode: "isabelle"

      settings.on 'change:showLineNumbers', (m,v) =>
        @cm.setOption('lineNumbers',v)

      lastAbbrev = null
        
      @cm.on 'change', (editor,change) => editor.operation =>
        unless editor.somethingSelected()          
          pos   = change.to
          cur   = editor.getCursor()
          token = editor.getTokenAt(pos)          
          marks = editor.findMarksAt(pos)
          for mark in marks 
            if mark.__special
              mark.clear()          
          from = 
            line: pos.line
            ch:   token.start
          to = 
            line: pos.line
            ch:   token.end
          if token.type? and (token.type.match(/special|symbol|control|sub|sup|bold/))              
            wid = symbols[token.string]
            if wid?
              @cm.markText from,to,          
                replacedWith: wid(token.type)
                clearOnEnter: false
                __special:    true
          else if token.type? and (token.type.match(/abbrev/))
            wid = symbols[token.string]
            if wid?
              @cm.markText from,to,          
                replacedWith: wid(token.type)
                clearOnEnter: false
                __special:    true          
        clearTimeout(@pushTimeout)
        if @changes.length is 0
          v = @model.get('currentVersion')
          @model.set 
            currentVersion: v + 1          
        while change?
          @changes.push
            from: change.from
            to:   change.to
            text: change.text
          change = change.next          
        @pushTimeout = setTimeout(@pushChanges,700)

      @cm.on 'cursorActivity', (editor) =>
        editor.removeLineClass(currentLine, 'background', 'current_line')
        cur = editor.getCursor()
        tok = editor.getTokenAt(cur)
        if tok? and tok.type?
          if tok.type.indexOf('control-sup') isnt -1
            @cm.setOption('cursorHeight', 0.66)
          else if tok.type.indexOf('control-sub') isnt -1
            @cm.setOption('cursorHeight', -0.66)      
          else
            @cm.setOption('cursorHeight', 1)      
        @model.set cursor: cur
        currentLine = editor.addLineClass(cur.line, 'background', 'current_line')

      @cm.on 'viewportChange', @updatePerspective

      cursor = @cm.getSearchCursor(/\\<(\^?[A-Za-z]+)>/)

      while cursor.findNext()
        sym = symbols[cursor.pos.match[0]]
        if sym?
          from = cursor.from()
          to   = cursor.to()
          @cm.markText(from, to, {
            replacedWith: sym(),
            clearOnEnter: false
          })
          
      currentLine = @cm.addLineClass(0, 'background', 'current_line')

      @model.get('commands').forEach @includeCommand
      @model.get('commands').on('add', @includeCommand)
      @model.get('commands').on('change', @includeCommand)
      @model.on 'change:states', (m,states) => @cm.operation () =>         
        @cm.clearGutter('states')        
        for state, i in states          
          marker = document.createElement('div')          
          marker.className = 'gutter-state-' + state
          @cm.setGutterMarker(i, 'states' ,marker)
      @model.on 'change:remoteVersion', (m,v) =>
        #console.log v
      @model.on 'check', (content) =>
        if @cm.getValue() isnt content          
          console.error "cross check failed: ", @cm.getValue(), content              
      CodeMirror.commands.autocomplete = (cm) ->
        syms = _.keys(symbols)
        CodeMirror.simpleHint cm, (editor) -> unless editor.somethingSelected()
          pos   = editor.getCursor()
          token = editor.getTokenAt(pos)          
          (
            list: _.filter(syms, (v) -> v.indexOf(token.string) isnt -1)
            from: 
              line: pos.line
              ch:   token.start
            to: 
              line: pos.line
              ch:   token.end
          )
      CodeMirror.commands.bold = (cm) ->
        cm.replaceRange('\\<^bold>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.isub = (cm) ->
        cm.replaceRange('\\<^isub>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.isup = (cm) ->
        cm.replaceRange('\\<^isup>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.sub = (cm) ->
        if cm.somethingSelected()
          s = cm.getSelection()
          cm.replaceSelection("\\<^bsub>#{s}\\<^esub>")
        else
          cm.replaceRange('\\<^sub>' ,cm.getCursor())
      CodeMirror.commands.sup = (cm) ->
        if cm.somethingSelected()
          s = cm.getSelection()
          cm.replaceSelection("\\<^bsup>#{s}\\<^esup>")
        else
          cm.replaceRange('\\<^sup>' ,cm.getCursor())
      CodeMirror.commands.isub = (cm) ->
        cm.replaceRange('\\<^isub>' ,cm.getCursor())
      CodeMirror.commands.isup = (cm) ->
        cm.replaceRange('\\<^isup>' ,cm.getCursor())
      

    updatePerspective: (editor, start, end) =>      
      @model.set
        perspective:
          start: start
          end:   end

    markers: []    

    addCommandWidget: (cmd) =>
      out = cmd.get('output')
      old = cmd.get('widget')
      rng = cmd.get('range')
      state = cmd.get('state')

      if old? 
        @cm.removeLineWidget(old)
      
      lineWidget = document.createElement('div')
      lineWidget.className = 'outputWidget ' + cmd.get('state')
      if cmd.get('current') then lineWidget.className += ' current'
      lineWidget.appendChild(document.createTextNode(out))
      wid = @cm.addLineWidget(rng.end,lineWidget)
      cmd.set((widget: wid), (silent: true))        


    includeCommand: (cmd) => if cmd.get('version') is @model.get('currentVersion') then @cm.operation =>
      unless cmd.get('registered')      
        cmd.on 'remove', (cmd) => if cmd?
          for m in cmd.get 'markup'
            m.clear()
          wid = cmd.get('widget')
          if wid?
            @cm.removeLineWidget(wid)
        cmd.set registered: true

      # add line widget
      @addCommandWidget(cmd)

      # mark Stuff
      old = cmd.get('markup')
      if old?
        for m in old
          m.clear()
      range  = cmd.get 'range'
      length = range.end - range.start
      marks = []
      for line, i in cmd.get 'tokens'
        l = i + range.start
        p = 0
        for tk in line
          from = 
            line: l
            ch: p
          p += tk.value.length
          unless (tk.type is "text" or tk.type is "")
            to =
              line: l
              ch: p              
            marks.push(@cm.markText from,to,
              className: "cm-#{tk.type.replace(/\./g,' cm-')}"
              tooltip: tk.tooltip
              __isabelle: true)
      cmd.set((markup: marks),(silent: true))

    remove: =>
      @model.get('commands').off()
      super.remove()

    render: => @