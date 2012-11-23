(*  Title:      HOL/Induct/Term.thy
    Author:     Stefan Berghofer,  TU Muenchen
*)

header {* Terms over a given alphabet *}

theory Term
imports Main
begin

datatype ('a, 'b) "term" =
    Var 'a
  | App 'b "('a, 'b) term list"


text {* \medskip Substitution function on terms *}

primrec subst_term :: "('a => ('a, 'b) term) => ('a, 'b) term => ('a, 'b) term"
  and subst_term_list :: "('a => ('a, 'b) term) => ('a, 'b) term list => ('a, 'b) term list"
where
  "subst_term f (Var a) = f a"
| "subst_term f (App b ts) = App b (subst_term_list f ts)"
| "subst_term_list f [] = []"
| "subst_term_list f (t # ts) = subst_term f t # subst_term_list f ts"


text {* \medskip A simple theorem about composition of substitutions *}

lemma subst_comp:
  "subst_term (subst_term f1 \<circ> f2) t =
    subst_term f1 (subst_term f2 t)"
and "subst_term_list (subst_term f1 \<circ> f2) ts =
    subst_term_list f1 (subst_term_list f2 ts)"
  by (induct t and ts) simp_all


text {* \medskip Alternative induction rule *}

lemma
  assumes var: "!!v. P (Var v)"
    and app: "!!f ts. (\<forall>t \<in> set ts. P t) ==> P (App f ts)"
  shows term_induct2: "P t"
    and "\<forall>t \<in> set ts. P t"
  apply (induct t and ts)
     apply (rule var)
    apply (rule app)
    apply assumption
   apply simp_all
  done

end
