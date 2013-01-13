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
# summary: A Tab for use with the Tabs class
#
####################################################################################################

define ->
  class Tab extends Backbone.Model
    defaults:
      active: false
      title: 'unnamed'
      content: $('<div></div>')
    activate: =>
      @set active: true
    deactivate: =>
      @set active: false
    close: (silent) =>
      @deactivate()
      @get('content')?.remove?()
      @trigger 'close' unless silent