define ['isabelle', 'commands'], (isabelle, commands) ->    
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

    initModel: (text) =>
      hlLine = 0      
      @cm = new CodeMirror @el, 
        value: text
        indentUnit: 2
        lineNumbers: true
        mode: "isabelle"
        onChange: (editor,change) =>
          clearTimeout(@pushTimeOut)
          if @changes.length is 0 then @model.set 
            currentVersion: @model.get('currentVersion') + 1
          while change?
            @changes.push
              from: change.from
              to:   change.to
              text: change.text
            change = change.next
          @pushTimeout = setTimeout(@pushChanges,700)
        onCursorActivity: (editor) ->
          editor.setLineClass(hlLine, null, null)
          hlLine = editor.setLineClass(editor.getCursor().line, "current_line")
        onViewportChange: @updatePerspective
      hlLine = @cm.setLineClass(0, "current_line")
      @model.get('commands').forEach @includeCommand
      @model.get('commands').on('add', @includeCommand)
      @model.get('commands').on('change', @includeCommand)
      @model.on 'change:states', (m,states) =>
        for state, i in states
          cmd = @model.get('commands').getCommandAt(i)          
          @cm.setMarker(i, null ,state)
      CodeMirror.simpleHint @cm, (args... )->
        console.log args ...

    updatePerspective: (editor, start, end) =>      
      @model.set
        perspective:
          start: start
          end:   end    

    includeCommand: (cmd) => if cmd.get 'version' is @model.get('currentVersion')
      console.log "hallo"
      vp = @cm.getViewport()
      console.log vp
      range  = cmd.get 'range'
      if vp.from >= range.end || vp.to <= range.start
        return      
      length = range.end - range.start
      for line, i in cmd.get 'tokens'
        l = i + range.start
        @cm.clearMarker(l)
        if l >= vp.from && l <= vp.to
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
              @cm.markText(from,to,"cm-#{tk.type.replace(/\./g,' cm-')}")

    remove: =>
      @model.get('commands').off()
      super.remove()

    render: => @