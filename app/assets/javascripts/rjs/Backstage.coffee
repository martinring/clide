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
# summary: Definition of the Backstage area view
#
####################################################################################################

define ->
  class Project extends Backbone.Model
    defaults:
      name: ''

  class ProjectList extends Backbone.Collection
    constructor: (@user) ->
    model: Project
    url:   routes.controllers.Projects.listProjects(@user).url

  class ProjectView extends Backbone.View
    tagName: 'li'
    initialize: ->
      _.bindAll @
      @model.bind 'change', @render
      @model.bind 'remove', @unrender
    render: ->
      $(@el).html("#{ @model.get 'name' }")
      return @
    unrender: ->
      $(@el).remove()

  class Backstage extends Backbone.View    
    el: $ '#backstage'
    events: ->
      'click #backstage': 'refresh'
    initialize: ->
      _.bindAll @
      @files = new ProjectList      
      @files.bind 'add', @add          
      @refresh()
    refresh: ->
      console.log('refreshing')
      @files.fetch success: => @render()      
    render: ->
      $(@el).empty()
      for file in @files.models
        view = new ProjectView model: file  
        $(@el).append(view.render().el)      
      return @
    add: (file) ->
      view = new ProjectView model: file
      $(@el).append view.render().el
    show: ->
      $(@el).removeClass 'hide'
    hide: ->
      $(@el).addClass 'hide'
    toggle: ->
      $(@el).toggleClass 'hide'
    isVisible: ->
      $(@el).hasClass 'hide'
      