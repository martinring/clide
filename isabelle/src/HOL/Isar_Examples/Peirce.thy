(*  Title:      HOL/Isar_Examples/Peirce.thy
    Author:     Markus Wenzel, TU Muenchen
*)

header {* Peirce's Law *}

theory Peirce
imports Main
begin

text {* We consider Peirce's Law: $((A \impl B) \impl A) \impl A$.
  This is an inherently non-intuitionistic statement, so its proof
  will certainly involve some form of classical contradiction.

  The first proof is again a well-balanced combination of plain
  backward and forward reasoning.  The actual classical step is where
  the negated goal may be introduced as additional assumption.  This
  eventually leads to a contradiction.\footnote{The rule involved
  there is negation elimination; it holds in intuitionistic logic as
  well.} *}

theorem "((A --> B) --> A) --> A"
proof
  assume "(A --> B) --> A"
  show A
  proof (rule classical)
    assume "~ A"
    have "A --> B"
    proof
      assume A
      with `~ A` show B by contradiction
    qed
    with `(A --> B) --> A` show A ..
  qed
qed

text {* In the subsequent version the reasoning is rearranged by means
  of ``weak assumptions'' (as introduced by \isacommand{presume}).
  Before assuming the negated goal $\neg A$, its intended consequence
  $A \impl B$ is put into place in order to solve the main problem.
  Nevertheless, we do not get anything for free, but have to establish
  $A \impl B$ later on.  The overall effect is that of a logical
  \emph{cut}.

  Technically speaking, whenever some goal is solved by
  \isacommand{show} in the context of weak assumptions then the latter
  give rise to new subgoals, which may be established separately.  In
  contrast, strong assumptions (as introduced by \isacommand{assume})
  are solved immediately. *}

theorem "((A --> B) --> A) --> A"
proof
  assume "(A --> B) --> A"
  show A
  proof (rule classical)
    presume "A --> B"
    with `(A --> B) --> A` show A ..
  next
    assume "~ A"
    show "A --> B"
    proof
      assume A
      with `~ A` show B by contradiction
    qed
  qed
qed

text {* Note that the goals stemming from weak assumptions may be even
  left until qed time, where they get eventually solved ``by
  assumption'' as well.  In that case there is really no fundamental
  difference between the two kinds of assumptions, apart from the
  order of reducing the individual parts of the proof configuration.

  Nevertheless, the ``strong'' mode of plain assumptions is quite
  important in practice to achieve robustness of proof text
  interpretation.  By forcing both the conclusion \emph{and} the
  assumptions to unify with the pending goal to be solved, goal
  selection becomes quite deterministic.  For example, decomposition
  with rules of the ``case-analysis'' type usually gives rise to
  several goals that only differ in there local contexts.  With strong
  assumptions these may be still solved in any order in a predictable
  way, while weak ones would quickly lead to great confusion,
  eventually demanding even some backtracking. *}

end
