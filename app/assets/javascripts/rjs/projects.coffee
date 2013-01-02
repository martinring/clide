require [contextMenu], (contextMenu) ->
  create = ->
    name = prompt('Please enter a name for the new project')
    unless name?
      return
    if name.match(/^[A-Za-z][A-Za-z0-9_]*$/)
      alert("create #{name}")
    else
      create()
  $('#newProject').on 'click', create
  $('.project').on 'right'