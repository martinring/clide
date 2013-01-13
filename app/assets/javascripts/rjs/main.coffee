###
## This is the main entry point for the ide application. This file gets executed opon load of the
## session page
###
$('#loadingStatus').append("<li>initializing</li>")
require ['Editor','Tabs','Tab','isabelle','sidebar','settings','commands','Router'], (Editor,Tabs,Tab,isabelle,sidebar,settings,commands,router) ->
  user = globalOptions.user
  project = globalOptions.project

  tabs = new Tabs('#content')

  openfiles = []

  commands.open.bind (file) ->    
    path = file.get 'path'
    name = file.get 'id'    
    if openfiles[name]?
      openfiles[name].activate()
    else
      console.log "command"
      editor = new Editor model: file
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

  router.on 'route:node', (node) ->
    thy = isabelle.theories.get(node)
    commands.open.execute(thy) if thy?

  $('#loadingStatus').append("<li>connecting</li>")
  isabelle.start user, project