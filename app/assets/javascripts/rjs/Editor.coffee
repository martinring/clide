define ['ace/ace','IsabelleConnection','ace/search', 'ace/range', 'isabelle'], (ace, IsabelleConnection, Search, Range, isabelle) ->
  Search = Search.Search
  Range = Range.Range
  # options: user, project, path to set the routes
  class Editor extends Backbone.View          
    # tag for new editors is <div>
    tagName: 'div'
    # css class name
    className: 'editor'    
    # initialization needs to be done once to set up the socket and
    # initialize ace aswell as our custom RemoteTokenizer
    initialize: ->
      console.log 'init', @model
      @model.on 'opened', (text) =>      
        console.log 'opened'
        @ace = ace.edit @el
        @ace.setValue(text)
        oldPos = null
        @ace.on 'changeSelection', (args...) =>         
          cursor = @ace.getCursorPosition()
          unless cursor.row is oldPos?.row and cursor.column is oldPos?.column
            oldPos = cursor
            @model.set 'cursor', cursor           
        editSession = @ace.getSession()
        oldRange =
          start: 0
          end: 0
        editSession.on 'changeScrollTop', (args...) =>
          start = @ace.getFirstVisibleRow()
          end = @ace.getLastVisibleRow()
          unless oldRange.start is start and oldRange.end is end
            oldRange.start = start
            oldRange.end = end
            @model.set 'perspective', oldRange
        # Reset the undo manager so that the user cant undo the file load
        editSession.getUndoManager().reset()
        #session.setMode('ace/mode/isabelle')
        new IsabelleConnection editSession, @model
        # Clear selesction and move cursor to top (needs to be done for some reason)
        @ace.selection.clearSelection()
        @ace.gotoLine 0
        # Finally move focus to the editor
        @ace.focus()
    close: =>
      @model.close()

    # nothing needs to be done for now...
    render: => @