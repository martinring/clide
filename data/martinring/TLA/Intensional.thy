(*  Title:       A Definitional Encoding of TLA in Isabelle/HOL
    Authors:     Gudmund Grov <ggrov at inf.ed.ac.uk>
                 Stephan Merz <Stephan.Merz at loria.fr>
    Year:        2011
    Maintainer:  Gudmund Grov <ggrov at inf.ed.ac.uk>
*)

header {* Representing Intensional Logic  *}

theory Intensional 
imports Main
begin

text{* 
  In higher-order logic, every proof rule has a corresponding tautology, i.e.
  the \emph{deduction theorem} holds. Isabelle/HOL implements this since object-level
  implication ($\longrightarrow$) and meta-level entailment ($\Longrightarrow$) 
  commute, viz. the proof rule @{text "impI:"} @{thm impI}. 
  However, the deduction theorem does not hold for 
  most modal and temporal logics \cite[page 95]{Lamport02}\cite{Merz98}.
  For example $A \vdash \Box A$ holds, meaning that if $A$ holds in any world, then
  it always holds. However, $\vdash A \longrightarrow \Box A$, stating that 
  $A$ always holds if it initially holds, is not valid.

  Merz  \cite{Merz98} overcame this problem by creating an
  @{term Intensional} logic. It exploits Isabelle's 
  axiomatic type class feature  \cite{Wenzel00b} by creating a type
  class @{term world}, which provides Skolem constants to associate formulas
  with the world they hold in. The class is trivial, not requiring any axioms.
*}

class world 
text {*
  @{term world} is a type class of possible worlds. It is a subclass
  of all HOL types @{term type}. No axioms are provided, since its only
  purpose is to avoid silly use of the @{term Intensional} syntax.
*}

subsection{* Abstract Syntax *}


type_synonym ('w,'a) expr = "'w \<Rightarrow> 'a"         
type_synonym  'w form = "('w, bool) expr"

