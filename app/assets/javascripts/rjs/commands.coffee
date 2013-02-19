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
# summary: Command infrastructure
#
####################################################################################################

define ->  
  class Command extends Backbone.Model
    constructor: (name) ->
      super name: name
    defaults:
      canExecute: true
    execute: (args...) =>
      if @get 'canExecute'
        @trigger 'execute', args...
      else
        console.error "command '#{@get 'name'}' can't be executed"
    bind: (f) =>
      @on 'execute', f

  commands = [
    'open',
    'close',
    'cut',
    'copy',
    'paste',
    'search',
    'sub',
    'sup',
    'isub',
    'isup',
    'bold',
    'insertSym'
  ]

  exports = { }

  for name in commands
    exports[name] = new Command name

  return exports