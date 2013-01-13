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
# summary: Defines a custom prompt interface
#
####################################################################################################

define ->
  class Prompt extends Backbone.View
    tagName:    'div'
    className:  'prompt'
    initialize: =>      
      @$el.append($("<h1>#{message}</h1>"))
      if options.description?
        @$el.append($("<span class='description'>#{description}</span>"))                
      @$el.append($("<input type='text' id='prompt' value='#{defaultText}'></input>"))
  prompts = []  
  return (message, defaultText = '', description) ->
    p = new Prompt
      message:     message
      defaultText: defaultText
      description: description
    $(body).append(p.$el)
    p.get