text {* The intention is that @{typ 'a} will be used for unlifted
types (class @{term type}), while @{typ 'w} is lifted (class @{term world}). 
*}

consts
  Valid    :: "('w::world) form \<Rightarrow> bool"
  const    :: "'a \<Rightarrow> ('w::world, 'a) expr"
  lift     :: "['a \<Rightarrow> 'b, ('w::world, 'a) expr] \<Rightarrow> ('w,'b) expr"
  lift2    :: "['a \<Rightarrow> 'b \<Rightarrow> 'c, ('w::world,'a) expr, ('w,'b) expr] \<Rightarrow> ('w,'c) expr"
  lift3    :: "['a \<Rightarrow> 'b => 'c \<Rightarrow> 'd, ('w::world,'a) expr, ('w,'b) expr, ('w,'c) expr] \<Rightarrow> ('w,'d) expr"
  lift4    :: "['a \<Rightarrow> 'b => 'c \<Rightarrow> 'd \<Rightarrow> 'e, ('w::world,'a) expr, ('w,'b) expr, ('w,'c) expr,('w,'d) expr] \<Rightarrow> ('w,'e) expr"

text {* 
  @{term "Valid F"} asserts that the lifted formula @{term F} holds everywhere.
  @{term const} allows lifting of a constant, while @{term lift} through
  @{term lift4} allow functions with arity 1--4 to be lifted. (Note that there
  is no way to define a generic lifting operator for functions of arbitrary arity.)
*}

consts
  RAll     :: "('a \<Rightarrow> ('w::world) form) \<Rightarrow> 'w form"      (binder "Rall " 10)
  REx      :: "('a \<Rightarrow> ('w::world) form) \<Rightarrow> 'w form"      (binder "Rex " 10)
  REx1     :: "('a \<Rightarrow> ('w::world) form) \<Rightarrow> 'w form"      (binder "Rex! " 10)

text {* 
  @{term RAll}, @{term REx} and @{term REx1} introduces ``rigid'' quantification
  over values (of non-world types) within ``intensional'' formulas. @{term RAll}
  is universal quantification, @{term REx} is existential quantifcation.
  @{term REx1} requires unique existence.
*}


subsection{* Concrete Syntax *}

nonterminal
  lift and liftargs

text{*
  The non-terminal @{term lift} represents lifted expressions. The idea is to use 
  Isabelle's macro mechanism to convert between the concrete and abstract syntax.
*}

syntax
  ""            :: "id \<Rightarrow> lift"                          ("_")
  ""            :: "longid \<Rightarrow> lift"                      ("_")
  ""            :: "var \<Rightarrow> lift"                         ("_")
  "_applC"      :: "[lift, cargs] \<Rightarrow> lift"               ("(1_/ _)" [1000, 1000] 999)
  ""            :: "lift \<Rightarrow> lift"                        ("'(_')")
  "_lambda"     :: "[idts, 'a] \<Rightarrow> lift"                  ("(3%_./ _)" [0, 3] 3)
  "_constrain"  :: "[lift, type] \<Rightarrow> lift"                ("(_::_)" [4, 0] 3)
  ""            :: "lift \<Rightarrow> liftargs"                    ("_")
  "_liftargs"   :: "[lift, liftargs] \<Rightarrow> liftargs"        ("_,/ _")
  "_Valid"      :: "lift \<Rightarrow> bool"                        ("(|- _)" 5)
  "_holdsAt"    :: "['a, lift] \<Rightarrow> bool"                  ("(_ |= _)" [100,10] 10)

  (* Syntax for lifted expressions outside the scope of \<turnstile> or \<Turnstile>.*)
  "LIFT"        :: "lift \<Rightarrow> 'a"                          ("LIFT _")

  (* generic syntax for lifted constants and functions *)
  "_const"      :: "'a \<Rightarrow> lift"                          ("(#_)" [1000] 999)
  "_lift"       :: "['a, lift] \<Rightarrow> lift"                  ("(_<_>)" [1000] 999)
  "_lift2"      :: "['a, lift, lift] \<Rightarrow> lift"            ("(_<_,/ _>)" [1000] 999)
  "_lift3"      :: "['a, lift, lift, lift] \<Rightarrow> lift"      ("(_<_,/ _,/ _>)" [1000] 999)
  "_lift4"      :: "['a, lift, lift, lift,lift] \<Rightarrow> lift"      ("(_<_,/ _,/ _,/ _>)" [1000] 999)

  (* concrete syntax for common infix functions: reuse same symbol *)
  "_liftEqu"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ =/ _)" [50,51] 50)
  "_liftNeq"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ ~=/ _)" [50,51] 50)
  "_liftNot"    :: "lift \<Rightarrow> lift"                        ("(~ _)" [90] 90)
  "_liftAnd"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ &/ _)" [36,35] 35)
  "_liftOr"     :: "[lift, lift] \<Rightarrow> lift"                ("(_ |/ _)" [31,30] 30)
  "_liftImp"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ -->/ _)" [26,25] 25)
  "_liftIf"     :: "[lift, lift, lift] \<Rightarrow> lift"          ("(if (_)/ then (_)/ else (_))" 10)
  "_liftPlus"   :: "[lift, lift] \<Rightarrow> lift"                ("(_ +/ _)" [66,65] 65)
  "_liftMinus"  :: "[lift, lift] \<Rightarrow> lift"                ("(_ -/ _)" [66,65] 65)
  "_liftTimes"  :: "[lift, lift] \<Rightarrow> lift"                ("(_ */ _)" [71,70] 70)
  "_liftDiv"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ div _)" [71,70] 70)
  "_liftMod"    :: "[lift, lift] \<Rightarrow> lift"                ("(_ mod _)" [71,70] 70)
  "_liftLess"   :: "[lift, lift] \<Rightarrow> lift"                ("(_/ < _)"  [50, 51] 50)
  "_liftLeq"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ <= _)" [50, 51] 50)
  "_liftMem"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ : _)" [50, 51] 50)
  "_liftNotMem" :: "[lift, lift] \<Rightarrow> lift"                ("(_/ ~: _)" [50, 51] 50)
  "_liftFinset" :: "liftargs => lift"                    ("{(_)}")
  (** TODO: syntax for lifted collection / comprehension **)
  "_liftPair"   :: "[lift,liftargs] \<Rightarrow> lift"                   ("(1'(_,/ _'))")
  (* infix syntax for list operations *)
  "_liftCons" :: "[lift, lift] \<Rightarrow> lift"                  ("(_ #/ _)" [65,66] 65)
  "_liftApp"  :: "[lift, lift] \<Rightarrow> lift"                  ("(_ @/ _)" [65,66] 65)
  "_liftList" :: "liftargs \<Rightarrow> lift"                      ("[(_)]")

  (* Rigid quantification (syntax level) *)
  "_ARAll"  :: "[idts, lift] \<Rightarrow> lift"                    ("(3! _./ _)" [0, 10] 10)
  "_AREx"   :: "[idts, lift] \<Rightarrow> lift"                    ("(3? _./ _)" [0, 10] 10)
  "_AREx1"  :: "[idts, lift] \<Rightarrow> lift"                    ("(3?! _./ _)" [0, 10] 10)
  "_RAll" :: "[idts, lift] \<Rightarrow> lift"                      ("(3ALL _./ _)" [0, 10] 10)
  "_REx"  :: "[idts, lift] \<Rightarrow> lift"                      ("(3EX _./ _)" [0, 10] 10)
  "_REx1" :: "[idts, lift] \<Rightarrow> lift"                      ("(3EX! _./ _)" [0, 10] 10)

