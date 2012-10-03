/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Ajax.org Code Editor (ACE).
 *
 * The Initial Developer of the Original Code is
 * Ajax.org B.V.
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *      Sergi Mansilla <sergi AT ajax DOT org>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK *****
 *
 */

define(function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var lang = require("../lib/lang");
var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

var IsabelleHighlightRules = function() {
    var keywords = lang.arrayToMap((
        "header|theory|imports|keywords|uses|begin|end|lemma|text").split("|")
    );

    var digit = "(?:[0-9]*)"    

    var decimalInteger = "(?:(?:[1-9]\\d*)|(?:0))";
    var octInteger = "(?:0[oO]?[0-7]+)";
    var hexInteger = "(?:0[xX][\\dA-Fa-f]+)";
    var binInteger = "(?:0[bB][01]+)";
    var integer = "(?:" + decimalInteger + "|" + octInteger + "|" + hexInteger + "|" + binInteger + ")";    

    var exponent = "(?:[eE][+-]?\\d+)";
    var fraction = "(?:\\.\\d+)";
    var intPart = "(?:\\d+)";
    var pointFloat = "(?:(?:" + intPart + "?" + fraction + ")|(?:" + intPart + "\\.))";
    var exponentFloat = "(?:(?:" + pointFloat + "|" +  intPart + ")" + exponent + ")";
    var floatNumber = "(?:" + exponentFloat + "|" + pointFloat + ")";

    this.$rules = {
        "start" : [
            {
                token : "comment",
                regex : '\\(\\*.*\\*\\)'
            },
            {
                token : "comment",
                merge : true,
                regex : '\\(\\*.*',
                next : "comment"
            },
            {
                token : "comment",
                regex : '\\{\\*.*?\\*\\}\\s*?$'
            },
            {
                token : "comment",
                merge : true,
                regex : '\\{\\*.*',
                next : "verbatim"
            },            
            {
                token : "string", // single line
                regex : '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'
            },
            {
                token : "string", // " string
                merge : true,
                regex : '"',
                next  : "qstring"
            },
            {
                token : "string", // single line
                regex : '[`](?:(?:\\\\.)|(?:[^`\\\\]))*?[`]'
            },
            {
                token : "string", // " string
                merge : true,
                regex : '`',
                next  : "qstring2"
            },
            {
                token : "symbol", // single line
                regex : '\\\\<(?:(?:\\\\.)|(?:[^`\\\\]))*?>'
            },            
            {
                token : "constant.numeric", // imaginary
                regex : "(?:" + floatNumber + "|\\d+)[jJ]\\b"
            },
            {
                token : "constant.numeric", // float
                regex : floatNumber
            },
            {
                token : "constant.numeric", // integer
                regex : integer + "\\b"
            },
            {
                token : function(value) {
                    if (keywords.hasOwnProperty(value))
                        return "keyword";
                    else
                        return "identifier";
                },
                regex : "[a-zA-Z_$][a-zA-Z0-9_$]*\\b"
            },
            {
                token : "keyword.operator",
                regex : "\\+\\.|\\-\\.|\\*\\.|\\/\\.|#|;;|\\+|\\-|\\*|\\*\\*\\/|\\/\\/|%|<<|>>|&|\\||\\^|~|<|>|<=|=>|==|!=|<>|<-|="
            },
            {
                token : "paren.lparen",
                regex : "[[({]"
            },
            {
                token : "paren.rparen",
                regex : "[\\])}]"
            },
            {
                token : "text",
                regex : "\\s+"
            }
        ],
        "comment" : [
            {
                token : "comment", // closing comment
                regex : ".*?\\*\\)",
                next : "start"
            },
            {
                token : "comment", // comment spanning whole line
                merge : true,
                regex : ".+"
            }
        ],
        "verbatim" : [
            {
                token : "verbatim", // closing comment
                regex : ".*?\\*\\}",
                next : "start"
            },
            {
                token : "verbatim", // comment spanning whole line
                merge : true,
                regex : ".+"
            }
        ],
        "qstring" : [
            {
                token : "string",
                regex : '"',
                next : "start"
            }, {
                token : "string",
                merge : true,
                regex : '.+'
            }
        ],
        "qstring2" : [
            {
                token : "string",
                regex : '`',
                next : "start"
            }, {
                token : "string",
                merge : true,
                regex : '.+'
            }
        ]
    };
};

oop.inherits(IsabelleHighlightRules, TextHighlightRules);

exports.IsabelleHighlightRules = IsabelleHighlightRules;
});
