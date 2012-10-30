require ['Editor','Tabs','Tab','session','sidebar'], (Editor,Tabs,Tab,session,sidebar) ->
  tabs = new Tabs('#content')  

  openfiles = []

  sidebar.on 'open', (file) ->
    if openfiles[file]? 
      openfiles[file].activate()
    else 
      editor = new Editor
        user: 'martinring'
        project: 'test'
        path: file
      tab = new Tab
        title: file
        content: editor.$el
      openfiles[file] = tab
      tabs.add tab    

  session.on 'change:phase', (model,phase) ->
    if phase is 'Ready' then  

  session.scala.call
    action: 'getFiles'
    callback: (files) ->
      sidebar.set files: files  