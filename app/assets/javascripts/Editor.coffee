define ['ace/ace','RemoteTokenizer'], (ace, RemoteTokenizer) ->
  # options: user, project, path to set the routes
  class Editor extends Backbone.View      
    # tag for new editors is <div>
    tagName: 'div'

    # css class name
    className: 'editor'

    # initialization needs to be done once to set up the socket and
    # initialize ace aswell as our custom RemoteTokenizer
    initialize: ->
      # The route for the RemoteTokenizer (WebSocket)
      @route = routes.controllers.Projects.getFileSocket(
        @options.user,
        @options.project,
        @options.path)
      # Create the editor
      @ace = ace.edit @el
      # Set to readonly while content is loading
      @ace.setReadOnly true
      # Set an initial theme
      @ace.setTheme 'ace/theme/textmate'
      # The route for file content
      file = routes.controllers.Projects.getFileContent(
        @options.user,
        @options.project,
        @options.path)
      # Retrieve file content asynchonously
      file.ajax
        success: (e) =>
          # Attach our RemoteTokenizer
          session = @ace.getSession()
          session.bgTokenizer = new RemoteTokenizer session, @route
          # Set the file content
          ## @ace.setValue e
          # Reset the undo manager so that the user cant undo the file load
          session.getUndoManager().reset()
          # Clear selesction and move cursor to top (needs to be done for some reason)
          @ace.selection.clearSelection()        
          @ace.gotoLine 0
          # Remove readonly
          @ace.setReadOnly false
          # Finally move focus to the editor
          @ace.focus()

    # nothing needs to be done for now...
    render: -> @