translations
  "_const"        \<rightleftharpoons>  "CONST const"

translations
  "_lift"         \<rightleftharpoons> "CONST lift"
  "_lift2"        \<rightleftharpoons> "CONST lift2"
  "_lift3"        \<rightleftharpoons> "CONST lift3"
  "_lift4"        \<rightleftharpoons> "CONST lift4"
  "_Valid"        \<rightleftharpoons> "CONST Valid"

translations
  "_RAll x A"     \<rightleftharpoons> "Rall x. A"
  "_REx x A"      \<rightleftharpoons> "Rex x. A"
  "_REx1 x A"     \<rightleftharpoons> "Rex! x. A"

translations
  "_ARAll"        \<rightharpoonup>  "_RAll"
  "_AREx"         \<rightharpoonup> "_REx"
  "_AREx1"        \<rightharpoonup> "_REx1"

  "w |= A"        \<rightharpoonup> "A w"
  "LIFT A"        \<rightharpoonup> "A::_\<Rightarrow>_"

translations
  "_liftEqu"      \<rightleftharpoons> "_lift2 (op =)"
  "_liftNeq u v"  \<rightleftharpoons> "_liftNot (_liftEqu u v)"
  "_liftNot"      \<rightleftharpoons> "_lift (CONST Not)"
  "_liftAnd"      \<rightleftharpoons> "_lift2 (op &)"
  "_liftOr"       \<rightleftharpoons> "_lift2 (op | )"
  "_liftImp"      \<rightleftharpoons> "_lift2 (op -->)"
  "_liftIf"       \<rightleftharpoons> "_lift3 (CONST If)"
  "_liftPlus"     \<rightleftharpoons> "_lift2 (op +)"
  "_liftMinus"    \<rightleftharpoons> "_lift2 (op -)"
  "_liftTimes"    \<rightleftharpoons> "_lift2 (op *)"
  "_liftDiv"      \<rightleftharpoons> "_lift2 (op div)"
 "_liftMod"      \<rightleftharpoons> "_lift2 (op mod)"
  "_liftLess"     \<rightleftharpoons> "_lift2 (op <)"
  "_liftLeq"      \<rightleftharpoons> "_lift2 (op <=)"
  "_liftMem"      \<rightleftharpoons> "_lift2 (op :)"
  "_liftNotMem x xs"             \<rightleftharpoons> "_liftNot (_liftMem x xs)"

translations
  "_liftFinset (_liftargs x xs)" \<rightleftharpoons> "_lift2 (CONST insert) x (_liftFinset xs)"
  "_liftFinset x"                \<rightleftharpoons> "_lift2 (CONST insert) x (_const (CONST Set.empty))"
  "_liftPair x (_liftargs y z)"  \<rightleftharpoons> "_liftPair x (_liftPair y z)"
  "_liftPair"                    \<rightleftharpoons> "_lift2 (CONST Pair)"
  "_liftCons"                    \<rightleftharpoons> "_lift2 (CONST Cons)"
  "_liftApp"                     \<rightleftharpoons> "_lift2 (op @)"
  "_liftList (_liftargs x xs)"   \<rightleftharpoons> "_liftCons x (_liftList xs)"
  "_liftList x"                  \<rightleftharpoons> "_liftCons x (_const [])"

  "w |= ~A"       \<leftharpoondown>  "_liftNot A w"
  "w |=  A & B"   \<leftharpoondown> "_liftAnd A B w"
  "w |= A | B"    \<leftharpoondown> "_liftOr A B w"
  "w |= A --> B"  \<leftharpoondown> "_liftImp A B w"
  "w |= u = v"    \<leftharpoondown> "_liftEqu u v w"
  "w |= ALL x. A" \<leftharpoondown> "_RAll x A w"
  "w |= EX x. A"  \<leftharpoondown> "_REx x A w"
  "w |= EX! x. A" \<leftharpoondown> "_REx1 x A w"

