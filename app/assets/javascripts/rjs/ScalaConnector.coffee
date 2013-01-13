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
# summary: WebSocket Communication Abstraction (See JSConnector on the Server)
#
####################################################################################################

define ->
  class ScalaConnector
    bytesUp: 0
    bytesDown: 0

    constructor: (@url,@object,init) ->
      recieve = (e) =>
        @blink() 
        if e.action
          f = @object[e.action]
          if f
            result = f.apply(f,e.args) or null            
            if e.id then @socket.send JSON.stringify
              resultFor: e.id
              success: true
              data: result
          else
            if e.id then @socket.send JSON.stringify
              resultFor: e.id
              success: false
              message: "action '#{e.action}' does not exist"
            else console.error "action '#{e.action}' does not exist"
        else
          callback = @results[e.resultFor]
          if callback
            callback(e.data)
            @results[e.resultFor] = null
      ready = false
      @isReady = () -> ready
      @socket = new WebSocket(@url)      
      @socket.onmessage = (e) =>
        @bytesDown += e.data.length
        recieve(JSON.parse(e.data))
      if init? then @socket.onopen = (e) -> init()
      window.getTraffic = => "up: #{@bytesUp / 1000} KB, down: #{@bytesDown / 1000} KB"

    id: 0

    results: []
    
    timeOut: null
    
    blink: () =>
      clearTimeout(@timeOut)
      $('#sessionStatus').addClass('working')
      @timeOut = setTimeout((-> $('#sessionStatus').removeClass('working')), 500)

    call: (options) =>
      @blink()      
      if options and options.action        
        if options.callback
          @results[@id] = options.callback
          options.id = @id
          @id += 1
        msg = JSON.stringify(options)
        @bytesUp += msg.length
        @socket.send JSON.stringify(options)
      else
        console.error 'no action defined'