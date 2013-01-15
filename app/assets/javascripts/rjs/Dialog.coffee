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
  class Dialog extends Backbone.View
    tagName:    'div'
    className:  'dialogContainer'
    attributes: 
      tabindex: 0
    exit: (action) => () =>
      text = @$('input').val()
      @$el.remove()
      if @options.done then @options.done
        action: action
        text: text
    initialize: ->
      @$el.append("<div class='dialog'><div class='content'></div></div>")          
      content = @$('.content')
      if @options.title?
        content.append(@make 'h1', {}, @options.title)
      if @options.message?
        content.append($("<span class='message'>#{@options.message}</span>"))
      if @options.defaultText?
        content.append($("<input type='text' id='prompt' value='#{@options.defaultText}'></input>"))
      buttons = $('<div class="buttons"></div>')
      for button in @options.buttons    
        but = @make 'button', { class: if button is @options.defaultAction then 'default' else 'button' }, button
        buttons.append(but)
        $(but).on 'click', @exit(button)
      content.append(buttons)
      $('body').append(@el)
      @$('.dialog').css('margin-top', -@$('.dialog').height() / 2)
      @$el.keypress (e) =>              
        if e.which is 13
          console.log(e)
          @exit(@options.defaultAction)()
          e.preventDefault()
      @$el.focus()
      @$('input').focus()