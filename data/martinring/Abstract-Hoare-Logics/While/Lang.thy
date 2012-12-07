(*  Title:       A while language
    Author:      Tobias Nipkow, 2001/2006
    Maintainer:  Tobias Nipkow
*)

header "Hoare Logics for While"

theory Lang imports Main begin

subsection{* The language \label{sec:lang} *}

text{* We start by declaring a type of states: *}

typedecl state

text{*\noindent
Our approach is completely parametric in the state space.
We define expressions (@{text bexp}) as functions from states
to the booleans: *}

type_synonym bexp = "state \<Rightarrow> bool"

text{*
Instead of modelling the syntax of boolean expressions, we
model their semantics. The (abstract and concrete)
syntax of our programming is defined as a recursive datatype:
*}

datatype com = Do "(state \<Rightarrow> state set)"
             | Semi  com com            ("_; _"  [60, 60] 10)
             | Cond  bexp com com     ("IF _ THEN _ ELSE _"  60)
             | While bexp com           ("WHILE _ DO _"  60)
             | Local "(state \<Rightarrow> state)" com "(state \<Rightarrow> state \<Rightarrow> state)"
               ("LOCAL _; _; _" [0,0,60] 60)

text{*\noindent Statements in this language are called
\emph{commands}.  They are modelled as terms of type @{typ
com}. @{term"Do f"} represents an atomic nondeterministic command that
changes the state from @{term s} to some element of @{term"f s"}.
Thus the command that does nothing, often called \texttt{skip}, can be
represented by @{term"Do(\<lambda>s. {s})"}. Again we have chosen to model the
semantics rather than the syntax, which simplifies matters
enormously. Of course it means that we can no longer talk about
certain syntactic matters, but that is just fine.

The constructors @{term Semi}, @{term Cond} and @{term While}
represent sequential composition, conditional and while-loop.
The annotations allow us to write
\begin{center}
@{term"c\<^isub>1;c\<^isub>2"} \qquad @{term"IF b THEN c\<^isub>1 ELSE c\<^isub>2"}
 \qquad @{term"WHILE b DO c"}
\end{center}
instead of @{term[source]"Semi c\<^isub>1 c\<^isub>2"}, @{term[source]"Cond b c\<^isub>1 c\<^isub>2"}
and @{term[source]"While b c"}.

The command @{term"LOCAL f;c;g"} applies function @{text f} to the state,
executes @{term c}, and then combines initial and final state via function
@{text g}. More below.
The semantics of commands is defined inductively by a so-called
big-step semantics.*}

inductive
  exec :: "state \<Rightarrow> com \<Rightarrow> state \<Rightarrow> bool" ("_/ -_\<rightarrow>/ _" [50,0,50] 50)
where
  (*<*)Do:(*>*)"t \<in> f s \<Longrightarrow> s -Do f\<rightarrow> t"

| (*<*)Semi:(*>*)"\<lbrakk> s0 -c1\<rightarrow> s1; s1 -c2\<rightarrow> s2 \<rbrakk> \<Longrightarrow> s0 -c1;c2\<rightarrow> s2"

| (*<*)IfT:(*>*)"\<lbrakk>  b s; s -c1\<rightarrow> t \<rbrakk> \<Longrightarrow> s -IF b THEN c1 ELSE c2\<rightarrow> t"
| (*<*)IfF:(*>*)"\<lbrakk> \<not>b s; s -c2\<rightarrow> t \<rbrakk> \<Longrightarrow> s -IF b THEN c1 ELSE c2\<rightarrow> t"

| (*<*)WhileF:(*>*)"\<not>b s \<Longrightarrow> s -WHILE b DO c\<rightarrow> s"
| (*<*)WhileT:(*>*)"\<lbrakk> b s; s -c\<rightarrow> t; t -WHILE b DO c\<rightarrow> u \<rbrakk> \<Longrightarrow> s -WHILE b DO c\<rightarrow> u"

| (*<*)Local:(*>*) "f s -c\<rightarrow> t \<Longrightarrow> s -LOCAL f; c; g\<rightarrow> g s t"

text{* Assuming that the state is a function from variables to values,
the declaration of a new local variable @{text x} with inital value
@{text a} can be modelled as
@{text"LOCAL (\<lambda>s. s(x := a s)); c; (\<lambda>s t. t(x := s x))"}. *}

lemma exec_Do_iff[iff]: "(s -Do f\<rightarrow> t) = (t \<in> f s)"
by(auto elim: exec.cases intro:exec.intros)

lemma [iff]: "(s -c;d\<rightarrow> u) = (\<exists>t. s -c\<rightarrow> t \<and> t -d\<rightarrow> u)"
by(best elim: exec.cases intro:exec.intros)

lemma [iff]: "(s -IF b THEN c ELSE d\<rightarrow> t) =
              (s -if b s then c else d\<rightarrow> t)"
apply auto
apply(blast elim: exec.cases intro:exec.intros)+
done

lemma [iff]: "(s -LOCAL f; c; g\<rightarrow> u) = (\<exists>t. f s -c\<rightarrow> t \<and> u = g s t)"
by(fastforce elim: exec.cases intro:exec.intros)

lemma unfold_while:
 "(s -WHILE b DO c\<rightarrow> u) =
  (s -IF b THEN c;WHILE b DO c ELSE Do(\<lambda>s. {s})\<rightarrow> u)"
by(auto elim: exec.cases intro:exec.intros split:split_if_asm)


lemma while_lemma[rule_format]:
"s -w\<rightarrow> t \<Longrightarrow> !b c. w = WHILE b DO c \<and> P s \<and>
                    (!s s'. P s \<and> b s \<and> s -c\<rightarrow> s' \<longrightarrow> P s') \<longrightarrow> P t \<and> \<not>b t"
apply(erule exec.induct)
apply clarify+
defer
apply clarify+
apply(subgoal_tac "P t")
apply blast
apply blast
done

lemma while_rule:
 "\<lbrakk>s -WHILE b DO c\<rightarrow> t; P s; \<forall>s s'. P s \<and> b s \<and> s -c\<rightarrow> s' \<longrightarrow> P s'\<rbrakk>
  \<Longrightarrow> P t \<and> \<not>b t"
apply(drule while_lemma)
prefer 2 apply assumption
apply blast
done

end
