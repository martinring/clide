define ->
  class Settings extends Backbone.Model
    initialize: =>
      @on 'change:inlineStates', (m,v) =>
        @set(inlineErrors: true) if v
      @on 'change:inlineErrors', (m,v) =>
        @set(inlineStates: false) unless v

  return new Settings
    showLineNumbers: true