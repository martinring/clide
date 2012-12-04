define ['ace/ace','IsabelleConnection','ace/search', 'ace/range', 'isabelle', 'commands'], (ace, IsabelleConnection, Search, Range, isabelle, commands) ->
  Search = Search.Search
  Range = Range.Range
  # options: user, project, path to set the routes
  class Editor extends Backbone.View
    # tag for new editors is <div>
    tagName: 'div'

    initialize: ->
      @model.on 'opened', @initModel
      @model.on 'close', @close    

    current_version: 0

    changes: []

    pushTimeout: null

    pushChanges: =>
      isabelle.scala.call
        action: 'edit'
        data: 
          path:    @model.get 'path'
          version: @current_version
          changes: @changes.splice(0)          

    initModel: (text) =>
      options = 
        value: text
        indentUnit: 2
        lineNumbers: true
        onChange: (editor,change) =>
          clearTimeout(@pushTimeOut)
          @current_version += 1 if @changes.length == 0
          while change?
            @changes.push
              from: change.from
              to:   change.to
              text: change.text
            change = change.next
          @pushTimeout = setTimeout(@pushChanges,700)

      @cm = new CodeMirror(@el,options) 
      @model.get('commands').forEach @includeCommand
      @model.get('commands').on('add', @includeCommand)
      @model.get('commands').on('change', @includeCommand)
      @model.on 'change:states', (m,states) =>
        @cm.setMarker(i,null,state) for state, i in states


    includeCommand: (cmd) => #if cmd.get 'version' is @current_version
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
            to =
              line: l
              ch: p          
            @cm.markText(from,to,tk.type.replace(/\./g,' '))

    remove: =>
      @model.get('commands').off()
      super.remove()

    render: => @