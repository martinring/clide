(*  Title:      ZF/Induct/Ntree.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1994  University of Cambridge
*)

header {* Datatype definition n-ary branching trees *}

theory Ntree imports Main begin

text {*
  Demonstrates a simple use of function space in a datatype
  definition.  Based upon theory @{text Term}.
*}

consts
  ntree :: "i => i"
  maptree :: "i => i"
  maptree2 :: "[i, i] => i"

datatype "ntree(A)" = Branch ("a \<in> A", "h \<in> (\<Union>n \<in> nat. n -> ntree(A))")
  monos UN_mono [OF subset_refl Pi_mono]  -- {* MUST have this form *}
  type_intros nat_fun_univ [THEN subsetD]
  type_elims UN_E

datatype "maptree(A)" = Sons ("a \<in> A", "h \<in> maptree(A) -||> maptree(A)")
  monos FiniteFun_mono1  -- {* Use monotonicity in BOTH args *}
  type_intros FiniteFun_univ1 [THEN subsetD]

datatype "maptree2(A, B)" = Sons2 ("a \<in> A", "h \<in> B -||> maptree2(A, B)")
  monos FiniteFun_mono [OF subset_refl]
  type_intros FiniteFun_in_univ'

definition
  ntree_rec :: "[[i, i, i] => i, i] => i"  where
  "ntree_rec(b) ==
    Vrecursor(\<lambda>pr. ntree_case(\<lambda>x h. b(x, h, \<lambda>i \<in> domain(h). pr`(h`i))))"

definition
  ntree_copy :: "i => i"  where
  "ntree_copy(z) == ntree_rec(\<lambda>x h r. Branch(x,r), z)"


text {*
  \medskip @{text ntree}
*}

lemma ntree_unfold: "ntree(A) = A \<times> (\<Union>n \<in> nat. n -> ntree(A))"
  by (blast intro: ntree.intros [unfolded ntree.con_defs]
    elim: ntree.cases [unfolded ntree.con_defs])

lemma ntree_induct [consumes 1, case_names Branch, induct set: ntree]:
  assumes t: "t \<in> ntree(A)"
    and step: "!!x n h. [| x \<in> A;  n \<in> nat;  h \<in> n -> ntree(A);  \<forall>i \<in> n. P(h`i)
      |] ==> P(Branch(x,h))"
  shows "P(t)"
  -- {* A nicer induction rule than the standard one. *}
  using t
  apply induct
  apply (erule UN_E)
  apply (assumption | rule step)+
   apply (fast elim: fun_weaken_type)
  apply (fast dest: apply_type)
  done

lemma ntree_induct_eqn [consumes 1]:
  assumes t: "t \<in> ntree(A)"
    and f: "f \<in> ntree(A)->B"
    and g: "g \<in> ntree(A)->B"
    and step: "!!x n h. [| x \<in> A;  n \<in> nat;  h \<in> n -> ntree(A);  f O h = g O h |] ==>
      f ` Branch(x,h) = g ` Branch(x,h)"
  shows "f`t=g`t"
  -- {* Induction on @{term "ntree(A)"} to prove an equation *}
  using t
  apply induct
  apply (assumption | rule step)+
  apply (insert f g)
  apply (rule fun_extension)
  apply (assumption | rule comp_fun)+
  apply (simp add: comp_fun_apply)
  done

text {*
  \medskip Lemmas to justify using @{text Ntree} in other recursive
  type definitions.
*}

lemma ntree_mono: "A \<subseteq> B ==> ntree(A) \<subseteq> ntree(B)"
  apply (unfold ntree.defs)
  apply (rule lfp_mono)
    apply (rule ntree.bnd_mono)+
  apply (assumption | rule univ_mono basic_monos)+
  done

lemma ntree_univ: "ntree(univ(A)) \<subseteq> univ(A)"
  -- {* Easily provable by induction also *}
  apply (unfold ntree.defs ntree.con_defs)
  apply (rule lfp_lowerbound)
   apply (rule_tac [2] A_subset_univ [THEN univ_mono])
  apply (blast intro: Pair_in_univ nat_fun_univ [THEN subsetD])
  done

lemma ntree_subset_univ: "A \<subseteq> univ(B) ==> ntree(A) \<subseteq> univ(B)"
  by (rule subset_trans [OF ntree_mono ntree_univ])


text {*
  \medskip @{text ntree} recursion.
*}

lemma ntree_rec_Branch:
    "function(h) ==>
     ntree_rec(b, Branch(x,h)) = b(x, h, \<lambda>i \<in> domain(h). ntree_rec(b, h`i))"
  apply (rule ntree_rec_def [THEN def_Vrecursor, THEN trans])
  apply (simp add: ntree.con_defs rank_pair2 [THEN [2] lt_trans] rank_apply)
  done

lemma ntree_copy_Branch [simp]:
    "function(h) ==>
     ntree_copy (Branch(x, h)) = Branch(x, \<lambda>i \<in> domain(h). ntree_copy (h`i))"
  by (simp add: ntree_copy_def ntree_rec_Branch)

lemma ntree_copy_is_ident: "z \<in> ntree(A) ==> ntree_copy(z) = z"
  by (induct z set: ntree)
    (auto simp add: domain_of_fun Pi_Collect_iff fun_is_function)


text {*
  \medskip @{text maptree}
*}

lemma maptree_unfold: "maptree(A) = A \<times> (maptree(A) -||> maptree(A))"
  by (fast intro!: maptree.intros [unfolded maptree.con_defs]
    elim: maptree.cases [unfolded maptree.con_defs])

lemma maptree_induct [consumes 1, induct set: maptree]:
  assumes t: "t \<in> maptree(A)"
    and step: "!!x n h. [| x \<in> A;  h \<in> maptree(A) -||> maptree(A);
                  \<forall>y \<in> field(h). P(y)
               |] ==> P(Sons(x,h))"
  shows "P(t)"
  -- {* A nicer induction rule than the standard one. *}
  using t
  apply induct
  apply (assumption | rule step)+
  apply (erule Collect_subset [THEN FiniteFun_mono1, THEN subsetD])
  apply (drule FiniteFun.dom_subset [THEN subsetD])
  apply (drule Fin.dom_subset [THEN subsetD])
  apply fast
  done


text {*
  \medskip @{text maptree2}
*}

lemma maptree2_unfold: "maptree2(A, B) = A \<times> (B -||> maptree2(A, B))"
  by (fast intro!: maptree2.intros [unfolded maptree2.con_defs]
    elim: maptree2.cases [unfolded maptree2.con_defs])

lemma maptree2_induct [consumes 1, induct set: maptree2]:
  assumes t: "t \<in> maptree2(A, B)"
    and step: "!!x n h. [| x \<in> A;  h \<in> B -||> maptree2(A,B);  \<forall>y \<in> range(h). P(y)
               |] ==> P(Sons2(x,h))"
  shows "P(t)"
  using t
  apply induct
  apply (assumption | rule step)+
   apply (erule FiniteFun_mono [OF subset_refl Collect_subset, THEN subsetD])
   apply (drule FiniteFun.dom_subset [THEN subsetD])
   apply (drule Fin.dom_subset [THEN subsetD])
   apply fast
   done

end
