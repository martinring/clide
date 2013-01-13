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
# summary: Parser for the outer syntax of isabelle
#
####################################################################################################

define ['isabelleGrammar'], (grammar) ->
  CodeMirror.defineMode 'isabelle', (config,parserConfig) ->    
    special = 
      startState: () ->
        control: null
        sub:     false
        sup:     false
      token: (stream,state) ->
        if stream.sol()
          state.control = null
        x = ''
        if      state.sub then x = 'sub control-sub '
        else if state.sup then x = 'sup control-sup '
        if state.control is 'sub'        
          stream.match(grammar.incomplete) or stream.next()
          state.control = null
          return x + 'sub'
        if state.control is 'sup'
          stream.match(grammar.incomplete) or stream.next()
          state.control = null
          return x + 'sup'
        if state.control is 'bold'
          console.log 'insub'
          stream.match(grammar.incomplete) or stream.next()
          state.control = null
          return x + 'bold'
        if stream.eatWhile(/[^\\]/)
          if x isnt ''
            return x
          return null
        if stream.match(/\\<\^[A-Za-z]+>/)
          switch stream.current()
            when '\\<^sub>'            
              state.control = 'sub'            
            when '\\<^sup>'
              state.control = 'sup'
            when '\\<^isub>'
              state.control = 'sub'
            when '\\<^isup>'
              state.control = 'sup'
            when '\\<^bold>'
              state.control = 'bold'
            when '\\<^bsub>'
              state.sub = true
              return "#{x}control control-sub"
            when '\\<^bsup>'
              state.sup = true
              return "#{x}control control-sup"
            when '\\<^esub>'
              state.sub = false
              return "control"
            when '\\<^esup>'
              state.sup = false
              return "control"
          if state.control?
            return "#{x}control control-#{state.control}"
          else
            return x + 'control'
        if stream.match(/\\<[A-Za-z]+>/)
          return x + 'special'      
        stream.next()
        if x isnt ''
          return x
        return null

    tokenBase = (stream, state) ->    
      if stream.match(grammar.lineComment)
        return "comment"
        
      ch = stream.peek()    

      # verbatim
      if ch is '{'
        stream.next()
        if stream.eat('*')        
          state.verbatimLevel++
          state.tokenize = tokenVerbatim
          return state.tokenize(stream, state)
        else stream.backUp(1)
      
      state.command = null

      # string
      if ch is '"'
        stream.next()
        state.tokenize = tokenString
        return "string"

      # alt string
      if ch is '`'
        stream.next()
        state.tokenize = tokenAltString
        return "altstring"

      # comment
      if ch is '('
        stream.next()
        if stream.eat('*')
          state.commentLevel++
          state.tokenize = tokenComment
          return state.tokenize(stream, state)   
        else stream.backUp(1)   

      if stream.match(grammar.abbrev)
        return 'symbol'
      if stream.match(grammar.typefree)
        return 'tfree'
      else if stream.match(grammar.typevar)
        return "tvar"    
      else if stream.match(grammar.variable)
        return "var"    
      else if stream.match(grammar.longident) or stream.match(grammar.ident)
        type = parserConfig.words[stream.current()] || "identifier"
        if type is 'command'        
          type = type + " " + stream.current()
          state.command = stream.current()
        return type
      else if stream.match(grammar.symident)      
        return "symbol"
      else if stream.match(grammar.control)
        return null
      else if stream.match(grammar.incomplete)
        return 'incomplete'

      stream.next()
      return null

    tokenString = (stream, state) ->
      if stream.eatSpace()
        return 'string'
      if stream.match('\"')
        state.tokenize = tokenBase
        return 'string'
      if stream.match(grammar.longident)
        return 'string longident'
      if stream.match(grammar.ident)
        return 'string ident' 
      if stream.match(grammar.typefree)
        return 'string tfree'
      if stream.match(grammar.typevar)
        return 'string tvar'
      if stream.match(grammar.symident)
        return 'string symbol'
      if stream.match(grammar.num)
        return 'string num'
      if stream.match(grammar.escaped)
        return 'string'
      if stream.match(grammar.control)
        return null
      else if stream.match(grammar.incomplete)
        return 'incomplete'
      stream.next()
      return 'string'

    tokenAltString = (stream, state) ->
      next = false
      end = false
      escaped = false
      while ((next = stream.next())?)
        if next is '`' and not escaped
          end = true
          break 
        escaped = not escaped and next is '\\'    
      if end and not escaped
        state.tokenize = tokenBase    
      return 'alt_string'  

    tokenComment = (stream, state) ->
      prev = null
      next = null
      while state.commentLevel > 0 and (next = stream.next())?
        if prev is '(' and next is '*' then state.commentLevel++
        if prev is '*' and next is ')' then state.commentLevel--
        prev = next    
      if state.commentLevel <= 0
        state.tokenize = tokenBase    
      return 'comment'

    tokenVerbatim = (stream, state) ->
      prev = null
      next = null
      while (next = stream.next())?      
        if prev is '*' and next is '}'
          state.tokenize = tokenBase
          return 'verbatim' + (if state.command? then ' ' + state.command else '')
        prev = next
      return 'verbatim' + (if state.command? then ' ' + state.command else '')

    CodeMirror.overlayMode((
      startState: () ->
        string:        null
        tokenize:      tokenBase
        command:       null
        commentLevel:  0

      token: (stream,state) ->
        if stream.sol() and stream.match(/(?:[ \t]*\|[ \t]*)|(?:[ \t]+)/)
          return "indent"
        if stream.eatSpace()
          return 'whitespace'
        else
          return state.tokenize(stream, state)
    ),special,true)

  CodeMirror.defineMIME("text/x-isabelle","isabelle")