require ['contextMenu'], (menu) ->  
  create = (again) ->    
    name = prompt('Please enter a name for the new project')
    unless name?
      return
    if name.match(/^[A-Za-z][A-Za-z0-9_]*$/)
      routes.controllers.Projects.createProject(user,name).ajax
        success: ->
          history.go(0)
        error: ->
          create(true)
    else
      create(true)
  
  $('#newProject').on 'click', create

  $('.project').each (i,elem) -> $(elem).on 'contextmenu', (e) ->
    e.preventDefault()
    menu.show(e.pageX,e.pageY,[
        text: 'Delete'
        command: -> if confirm("Do you really want to delete project #{$(elem).data('name')}?")
          deleteProject(user,$(elem).data('name'))
      ])
  
  window.changeLogic = (user, project) ->
    nl = $("#logic-#{user}-#{project}").val()
    routes.controllers.Projects.setProjectConf(user,project).ajax
        data:
            logic : nl

  window.deleteProject = (user, project) ->    
    routes.controllers.Projects.removeProject(user,project).ajax
      success: -> $('#' + "#{user}-#{project}").remove()