define ->  
  class Command extends Backbone.Model
    constructor: (name) ->
      super name: name
    defaults:
      canExecute: true
    execute: (args...) =>
      if @get 'canExecute'
        @trigger 'execute', args...
      else
        console.error "command '#{@get 'name'}' can't be executed"
    bind: (f) =>
      @on 'execute', f

  commands = [
    'open',
    'close',
    'cut',
    'copy',
    'paste'
  ]

  exports = { }

  for name in commands
    exports[name] = new Command name

  return exports