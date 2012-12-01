define ['ace/ace','IsabelleConnection','ace/search', 'ace/range', 'isabelle', 'commands'], (ace, IsabelleConnection, Search, Range, isabelle, commands) ->
  Search = Search.Search
  Range = Range.Range
  # options: user, project, path to set the routes
  class Editor extends Backbone.View
    # tag for new editors is <div>
    tagName: 'div'

    initialize: ->      
      @editorEl = $('<div class="editor"></div>')
      @$el.append(@editorEl)
      @model.on 'opened', @initModel
      @model.on 'close', @close

    initModel: (text) =>
      @ace = ace.edit @editorEl[0]
      @ace.setValue(text)      

      # setup search
      commands.search.bind (text) => if @model.get 'active'
        @ace.findAll(text)

      oldPos = null
      pushPosTimeout = null

      editSession = @ace.getSession()

      @ace.on 'changeSelection', (args...) =>
        cursor = @ace.getCursorPosition()
        token = editSession.getTokenAt(cursor.row, cursor.column)        
        @model.set
          cursor: cursor
          currentToken: token
        isabelle.set
          currentToken: token
        #f = =>
        #  r = @ace.renderer
        #  pos = r.$cursorLayer.$pixelPos
        #  offset = @editorEl.offset()          
        #  pos.top += offset.top + r.lineHeight + 4 if offset?
        #  pos.left += offset.left + (if r.showGutter then r.$gutter.offsetWidth else 0) if offset?
        #  $('#completion').css pos
        #  console.log editSession.getTokenAt(cursor.row,cursor.column)
        #setTimeout(f,50)
        #unless cursor.row is oldPos?.row and cursor.column is oldPos?.column
        #  clearTimeout(pushPosTimeout)
        #  pushPosTimeout = setTimeout((=>
        #    oldPos = cursor
        #    @model.set 'cursor', cursor
        #    ),200)
      
      #@model.on 'change:output', (model, out) =>
      #  pos = editSession.documentToScreenPosition(out.line, 100)
      #  #@outputEl.css 
      #  #  top: pos.row
      #  #  left: pos.column
      #  @outputEl.html(out.message)
      range =
        start: 0
        end: 0
      editSession.on 'changeScrollTop', (args...) =>                  
        @model.set 
          perspective:
            start: @ace.getFirstVisibleRow()
            end: @ace.getLastVisibleRow()                
      # Reset the undo manager so that the user cant undo the file load
      editSession.getUndoManager().reset()
      #session.setMode('ace/mode/isabelle')
      connect = new IsabelleConnection editSession, @model      
      # Clear selesction and move cursor to top (needs to be done for some reason)
      @ace.selection.clearSelection()
      @ace.gotoLine 0
      # Finally move focus to the editor
      @ace.focus()      
      @model.off 'opened', @initModel

    remove: =>      
      @ace.destroy()
      super.remove()
    render: => @