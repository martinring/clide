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
# summary: This is the main entry point for the ide application. This code gets executed opon load 
#          of the session page.
#
####################################################################################################

$('#loadingStatus').append("<li>initializing</li>")
require ['Editor','Tabs','Tab','isabelle','sidebar','settings','commands','Router','Dialog'], (Editor,Tabs,Tab,isabelle,sidebar,settings,commands,router,Dialog) ->
  user = globalOptions.user
  project = globalOptions.project

  tabs = new Tabs('#content')

  openfiles = []

  commands.open.bind (file,fl,fc,tl,tc) ->    
    path = file.get 'path'
    name = file.get 'id'    
    if openfiles[name]?      
      openfiles[name].activate()
      file.trigger 'focus', fl, fc, tl, tc
    else
      console.log "command"
      editor = new Editor 
        model: file
        focus:
          from:
            line: fl
            ch: fc
          to: 
            line: tl
            ch: tc
      tab = new Tab
        title: name
        content: editor.$el
      openfiles[name] = tab
      tab.on 'close', () ->
        openfiles[name] = null
        file.close()
      tab.on 'change:active', (m,a) ->
        file.set active: a
        if a then router.navigate name
      file.on 'close', ->
        openfiles[name] = null
        tab.close(true)
      tabs.add tab
      file.open()

  clipboardUnsupported = () ->
    new Dialog
      title: "Missing Browser Support"
      message: "<p>Unfortunately, up to now, no modern browser implements the new 'HTML5 Clipboard API'.</p>" +
          "<p>Up to then there is no Access to the clipboard from JS.</p>" + 
          "Meanwhile, please use the normal key combinations CTRL-X, CTRL-C and CTRL-V respectively for cut, copy and paste."
      buttons: ['Ok']
      defaultAction: 'Ok'

  commands.cut.bind clipboardUnsupported
  commands.copy.bind clipboardUnsupported
  commands.paste.bind clipboardUnsupported

  isabelle.on 'change:phase', (model,phase) -> 
    $('#loadingStatus').append("<li>Session #{phase}</li>".toLowerCase())
    if phase is 'Ready' then $('#loading').fadeOut()
    else $('#loading').fadeIn()
    $('#sessionStatus').removeClass(model.previous 'phase')
                       .addClass(model.get 'phase')

  isabelle.on 'ready', ->
    unless globalOptions.path is ""
      router.navigate globalOptions.path,
        replace: true

  isabelle.on 'change:logic', (model,logic) ->
    $('#sessionLogic').text('logic: ' + logic)

  isabelle.on 'println', (msg) ->
    $('#loadingStatus').append("<li>#{msg}</li>".toLowerCase())
    console.log("server says: '#{msg}'")
    $('#syslog').html(msg)

  $('#consoleButton').on 'click', ->
    old = settings.get('outputPanel')
    settings.set(outputPanel: (not old))

  settings.on 'change:outputPanel', (m,v) ->
    $('#consoleButton').toggleClass 'active', v
    $('body').toggleClass 'extendedStatusbar', v

  settings.on 'change:inlineStates', (m,v) ->    
    $('body').toggleClass 'inlineStates', v  

  settings.on 'change:inlineErrors', (m,v) ->    
    $('body').toggleClass 'inlineErrors', v  

  isabelle.on 'change:output', (m,out) ->
    $('#output').html(out)
  
  Backbone.history.start
    root: "/#{user}/#{project}/"
    pushState: true

  router.on 'route:node', (node, pos) ->
    [exp,fl,fc,tl,tc] = pos.match /^([0-9]+):([0-9]+)(?:-([0-9]+):([0-9]+))?$/ if pos?    
    thy = isabelle.theories.get(node)
    commands.open.execute(thy,fl,fc,tl,tc) if thy?        

  $('#loadingStatus').append("<li>connecting</li>")
  isabelle.start user, project