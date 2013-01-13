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
# summary: This file defines regular expressions for processing the outer syntax of isabelle
#          code.
#
####################################################################################################

define ->
  # extracted from the isabelle reference manual
  greek       = "(?:\\\\<(?:alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|' +
    'mu|nu|xi|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega|Gamma|Delta|Theta|Lambda|Xi|' +
    'Pi|Sigma|Upsilon|Phi|Psi|Omega)>)"
  digit       = "[0-9]"
  latin       = "[a-zA-Z]"
  sym         = "[\\!|\\#|\\$|\\%|\\&|\\*|\\+|\\-|\\/|\\<|\\=|\\>|\\?|\\@|\\^|\\_|\\||\\~]"
  letter      = "(?:#{latin}|\\\\<#{latin}{1,2}>|#{greek}|\\\\<^isu[bp]>)"
  quasiletter = "(?:#{letter}|#{digit}|\\_|\\')"
  ident       = "(?:#{letter}#{quasiletter}*)"
  longident   = "(?:#{ident}(?:\\.#{ident})+)"
  symident    = "(?:#{sym}+|\\\\<#{ident}>)"
  nat         = "(?:#{digit}+)"
  floating    = "-?#{nat}\\.#{nat}"  
  variable    = "\\?#{ident}(?:\\.#{nat})?"
  typefree    = "'#{ident}"
  typevar     = "\\?#{typefree}(?:\\.#{nat})"
  string      = "\\\".*\\\""
  altstring   = "`.*`"
  verbatim    = "{\\*.*\\*}"  
  abbrev =
    '\\<\\.|\\.\\>|\\(\\||\\|\\)|\\[\\||\\|\\]|\\{\\.|\\.\\}|\\/\\\\|\\\\\\/' +
    '|\\~\\:|\\(\\=|\\=\\)|\\[\\=|\\=\\]|\\+o|\\+O|\\*o|\\*O|\\.o|\\.O' +
    '|\\-o|\\/o|\\=\\_\\(|\\=\\_\\)|\\=\\^\\(|\\=\\^\\)|\\-\\.|\\.\\.\\.|(?:Int|Inter' +
    "|Un|Union|SUM|PROD)(?!#{quasiletter})"  

  abbrev      = RegExp abbrev
  greek       = RegExp greek      
  digit       = RegExp digit      
  latin       = RegExp latin      
  sym         = RegExp sym        
  letter      = RegExp letter     
  quasiletter = RegExp quasiletter
  ident       = RegExp ident      
  longident   = RegExp longident  
  symident    = RegExp symident   
  nat         = RegExp nat        
  floating    = RegExp floating   
  variable    = RegExp variable   
  typefree    = RegExp typefree   
  typevar     = RegExp typevar    
  string      = RegExp string     
  altstring   = RegExp altstring  
  verbatim    = RegExp verbatim   
  num         = /\#?-?[0-9]+(?:\.[0-9]+)?/
  escaped     = /\\[\"\\]/
  special     = /\\<[A-Za-z]+>/
  control     = /\\<\^[A-Za-z]+>/
  incomplete  = /\\<\^{0,1}[A-Za-z]*>?/
  lineComment = /--.*/