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
# summary: Global settings
#
####################################################################################################

define ->
  class Settings extends Backbone.Model
    initialize: =>
      @on 'change:inlineStates', (m,v) =>
        @set(inlineErrors: true) if v
      @on 'change:inlineErrors', (m,v) =>
        @set(inlineStates: false) unless v

  return new Settings
    showLineNumbers: true
    inlineStates: false
    inlineErrors: true