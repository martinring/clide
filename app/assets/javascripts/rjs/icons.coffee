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
# summary: Special icon strings for use with icon font
#
####################################################################################################

define ->  
  search: '\uE000'
  check: '\uE001'
  file: '\uE160'
  trash: '\uE107'
  save: '\uE105'
  arrow:
    right: '\uE111'
    left: '\uE112'
    up: '\uE110'
  settings: '\uE115'
  undo: '\uE10E'  
  redo: '\uE10D'
  globe: '\uE128'
  zoom:
    in: '\uE12E'
    out: '\uE0BD'
  io: '\uE07D'
  checkbox:
    empty: '\u20e3'
    checked: '\u22a0'
    partial: '\u22a1'
    fromBool: (checked) -> if checked? then (if checked then '\ue0e7' else '') else '\u25a2'
  radio:
    empty: '\uE070'
    checket: '\uE0A3'
  heart:
    outline: '\uE006'
    broken: '\uE007'
    plain: '\uE00B'
  star: '\uE00B'
  view: '\uE18B'
  exit: '\uE0B2'
  edit: '\uE104'
  list: '\uE133'
  plus: '\uE109'
  minus: '\uE108'
  close: '\uE10A'
  cancel: '\uE10A'  
  check: '\uE10B'
  home: '\uE10F'
  clock: '\uE121'
  cut: '\uE16B'
  attachment: '\uE16C'
  paste: '\uE16D'
  filter: '\uE16E'
  copy: '\uE16F'
  folder: '\uE1C1'
  key: '\uE192'
  bold: '\uE19B'
  connected: '\uE0F7'
  disconnected: '\uE0F6'
  help: '\uE11B'
  laugh: '\uE11D'
  mirror: '\uE11E'
  sync: '\uE117'
  shield: '\uE1DE'
  bold: '\uE19B'
  sub: '\uE1C6'
  sup: '\uE1C7'
  isub: '\uE1C6'
  isup: '\uE1C7'
  symbol: '\uE1bc'
