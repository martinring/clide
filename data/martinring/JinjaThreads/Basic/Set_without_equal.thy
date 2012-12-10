(*  Title:      JinjaThreads/Basic/Set_without_equal.thy
    Author:     Andreas Lochbihler
*)

theory Set_without_equal
imports Main
begin

text {*
  Adapt @{type "set"} code setup such that @{const "insert"}, 
  @{const "union"}, and @{term "set_of_pred"} do not generate
  sort constraint @{class equal}.
*}

definition insert' :: "'a \<Rightarrow> 'a set \<Rightarrow> 'a set"
where "insert' = Set.insert"

definition union' :: "'a set \<Rightarrow> 'a set \<Rightarrow> 'a set"
where "union' A B = sup A B"

declare
  insert'_def [symmetric, code_unfold]
  union'_def [symmetric, code_unfold]

lemma insert'_code:
  "insert' x (set xs) = set (x # xs)"
  by (rule set_eqI) (simp add: insert'_def)

lemma union'_code:
  "union' (set xs) (set ys) = set (xs @ ys)"
  by (rule set_eqI) (simp add: union'_def fun_eq_iff)

declare
  insert'_code [code]
  union'_code [code]

text {* Merge name spaces to avoid cyclic module dependencies *}

code_modulename SML
  Set_without_equal Set

code_modulename Haskell
  Set_without_equal Set

code_modulename OCaml
  Set_without_equal Set

end

