define -> 
  body = $('body')
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