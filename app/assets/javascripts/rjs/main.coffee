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
      tabs.add tab
      file.open()

  isabelle.on 'change:phase', (model,phase) ->
    $('#sessionStatus').removeClass(model.previous 'phase')
                       .addClass(model.get 'phase')

  isabelle.on 'ready', ->
    unless globalOptions.path is ""
      router.navigate globalOptions.path,
        replace: true

  isabelle.on 'change:logic', (model,logic) ->
    $('#sessionLogic').text('logic: ' + logic)

  isabelle.on 'println', (msg) ->
    console.log("server says: '#{msg}'")
    $('#syslog').html(msg)

  $('#consoleButton').on 'click', ->
    $('#consoleButton').toggleClass 'active'
    $('body').toggleClass 'extendedStatusbar'

  isabelle.on 'change:output', (m,out) ->
    $('#output').html(out)
  
  Backbone.history.start
    root: "/#{user}/#{project}/"
    pushState: true

  #router.navigate "/martinring/test/",
  #  replace: true

  router.on 'node', (node) ->
    console.log node
    thy = isabelle.theories.get(node)
    commands.open.execute(thy) if thy?

  isabelle.start user, project