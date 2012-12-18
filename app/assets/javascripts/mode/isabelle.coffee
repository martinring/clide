CodeMirror.defineMode "isabelle", (config,parserConfig) ->  
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

  special = 
    startState: () ->
      control: null
      sub:     false
      sup:     false
    token: (stream,state) ->
      if stream.sol()
        state.control = null
      x = ''
      if      state.sub then x = 'sub control-sub '
      else if state.sup then x = 'sup control-sup '
      if state.control is 'sub'        
        stream.match(incomplete) or stream.next()
        state.control = null
        return x + 'sub'
      if state.control is 'sup'
        stream.match(incomplete) or stream.next()
        state.control = null
        return x + 'sup'
      if state.control is 'bold'
        console.log 'insub'
        stream.match(incomplete) or stream.next()
        state.control = null
        return x + 'bold'
      if stream.eatWhile(/[^\\]/)
        if x isnt ''
          return x
        return null
      if stream.match(/\\<\^[A-Za-z]+>/)
        switch stream.current()
          when '\\<^sub>'            
            state.control = 'sub'            
          when '\\<^sup>'
            state.control = 'sup'
          when '\\<^isub>'
            state.control = 'sub'
          when '\\<^isup>'
            state.control = 'sup'
          when '\\<^bold>'
            state.control = 'bold'
          when '\\<^bsub>'
            state.sub = true
            return "#{x}control control-sub"
          when '\\<^bsup>'
            state.sup = true
            return "#{x}control control-sup"
          when '\\<^esub>'
            state.sub = false
            return "control"
          when '\\<^esup>'
            state.sup = false
            return "control"
        if state.control?
          return "#{x}control control-#{state.control}"
        else
          return x + 'control'
      if stream.match(/\\<[A-Za-z]+>/)
        return x + 'special'      
      stream.next()
      if x isnt ''
        return x
      return null

  words =
    '.' :  'command'
    '..' : 'command'
    'Isabelle.command' : 'command'
    'Isar.begin_document' :  'command'
    'Isar.define_command' :  'command'
    'Isar.edit_document' : 'command'
    'Isar.end_document' :  'command'
    'ML' : 'command'
    'ML_command' : 'command'
    'ML_prf' : 'command'
    'ML_val' : 'command'
    'ProofGeneral.inform_file_processed' : 'command'
    'ProofGeneral.inform_file_retracted' : 'command'
    'ProofGeneral.kill_proof' :  'command'
    'ProofGeneral.pr' :  'command'
    'ProofGeneral.process_pgip' :  'command'
    'ProofGeneral.restart' : 'command'
    'ProofGeneral.undo' :  'command'
    'abbreviation' : 'command'
    'also' : 'command'
    'apply' :  'command'
    'apply_end' :  'command'
    'arities' :  'command'
    'assume' : 'command'
    'atom_decl' :  'command'
    'attribute_setup' :  'command'
    'automaton' :  'command'
    'ax_specification' : 'command'
    'axiomatization' : 'command'
    'axioms' : 'command'
    'back' : 'command'
    'boogie_end' : 'command'
    'boogie_open' :  'command'
    'boogie_status' :  'command'
    'boogie_vc' :  'command'
    'by' : 'command'
    'cannot_undo' :  'command'
    'case' : 'command'
    'cd' : 'command'
    'chapter' :  'command'
    'class' :  'command'
    'class_deps' : 'command'
    'classes' :  'command'
    'classrel' : 'command'
    'code_abort' : 'command'
    'code_class' : 'command'
    'code_const' : 'command'
    'code_datatype' :  'command'
    'code_deps' :  'command'
    'code_include' : 'command'
    'code_instance' :  'command'
    'code_library' : 'command'
    'code_module' :  'command'
    'code_modulename' :  'command'
    'code_monad' : 'command'
    'code_pred' :  'command'
    'code_reflect' : 'command'
    'code_reserved' :  'command'
    'code_thms' :  'command'
    'code_type' :  'command'
    'coinductive' :  'command'
    'coinductive_set' :  'command'
    'commit' : 'command'
    'constdefs' :  'command'
    'consts' : 'command'
    'consts_code' :  'command'
    'context' :  'command'
    'corollary' :  'command'
    'cpodef' : 'command'
    'datatype' : 'command'
    'declaration' :  'command'
    'declare' :  'command'
    'def' :  'command'
    'default_sort' : 'command'
    'defer' :  'command'
    'defer_recdef' : 'command'
    'definition' : 'command'
    'defs' : 'command'
    'disable_pr' : 'command'
    'display_drafts' : 'command'
    'domain' : 'command'
    'domain_isomorphism' : 'command'
    'done' : 'command'
    'enable_pr' :  'command'
    'end' :  'keyword'
    'equivariance' : 'command'
    'example_proof' :  'command'
    'exit' : 'command'
    'export_code' :  'command'
    'extract' :  'command'
    'extract_type' : 'command'
    'finalconsts' :  'command'
    'finally' :  'command'
    'find_consts' :  'command'
    'find_theorems' :  'command'
    'fix' :  'command'
    'fixpat' : 'command'
    'fixrec' : 'command'
    'from' : 'command'
    'full_prf' : 'command'
    'fun' :  'command'
    'function' : 'command'
    'global' : 'command'
    'guess' :  'command'
    'have' : 'command'
    'header' : 'command'
    'help' : 'command'
    'hence' :  'command'
    'hide_class' : 'command'
    'hide_const' : 'command'
    'hide_fact' :  'command'
    'hide_type' :  'command'
    'inductive' :  'command'
    'inductive_cases' :  'command'
    'inductive_set' :  'command'
    'init_toplevel' :  'command'
    'instance' : 'command'
    'instantiation' :  'command'
    'interpret' :  'command'
    'interpretation' : 'command'
    'judgment' : 'command'
    'kill' : 'command'
    'kill_thy' : 'command'
    'lemma' :  'command'
    'lemmas' : 'command'
    'let' :  'command'
    'linear_undo' :  'command'
    'local' :  'command'
    'local_setup' :  'command'
    'locale' : 'command'
    'method_setup' : 'command'
    'moreover' : 'command'
    'new_domain' : 'command'
    'next' : 'command'
    'nitpick' :  'command'
    'nitpick_params' : 'command'
    'no_notation' :  'command'
    'no_syntax' :  'command'
    'no_translations' :  'command'
    'no_type_notation' : 'command'
    'nominal_datatype' : 'command'
    'nominal_inductive' :  'command'
    'nominal_inductive2' : 'command'
    'nominal_primrec' :  'command'
    'nonterminals' : 'command'
    'normal_form' :  'command'
    'notation' : 'command'
    'note' : 'command'
    'notepad' : 'command'
    'obtain' : 'command'
    'oops' : 'command'
    'oracle' : 'command'
    'overloading' :  'command'
    'parse_ast_translation' :  'command'
    'parse_translation' :  'command'
    'pcpodef' :  'command'
    'pr' : 'command'
    'prefer' : 'command'
    'presume' :  'command'
    'pretty_setmargin' : 'command'
    'prf' :  'command'
    'primrec' :  'command'
    'print_abbrevs' :  'command'
    'print_antiquotations' : 'command'
    'print_ast_translation' :  'command'
    'print_attributes' : 'command'
    'print_binds' :  'command'
    'print_cases' :  'command'
    'print_claset' : 'command'
    'print_classes' :  'command'
    'print_codeproc' : 'command'
    'print_codesetup' :  'command'
    'print_commands' : 'command'
    'print_configs' :  'command'
    'print_context' :  'command'
    'print_drafts' : 'command'
    'print_facts' :  'command'
    'print_induct_rules' : 'command'
    'print_interps' :  'command'
    'print_locale' : 'command'
    'print_locales' :  'command'
    'print_methods' :  'command'
    'print_orders' : 'command'
    'print_quotconsts' : 'command'
    'print_quotients' :  'command'
    'print_quotmaps' : 'command'
    'print_rules' :  'command'
    'print_simpset' :  'command'
    'print_statement' :  'command'
    'print_syntax' : 'command'
    'print_theorems' : 'command'
    'print_theory' : 'command'
    'print_trans_rules' :  'command'
    'print_translation' :  'command'
    'proof' :  'command'
    'prop' : 'command'
    'pwd' :  'command'
    'qed' :  'command'
    'quickcheck' : 'command'
    'quickcheck_params' :  'command'
    'quit' : 'command'
    'quotient_definition' :  'command'
    'quotient_type' :  'command'
    'realizability' :  'command'
    'realizers' :  'command'
    'recdef' : 'command'
    'recdef_tc' :  'command'
    'record' : 'command'
    'refute' : 'command'
    'refute_params' :  'command'
    'remove_thy' : 'command'
    'rep_datatype' : 'command'
    'repdef' : 'command'
    'schematic_corollary' :  'command'
    'schematic_lemma' :  'command'
    'schematic_theorem' :  'command'
    'sect' : 'command'
    'section' :  'command'
    'setup' :  'command'
    'show' : 'command'
    'simproc_setup' :  'command'
    'sledgehammer' : 'command'
    'sledgehammer_params' :  'command'
    'smt_status' : 'command'
    'sorry' :  'command'
    'specification' :  'command'
    'statespace' : 'command'
    'subclass' : 'command'
    'sublocale' :  'command'
    'subsect' :  'command'
    'subsection' : 'command'
    'subsubsect' : 'command'
    'subsubsection' :  'command'
    'syntax' : 'command'
    'term' : 'command'
    'termination' :  'command'
    'text' : 'command'
    'text_raw' : 'command'
    'then' : 'command'
    'theorem' :  'command'
    'theorems' : 'command'
    'theory' : 'command'
    'thm' :  'command'
    'thm_deps' : 'command'
    'thus' : 'command'
    'thy_deps' : 'command'
    'touch_thy' :  'command'
    'translations' : 'command'
    'txt' :  'command'
    'txt_raw' :  'command'
    'typ' :  'command'
    'type_notation' :  'command'
    'typed_print_translation' :  'command'
    'typedecl' : 'command'
    'typedef' :  'command'
    'types' :  'command'
    'types_code' : 'command'
    'ultimately' : 'command'
    'undo' : 'command'
    'undos_proof' :  'command'
    'unfolding' :  'command'
    'unused_thms' :  'command'
    'use' :  'command'
    'use_thy' :  'command'
    'using' :  'command'
    'value' :  'command'
    'values' : 'command'
    'welcome' :  'command'
    'with' : 'command'
    'write' :  'command'
    '{' :  'command'
    '}' :  'command'
    'actions' : 'keyword'
    'advanced' : 'keyword'
    'and' : 'keyword'
    'assumes' : 'keyword'
    'attach' : 'keyword'
    'avoids' : 'keyword'
    'begin' : 'keyword'
    'binder' : 'keyword'
    'compose' : 'keyword'
    'congs' : 'keyword'
    'constrains' : 'keyword'
    'contains' : 'keyword'
    'datatypes' : 'keyword'
    'defines' : 'keyword'
    'file' : 'keyword'
    'fixes' : 'keyword'
    'for' : 'keyword'
    'functions' : 'keyword'
    'hide_action' : 'keyword'
    'hints' : 'keyword'
    'identifier' : 'keyword'
    'if' : 'keyword'
    'imports' : 'keyword'
    'in' : 'keyword'
    'infix' : 'keyword'
    'infixl' : 'keyword'
    'infixr' : 'keyword'
    'initially' : 'keyword'
    'inputs' : 'keyword'
    'internals' : 'keyword'
    'is' : 'keyword'
    'lazy' : 'keyword'
    'module_name' : 'keyword'
    'monos' : 'keyword'
    'morphisms' : 'keyword'
    'notes' : 'keyword'
    'obtains' : 'keyword'
    'open' : 'keyword'
    'output' : 'keyword'
    'outputs' : 'keyword'
    'overloaded' : 'keyword'
    'permissive' : 'keyword'
    'pervasive' : 'keyword'
    'post' : 'keyword'
    'pre' : 'keyword'
    'rename' : 'keyword'
    'restrict' : 'keyword'
    'shows' : 'keyword'
    'signature' : 'keyword'
    'states' : 'keyword'
    'structure' : 'keyword'
    'to' : 'keyword'
    'transitions' : 'keyword'
    'transrel' : 'keyword'
    'unchecked' : 'keyword'
    'uses' : 'keyword'
    'where' : 'keyword'


  delimiters = [
    'rightarrow'
    'Rightarrow'
  ]

  tokenBase = (stream, state) ->    
    ch = stream.peek()

    # verbatim
    if ch is '{'
      stream.next()
      if stream.eat('*')        
        state.verbatimLevel++
        state.tokenize = tokenVerbatim
        return state.tokenize(stream, state)
      else stream.backUp(1)
    
    state.command = null

    # string
    if ch is '"'
      stream.next()
      state.tokenize = tokenString
      return "string"

    # alt string
    if ch is '`'
      stream.next()
      state.tokenize = tokenAltString
      return "altstring"

    # comment
    if ch is '('
      stream.next()
      if stream.eat('*')
        state.commentLevel++
        state.tokenize = tokenComment
        return state.tokenize(stream, state)   
      else stream.backUp(1)   

    if stream.match(abbrev)
      return 'symbol'
    if stream.match(typefree)
      return 'tfree'
    else if stream.match(typevar)
      return "tvar"    
    else if stream.match(variable)
      return "var"    
    else if stream.match(longident) or stream.match(ident)
      type = words[stream.current()] || "identifier"
      if type is 'command'        
        type = type + " " + stream.current()
        state.command = stream.current()
      return type
    else if stream.match(symident)      
      return "symbol"
    else if stream.match(control)
      return null
    else if stream.match(incomplete)
      return 'incomplete'

    stream.next()
    return null

  tokenString = (stream, state) ->
    if stream.eatSpace()
      return 'string'
    if stream.match('\"')
      state.tokenize = tokenBase
      return 'string'
    if stream.match(longident)
      return 'string longident'
    if stream.match(ident)
      return 'string ident' 
    if stream.match(typefree)
      return 'string tfree'
    if stream.match(typevar)
      return 'string tvar'
    if stream.match(symident)
      return 'string symbol'
    if stream.match(num)
      return 'string num'
    if stream.match(escaped)
      return 'string'
    if stream.match(control)
      return null
    else if stream.match(incomplete)
      return 'incomplete'
    stream.next()
    return 'string'

  tokenAltString = (stream, state) ->
    next = false
    end = false
    escaped = false
    while ((next = stream.next())?)
      if next is '`' and not escaped
        end = true
        break 
      escaped = not escaped and next is '\\'    
    if end and not escaped
      state.tokenize = tokenBase    
    return 'alt_string'  

  tokenComment = (stream, state) ->
    prev = null
    next = null
    while state.commentLevel > 0 and (next = stream.next())?
      if prev is '(' and next is '*' then state.commentLevel++
      if prev is '*' and next is ')' then state.commentLevel--
      prev = next    
    if state.commentLevel <= 0
      state.tokenize = tokenBase    
    return 'comment'

  tokenVerbatim = (stream, state) ->
    prev = null
    next = null
    while (next = stream.next())?      
      if prev is '*' and next is '}'
        state.tokenize = tokenBase
        return 'verbatim' + (if state.command? then ' ' + state.command else '')
      prev = next
    return 'verbatim' + (if state.command? then ' ' + state.command else '')

  CodeMirror.overlayMode((
    startState: () ->
      string:        null
      tokenize:      tokenBase
      command:       null
      commentLevel:  0

    token: (stream,state) ->
      if stream.sol() and stream.eatSpace()
        return "indent"
      if stream.eatSpace()
        return 'whitespace'
      else
        return state.tokenize(stream, state)
  ),special,true)

CodeMirror.defineMIME("text/x-isabelle","isabelle")