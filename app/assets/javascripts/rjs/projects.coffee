####################################################################################################
#
# Copyright (c) 2012, 2013 All Right Reserved, Martin Ring
#
# This source is subject to the General Public License (GPL).
# Please see the License.txt file for more information.
# All other rights reserved.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# author:  Martin Ring
# email:   martinring@live.de
# summary: This is the main entry point for the projects page. This code gets executed opon load 
#          of the projects page.
#
####################################################################################################

require ['contextMenu','Dialog'], (menu,Dialog) ->  
  create = (again,name) ->    
    new Dialog
      title: 'New project'
      message:
        if again is true 
          (if name? then "<p>Name #{name} is allready taken</p>" else "<p>You entered an invalid name</p>") + 
          '<p>Please enter a unique alphanumerical name</p>'
        else 
          'Please enter a name for the new project'
      defaultText: ''
      buttons: ['Ok','Cancel']
      defaultAction: 'Ok'
      done: (e) => if e.action is 'Ok'
        name = e.text
        if name.match(/^[A-Za-z][A-Za-z0-9_]*$/)
          routes.controllers.Projects.createProject(user,name).ajax
            success: ->
              history.go(0)
            error: ->
              create(true,name)
        else
          create(true)
  
  $('#newProject').on 'click', create

  $('.project').each (i,elem) -> $(elem).on 'contextmenu', (e) ->
    e.preventDefault()
    menu.show(e.pageX,e.pageY,[
        text: 'Delete'
        command: ->
          new Dialog
            title: "Delete Project"
            message: "Do you really want to delete project '#{$(elem).data('name')}'?"
            buttons: ['Yes','No']
            defaultAction: 'Yes'
            done: (e) => if e.action is 'Yes' then deleteProject(user,$(elem).data('name'))                  
      ])
  
  window.changeLogic = (user, project) ->
    nl = $("#logic-#{user}-#{project}").val()
    routes.controllers.Projects.setProjectConf(user,project).ajax
        data:
            logic : nl

  window.deleteProject = (user, project) ->    
    routes.controllers.Projects.removeProject(user,project).ajax
      success: -> $('#' + "#{user}-#{project}").remove()