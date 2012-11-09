require ['Editor','Tabs','Tab','isabelle','sidebar','settings','commands','ace/ace'], (Editor,Tabs,Tab,isabelle,sidebar,settings,commands,ace) ->
  user = 'martinring'
  project = 'test'

  tabs = new Tabs('#content')

  openfiles = []

  commands.open.bind (file) ->    
    path = file.get 'path'
    name = file.get 'id'
    if openfiles[file.cid]?
      openfiles[file.cid].activate()
    else
      editor = new Editor model: file
      tab = new Tab
        title: name
        content: editor.$el
      openfiles[file.cid] = tab      
      tab.on 'close', () ->
        openfiles[file.cid] = null
        file.set active: false
      tab.on 'change:active', (m,a) ->
        file.set active: a
      tabs.add tab   
      file.open()

  isabelle.on 'change:phase', (model,phase) ->
    $('#sessionStatus').addClass(model.get 'phase')

  isabelle.on 'change:logic', (model,logic) ->
    $('#sessionLogic').text('logic: ' + logic)

  isabelle.on 'println', (msg) ->
    $('#syslog').text(msg)

  isabelle.start user, project