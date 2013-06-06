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
# summary: Adapted CodeMirror Instance for Isabelle Source Editing
#
####################################################################################################

define ['isabelle', 'commands', 'symbols', 'settings', 'isabelleDefaultWords'], (isabelle, commands, symbols, settings, defaultWords) ->    
  # options: user, project, path to set the routes
  class Editor extends Backbone.View
    # tag for new editors is <div>
    tagName: 'div'

    initialize: ->
      @model.on 'opened', @initModel
      @model.on 'close', @close      

    changes: []

    pushTimeout: null

    pushChanges: =>
      isabelle.scala.call
        action: 'edit'
        data: 
          path:    @model.get 'path'
          version: @model.get 'currentVersion'
          changes: @changes.splice(0)          

    substitutions: []

    initModel: (text) =>      
      currentLine = 0  

      console.log 'init'
      @cm = new CodeMirror @el, 
        value: text
        indentUnit: 2
        lineNumbers: settings.get('showLineNumbers')
        gutters: ['CodeMirror-linenumbers','states']
        extraKeys: 
          'Ctrl-Space': 'autocomplete'
          'Ctrl-Down' : 'sub'
          'Ctrl-Up'   : 'sup'
          'Ctrl-Shift-Down' : 'isub'
          'Ctrl-Shift-Up' : 'isup'
          'Ctrl-B'    : 'bold'
          'Ctrl-S'    : 'save'
          'Ctrl-H'    : 'replace'
          'F3'        : 'findNext'
        mode: 
          name: 'isabelle'
          words: defaultWords
      console.log 'done'

      settings.on 'change:showLineNumbers', (m,v) =>
        @cm.setOption('lineNumbers',v)

      lastAbbrev = null

      if @options.focus.from.fl?
        @cm.setCursor(@options.focus.from)
        @cm.scrollIntoView(null)
        @cm.setExtending(true)
        if @options.focus.to.tl?
          @cm.setCursor(@options.focus.to)
        @cm.setExtending(false)

      @model.on 'focus', (fl,fc,tl,tc) => if fl?
        @cm.setCursor (line: fl, ch: fc)
        @cm.scrollIntoView(null)
        @cm.setExtending(true)
        if tl?
          @cm.setCursor (line: tl, ch: tc)
        @cm.setExtending(false)        
        
      @model.on 'saved', =>
        @cm.markClean()        
        @model.set(clean: true)

      @cm.on 'change', (editor,change) => editor.operation =>
        @model.set(clean: editor.isClean())
        unless editor.somethingSelected()          
          pos   = change.to
          cur   = editor.getCursor()
          token = editor.getTokenAt(pos)          
          marks = editor.findMarksAt(pos)
          for mark in marks 
            if mark.__special
              mark.clear()          
          from = 
            line: pos.line
            ch:   token.start
          to = 
            line: pos.line
            ch:   token.end
          if token.type? and (token.type.match(/special|symbol|control|sub|sup|bold/))              
            wid = symbols[token.string]
            if wid?
              @cm.markText from,to,          
                replacedWith: wid(token.type)
                clearOnEnter: false
                __special:    true
          else if token.type? and (token.type.match(/abbrev/))
            wid = symbols[token.string]
            if wid?
              @cm.markText from,to,          
                replacedWith: wid(token.type)
                clearOnEnter: false
                __special:    true          
        clearTimeout(@pushTimeout)
        if @changes.length is 0
          v = @model.get('currentVersion')
          @model.set 
            currentVersion: v + 1          
        while change?
          @changes.push
            from: change.from
            to:   change.to
            text: change.text
          change = change.next          
        @pushTimeout = setTimeout(@pushChanges,1500)

      @cm.on 'cursorActivity', (editor) =>
        editor.removeLineClass(currentLine, 'background', 'current_line')
        cur = editor.getCursor()
        tok = editor.getTokenAt(cur)
        if tok? and tok.type?
          if tok.type.indexOf('control-sup') isnt -1
            @cm.setOption('cursorHeight', 0.66)
          else if tok.type.indexOf('control-sub') isnt -1
            @cm.setOption('cursorHeight', -0.66)      
          else
            @cm.setOption('cursorHeight', 1)      
        @model.set cursor: cur
        currentLine = editor.addLineClass(cur.line, 'background', 'current_line')

      @cm.on 'viewportChange', @updatePerspective

      cursor = @cm.getSearchCursor(/\\<(\^?[A-Za-z]+)>/)

      while cursor.findNext()
        sym = symbols[cursor.pos.match[0]]
        if sym?
          from = cursor.from()
          to   = cursor.to()
          @cm.markText(from, to, {
            replacedWith: sym(),
            clearOnEnter: false
          })
          
      currentLine = @cm.addLineClass(0, 'background', 'current_line')

      commands.insertSym.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.autocomplete(@cm)
     
      commands.search.bind =>
        @cm.focus()
        CodeMirror.commands.find(@cm)

      commands.bold.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.bold(@cm)

      commands.sub.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.sub(@cm)

      commands.sup.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.sup(@cm)

      commands.isub.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.isub(@cm)

      commands.isup.bind => if @model.get('active')
        @cm.focus()
        CodeMirror.commands.isup(@cm)
        
      #@overlay = 
      #  startState: () -> 
      #    line: 0
      #  token: (stream, state) ->
      #    cmd = @model.get('commands').getCommandAt(line)
      #    if cmd?
      #      range = cmd.get('range')
      #      tokens = cmd.get('tokens')
      #      tokens[line + range.start]
      #    else
      #      stream.skipToEnd()
      #      state.line += 1;
      #      return null

      @model.get('commands').forEach @includeCommand
      @model.get('commands').on('add', @includeCommand)
      @model.get('commands').on('change', @includeCommand)

      @model.on 'change:active', (m,a) => if a then @pushChanges()

      @model.on 'change:states', (m,states) => @cm.operation () =>         
        @cm.clearGutter('states')        
        for state, i in states          
          marker = document.createElement('div')          
          marker.className = 'gutter-state-' + state
          @cm.setGutterMarker(i, 'states' ,marker)
      @model.on 'change:remoteVersion', (m,v) =>
        #console.log v
      @model.on 'check', (content) =>
        if @cm.getValue() isnt content          
          console.error "cross check failed: ", @cm.getValue(), content              
      CodeMirror.commands.autocomplete = (cm) ->
        syms = _.keys(symbols)
        CodeMirror.showHint cm, (editor) -> unless editor.somethingSelected()
          pos   = editor.getCursor()
          token = editor.getTokenAt(pos)           
          list = _.filter(syms, (v) -> v.indexOf(token.string) isnt -1)
          (
            list: if list.length > 0 then list else syms
            from: 
              line: pos.line
              ch:   if token.type is 'incomplete' then token.start - 1 else token.start
            to: 
              line: pos.line
              ch:   token.end
          )
      CodeMirror.commands.save = ->
        isabelle.save()
      CodeMirror.commands.bold = (cm) ->
        cm.replaceRange('\\<^bold>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.isub = (cm) ->
        cm.replaceRange('\\<^isub>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.isup = (cm) ->
        cm.replaceRange('\\<^isup>' ,cm.getCursor()) unless cm.somethingSelected()
      CodeMirror.commands.sub = (cm) ->
        if cm.somethingSelected()
          s = cm.getSelection()
          cm.replaceSelection("\\<^bsub>#{s}\\<^esub>")
        else
          cm.replaceRange('\\<^sub>' ,cm.getCursor())
      CodeMirror.commands.sup = (cm) ->
        if cm.somethingSelected()
          s = cm.getSelection()
          cm.replaceSelection("\\<^bsup>#{s}\\<^esup>")
        else
          cm.replaceRange('\\<^sup>' ,cm.getCursor())
      CodeMirror.commands.isub = (cm) ->
        cm.replaceRange('\\<^isub>' ,cm.getCursor())
      CodeMirror.commands.isup = (cm) ->
        cm.replaceRange('\\<^isup>' ,cm.getCursor())
      
    updatePerspective: (editor, start, end) =>      
      @model.set
        perspective:
          start: start
          end:   end

    markers: []    

    addCommandWidget: (cmd) =>
      out = cmd.get('output')
      old = cmd.get('widget')
      rng = cmd.get('range')
      state = cmd.get('state')

      if old? 
        @cm.removeLineWidget(old)
      
      lineWidget = document.createElement('div')
      lineWidget.className = 'outputWidget ' + cmd.get('state')
      if cmd.get('current') then lineWidget.className += ' current'
      lineWidget.appendChild(document.createTextNode(out))
      wid = @cm.addLineWidget(rng.end,lineWidget)
      cmd.set((widget: wid), (silent: true))        


    includeCommand: (cmd) => if cmd.get('version') is @model.get('currentVersion') then @cm.operation =>
      unless cmd.get('registered')      
        cmd.on 'remove', (cmd) => if cmd?
          for m in cmd.get 'markup'
            m.clear()
          wid = cmd.get('widget')
          if wid?
            @cm.removeLineWidget(wid)
        cmd.set registered: true

      # add line widget
      @addCommandWidget(cmd)

      # mark Stuff
      old = cmd.get('markup')
      if old?
        for m in old
          m.clear()
      range  = cmd.get 'range'
      length = range.end - range.start
      marks = []
      console.log (cmd.get 'tokens')
      for line, i in cmd.get 'tokens'
        l = i + range.start
        p = 0
        for tk in line
          from = 
            line: l
            ch: p
          p += tk.value.length
          unless (tk.type is "text" or tk.type is "")
            to =
              line: l
              ch: p              
            marks.push(@cm.markText from,to,
              className: "cm-#{tk.type.replace(/\./g,' cm-')}"
              tooltip: tk.tooltip
              __isabelle: true)
      cmd.set((markup: marks),(silent: true))

    remove: =>
      @model.get('commands').off()
      super.remove()

    render: => @