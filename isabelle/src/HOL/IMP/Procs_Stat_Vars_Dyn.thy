theory Procs_Stat_Vars_Dyn imports Procs
begin

subsubsection "Static Scoping of Procedures, Dynamic of Variables"

type_synonym penv = "(pname \<times> com) list"

inductive
  big_step :: "penv \<Rightarrow> com \<times> state \<Rightarrow> state \<Rightarrow> bool" ("_ \<turnstile> _ \<Rightarrow> _" [60,0,60] 55)
where
Skip:    "pe \<turnstile> (SKIP,s) \<Rightarrow> s" |
Assign:  "pe \<turnstile> (x ::= a,s) \<Rightarrow> s(x := aval a s)" |
Seq:     "\<lbrakk> pe \<turnstile> (c\<^isub>1,s\<^isub>1) \<Rightarrow> s\<^isub>2;  pe \<turnstile> (c\<^isub>2,s\<^isub>2) \<Rightarrow> s\<^isub>3 \<rbrakk> \<Longrightarrow>
          pe \<turnstile> (c\<^isub>1;c\<^isub>2, s\<^isub>1) \<Rightarrow> s\<^isub>3" |

IfTrue:  "\<lbrakk> bval b s;  pe \<turnstile> (c\<^isub>1,s) \<Rightarrow> t \<rbrakk> \<Longrightarrow>
         pe \<turnstile> (IF b THEN c\<^isub>1 ELSE c\<^isub>2, s) \<Rightarrow> t" |
IfFalse: "\<lbrakk> \<not>bval b s;  pe \<turnstile> (c\<^isub>2,s) \<Rightarrow> t \<rbrakk> \<Longrightarrow>
         pe \<turnstile> (IF b THEN c\<^isub>1 ELSE c\<^isub>2, s) \<Rightarrow> t" |

WhileFalse: "\<not>bval b s \<Longrightarrow> pe \<turnstile> (WHILE b DO c,s) \<Rightarrow> s" |
WhileTrue:
  "\<lbrakk> bval b s\<^isub>1;  pe \<turnstile> (c,s\<^isub>1) \<Rightarrow> s\<^isub>2;  pe \<turnstile> (WHILE b DO c, s\<^isub>2) \<Rightarrow> s\<^isub>3 \<rbrakk> \<Longrightarrow>
   pe \<turnstile> (WHILE b DO c, s\<^isub>1) \<Rightarrow> s\<^isub>3" |

Var: "pe \<turnstile> (c,s) \<Rightarrow> t  \<Longrightarrow>  pe \<turnstile> ({VAR x;; c}, s) \<Rightarrow> t(x := s x)" |

Call1: "(p,c)#pe \<turnstile> (c, s) \<Rightarrow> t  \<Longrightarrow>  (p,c)#pe \<turnstile> (CALL p, s) \<Rightarrow> t" |
Call2: "\<lbrakk> p' \<noteq> p;  pe \<turnstile> (CALL p, s) \<Rightarrow> t \<rbrakk> \<Longrightarrow>
       (p',c)#pe \<turnstile> (CALL p, s) \<Rightarrow> t" |

Proc: "(p,cp)#pe \<turnstile> (c,s) \<Rightarrow> t  \<Longrightarrow>  pe \<turnstile> ({PROC p = cp;; c}, s) \<Rightarrow> t"

code_pred big_step .

values "{map t [''x'', ''y'', ''z''] |t. 
            [] \<turnstile> (CALL ''p'', <''x'' := 42, ''y'' := 43>) \<Rightarrow> t}"

values "{map t [''x'', ''y'', ''z''] |t. [] \<turnstile> (test_com, <>) \<Rightarrow> t}"

end