syntax (xsymbols)
  "_Valid"      :: "lift \<Rightarrow> bool"                        ("(\<turnstile> _)" 5)
  "_holdsAt"    :: "['a, lift] \<Rightarrow> bool"                  ("(_ \<Turnstile> _)" [100,10] 10)
  "_liftNeq"    :: "[lift, lift] \<Rightarrow> lift"                (infixl "\<noteq>" 50)
  "_liftNot"    :: "lift \<Rightarrow> lift"                        ("\<not> _" [90] 90)
  "_liftAnd"    :: "[lift, lift] \<Rightarrow> lift"                (infixr "\<and>" 35)
  "_liftOr"     :: "[lift, lift] \<Rightarrow> lift"                (infixr "\<or>" 30)
  "_liftImp"    :: "[lift, lift] \<Rightarrow> lift"                (infixr "\<longrightarrow>" 25)
  "_RAll"       :: "[idts, lift] \<Rightarrow> lift"                ("(3\<forall>_./ _)" [0, 10] 10)
  "_REx"        :: "[idts, lift] \<Rightarrow> lift"                ("(3\<exists>_./ _)" [0, 10] 10)
  "_REx1"       :: "[idts, lift] \<Rightarrow> lift"                ("(3\<exists>!_./ _)" [0, 10] 10)
  "_liftLeq"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<le> _)" [50, 51] 50)
  "_liftMem"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<in> _)" [50, 51] 50)
  "_liftNotMem" :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<notin> _)" [50, 51] 50)

syntax (HTML output)
  "_liftNeq"    :: "[lift, lift] \<Rightarrow> lift"                (infixl "\<noteq>" 50)
  "_liftNot"    :: "lift \<Rightarrow> lift"                        ("\<not> _" [90] 90)
  "_liftAnd"    :: "[lift, lift] \<Rightarrow> lift"                (infixr "\<and>" 35)
  "_liftOr"     :: "[lift, lift] \<Rightarrow> lift"                (infixr "\<or>" 30)
  "_RAll"       :: "[idts, lift] \<Rightarrow> lift"                ("(3\<forall>_./ _)" [0, 10] 10)
  "_REx"        :: "[idts, lift] \<Rightarrow> lift"                ("(3\<exists>_./ _)" [0, 10] 10)
  "_REx1"       :: "[idts, lift] \<Rightarrow> lift"                ("(3\<exists>!_./ _)" [0, 10] 10)
  "_liftLeq"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<le> _)" [50, 51] 50)
  "_liftMem"    :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<in> _)" [50, 51] 50)
  "_liftNotMem" :: "[lift, lift] \<Rightarrow> lift"                ("(_/ \<notin> _)" [50, 51] 50)

subsection {* Definitions *}

defs
  Valid_def:   "\<turnstile> A    \<equiv>  \<forall>w. w \<Turnstile> A"
  unl_con:     "LIFT #c w  \<equiv>  c"
  unl_lift:    "(LIFT f<x>) w \<equiv> f (x w)"
  unl_lift2:   "LIFT f<x, y> w \<equiv> f (x w) (y w)"
  unl_lift3:   "LIFT f<x, y, z> w \<equiv> f (x w) (y w) (z w)"
  unl_lift4:   "LIFT f<x, y, z, zz> w \<equiv> f (x w) (y w) (z w) (zz w)"

defs
  unl_Rall:    "w \<Turnstile> \<forall>x. A x   \<equiv>  \<forall>x. (w \<Turnstile> A x)"
  unl_Rex:     "w \<Turnstile> \<exists>x. A x   \<equiv>  \<exists>x. (w \<Turnstile> A x)"
  unl_Rex1:    "w \<Turnstile> \<exists>!x. A x  \<equiv>  \<exists>! x. (w \<Turnstile> A x)"

text {*
  We declare the ``unlifting rules'' as rewrite rules that will be applied
  automatically.
*}

lemmas intensional_rews[simp] = 
  unl_con unl_lift unl_lift2 unl_lift3 unl_lift4 
  unl_Rall unl_Rex unl_Rex1

subsection {* Lemmas and Tactics *}

lemma intD[dest]: "\<turnstile> A \<Longrightarrow> w \<Turnstile> A"
proof -
  assume a:"\<turnstile> A"
  from a have "ALL w. w \<Turnstile> A" by (auto simp add: Valid_def)
  thus ?thesis ..
qed

lemma intI [intro!]: assumes P1:"(\<And> w. w \<Turnstile> A)" shows "\<turnstile> A"
  using assms by (auto simp: Valid_def)

