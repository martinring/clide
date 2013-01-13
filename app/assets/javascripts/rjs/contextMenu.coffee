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
# summary: Context Menu module
#          Depends on contextMenu.less
#
####################################################################################################

define ->  
  body = $('body')
  body.append('<ul id="contextMenu"></ul>')
  menu = $('#contextMenu')

  hide = () -> 
    menu.removeClass('show')
    body.off 'click'

  (
    show: (x,y,options) ->
      menu.html('')
      for opt in options
        li = $("<li>#{opt.text}</li>")
        li.on 'click', opt.command
        menu.append li        
      wh = $(window).height()
      ww = $(window).width()
      ch = menu.height() + 6
      cw = menu.height() + 6
      menu.css
        left: if (x + cw > ww) then ww - cw else x
        top: if (y + ch > wh) then wh - ch else y
      menu.addClass('show')
      body.on 'click', hide
    hide: hide    
  )