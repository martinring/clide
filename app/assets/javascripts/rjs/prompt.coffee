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