text{*
  Basic unlifting introduces a parameter @{term w} and applies basic rewrites, e.g 
  @{term "\<turnstile> F = G"} becomes @{term "F w = G w"} and @{term "\<turnstile> F \<longrightarrow> G"} becomes   
  @{term "F w \<longrightarrow> G w"}.
*}

method_setup int_unlift = {* Scan.succeed
  (K (SIMPLE_METHOD ((rtac @{thm intI} 
                      THEN' rewrite_goal_tac @{thms intensional_rews}) 1))) *} 
  "method to unlift and followed by intensional rewrites"

lemma inteq_reflection: assumes P1: "\<turnstile> x=y" shows  "(x \<equiv> y)"
proof -
  from P1 have P2: "ALL w. x w = y w" by (unfold Valid_def unl_lift2)
  hence P3:"x=y" by blast
  thus "x \<equiv> y" by (rule "eq_reflection")
qed

lemma int_simps:
  "\<turnstile> (x=x) = #True"
  "\<turnstile> (\<not> #True) = #False"
  "\<turnstile> (\<not> #False) = #True"
  "\<turnstile> (\<not>\<not> P) = P"
  "\<turnstile> ((\<not> P) = P) = #False"
  "\<turnstile> (P = (\<not>P)) = #False"
  "\<turnstile> (P \<noteq> Q) = (P = (\<not> Q))"
  "\<turnstile> (#True=P) = P"
  "\<turnstile> (P=#True) = P"
  "\<turnstile> (#True \<longrightarrow> P) = P"
  "\<turnstile> (#False \<longrightarrow> P) = #True"
  "\<turnstile> (P \<longrightarrow> #True) = #True"
  "\<turnstile> (P \<longrightarrow> P) = #True"
  "\<turnstile> (P \<longrightarrow> #False) = (\<not>P)"
  "\<turnstile> (P \<longrightarrow> ~P) = (\<not>P)"
  "\<turnstile> (P \<and> #True) = P"
  "\<turnstile> (#True \<and> P) = P"
  "\<turnstile> (P \<and> #False) = #False"
  "\<turnstile> (#False \<and> P) = #False"
  "\<turnstile> (P \<and> P) = P"
  "\<turnstile> (P \<and> ~P) = #False"
  "\<turnstile> (\<not>P \<and> P) = #False"
  "\<turnstile> (P \<or> #True) = #True"
  "\<turnstile> (#True \<or> P) = #True"
  "\<turnstile> (P \<or> #False) = P"
  "\<turnstile> (#False \<or> P) = P"
  "\<turnstile> (P \<or> P) = P"
  "\<turnstile> (P \<or> \<not>P) = #True"
  "\<turnstile> (\<not>P \<or> P) = #True"
  "\<turnstile> (\<forall> x. P) = P"
  "\<turnstile> (\<exists> x. P) = P"
  by auto

lemmas intensional_simps[simp] = int_simps[THEN inteq_reflection]

method_setup int_rewrite = {* Scan.succeed
  (K (SIMPLE_METHOD ((rewrite_goal_tac @{thms intensional_simps}) 1))) *}
  "rewrite method at intensional level"

lemma Not_Rall: "\<turnstile> (\<not>(\<forall> x. F x)) = (\<exists> x. \<not>F x)"
  by auto

lemma Not_Rex: "\<turnstile> (\<not>(\<exists> x. F x)) = (\<forall> x. \<not>F x)"
  by auto

lemma TrueW [simp]: "\<turnstile> #True"
  by auto

lemma int_eq: "\<turnstile> X = Y \<Longrightarrow> X = Y"
  by (auto simp: inteq_reflection)

lemma int_iffI: 
  assumes "\<turnstile> F \<longrightarrow> G" and "\<turnstile> G \<longrightarrow> F"
  shows "\<turnstile> F = G"
  using assms by force

lemma int_iffD1: assumes h: "\<turnstile> F = G" shows "\<turnstile> F \<longrightarrow> G"
  using h by auto

lemma int_iffD2: assumes h: "\<turnstile> F = G" shows "\<turnstile> G \<longrightarrow> F"
  using h by auto

lemma lift_imp_trans: 
  assumes "\<turnstile> A \<longrightarrow> B" and "\<turnstile> B \<longrightarrow> C"
  shows "\<turnstile> A \<longrightarrow> C"
  using assms by force

lemma lift_imp_neg: assumes "\<turnstile> A \<longrightarrow> B" shows "\<turnstile> \<not>B \<longrightarrow> \<not>A"
  using assms by auto

lemma lift_and_com:  "\<turnstile> (A \<and> B) = (B \<and> A)"
  by auto

end
