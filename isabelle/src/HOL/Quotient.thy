(*  Title:      HOL/Quotient.thy
    Author:     Cezary Kaliszyk and Christian Urban
*)

header {* Definition of Quotient Types *}

theory Quotient
imports Plain Hilbert_Choice Equiv_Relations Lifting
keywords
  "print_quotmapsQ3" "print_quotientsQ3" "print_quotconsts" :: diag and
  "quotient_type" :: thy_goal and "/" and
  "quotient_definition" :: thy_goal
uses
  ("Tools/Quotient/quotient_info.ML")
  ("Tools/Quotient/quotient_type.ML")
  ("Tools/Quotient/quotient_def.ML")
  ("Tools/Quotient/quotient_term.ML")
  ("Tools/Quotient/quotient_tacs.ML")
begin

text {*
  Basic definition for equivalence relations
  that are represented by predicates.
*}

text {* Composition of Relations *}

abbreviation
  rel_conj :: "('a \<Rightarrow> 'b \<Rightarrow> bool) \<Rightarrow> ('b \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a \<Rightarrow> 'b \<Rightarrow> bool" (infixr "OOO" 75)
where
  "r1 OOO r2 \<equiv> r1 OO r2 OO r1"

lemma eq_comp_r:
  shows "((op =) OOO R) = R"
  by (auto simp add: fun_eq_iff)

subsection {* Quotient Predicate *}

definition
  "Quotient3 R Abs Rep \<longleftrightarrow>
     (\<forall>a. Abs (Rep a) = a) \<and> (\<forall>a. R (Rep a) (Rep a)) \<and>
     (\<forall>r s. R r s \<longleftrightarrow> R r r \<and> R s s \<and> Abs r = Abs s)"

lemma Quotient3I:
  assumes "\<And>a. Abs (Rep a) = a"
    and "\<And>a. R (Rep a) (Rep a)"
    and "\<And>r s. R r s \<longleftrightarrow> R r r \<and> R s s \<and> Abs r = Abs s"
  shows "Quotient3 R Abs Rep"
  using assms unfolding Quotient3_def by blast

lemma Quotient3_abs_rep:
  assumes a: "Quotient3 R Abs Rep"
  shows "Abs (Rep a) = a"
  using a
  unfolding Quotient3_def
  by simp

lemma Quotient3_rep_reflp:
  assumes a: "Quotient3 R Abs Rep"
  shows "R (Rep a) (Rep a)"
  using a
  unfolding Quotient3_def
  by blast

lemma Quotient3_rel:
  assumes a: "Quotient3 R Abs Rep"
  shows "R r r \<and> R s s \<and> Abs r = Abs s \<longleftrightarrow> R r s" -- {* orientation does not loop on rewriting *}
  using a
  unfolding Quotient3_def
  by blast

lemma Quotient3_refl1: 
  assumes a: "Quotient3 R Abs Rep" 
  shows "R r s \<Longrightarrow> R r r"
  using a unfolding Quotient3_def 
  by fast

lemma Quotient3_refl2: 
  assumes a: "Quotient3 R Abs Rep" 
  shows "R r s \<Longrightarrow> R s s"
  using a unfolding Quotient3_def 
  by fast

lemma Quotient3_rel_rep:
  assumes a: "Quotient3 R Abs Rep"
  shows "R (Rep a) (Rep b) \<longleftrightarrow> a = b"
  using a
  unfolding Quotient3_def
  by metis

lemma Quotient3_rep_abs:
  assumes a: "Quotient3 R Abs Rep"
  shows "R r r \<Longrightarrow> R (Rep (Abs r)) r"
  using a unfolding Quotient3_def
  by blast

lemma Quotient3_rel_abs:
  assumes a: "Quotient3 R Abs Rep"
  shows "R r s \<Longrightarrow> Abs r = Abs s"
  using a unfolding Quotient3_def
  by blast

lemma Quotient3_symp:
  assumes a: "Quotient3 R Abs Rep"
  shows "symp R"
  using a unfolding Quotient3_def using sympI by metis

lemma Quotient3_transp:
  assumes a: "Quotient3 R Abs Rep"
  shows "transp R"
  using a unfolding Quotient3_def using transpI by (metis (full_types))

lemma Quotient3_part_equivp:
  assumes a: "Quotient3 R Abs Rep"
  shows "part_equivp R"
by (metis Quotient3_rep_reflp Quotient3_symp Quotient3_transp a part_equivpI)

lemma identity_quotient3:
  shows "Quotient3 (op =) id id"
  unfolding Quotient3_def id_def
  by blast

lemma fun_quotient3:
  assumes q1: "Quotient3 R1 abs1 rep1"
  and     q2: "Quotient3 R2 abs2 rep2"
  shows "Quotient3 (R1 ===> R2) (rep1 ---> abs2) (abs1 ---> rep2)"
proof -
  have "\<And>a.(rep1 ---> abs2) ((abs1 ---> rep2) a) = a"
    using q1 q2 by (simp add: Quotient3_def fun_eq_iff)
  moreover
  have "\<And>a.(R1 ===> R2) ((abs1 ---> rep2) a) ((abs1 ---> rep2) a)"
    by (rule fun_relI)
      (insert q1 q2 Quotient3_rel_abs [of R1 abs1 rep1] Quotient3_rel_rep [of R2 abs2 rep2],
        simp (no_asm) add: Quotient3_def, simp)
  
  moreover
  {
  fix r s
  have "(R1 ===> R2) r s = ((R1 ===> R2) r r \<and> (R1 ===> R2) s s \<and>
        (rep1 ---> abs2) r  = (rep1 ---> abs2) s)"
  proof -
    
    have "(R1 ===> R2) r s \<Longrightarrow> (R1 ===> R2) r r" unfolding fun_rel_def
      using Quotient3_part_equivp[OF q1] Quotient3_part_equivp[OF q2] 
      by (metis (full_types) part_equivp_def)
    moreover have "(R1 ===> R2) r s \<Longrightarrow> (R1 ===> R2) s s" unfolding fun_rel_def
      using Quotient3_part_equivp[OF q1] Quotient3_part_equivp[OF q2] 
      by (metis (full_types) part_equivp_def)
    moreover have "(R1 ===> R2) r s \<Longrightarrow> (rep1 ---> abs2) r  = (rep1 ---> abs2) s"
      apply(auto simp add: fun_rel_def fun_eq_iff) using q1 q2 unfolding Quotient3_def by metis
    moreover have "((R1 ===> R2) r r \<and> (R1 ===> R2) s s \<and>
        (rep1 ---> abs2) r  = (rep1 ---> abs2) s) \<Longrightarrow> (R1 ===> R2) r s"
      apply(auto simp add: fun_rel_def fun_eq_iff) using q1 q2 unfolding Quotient3_def 
    by (metis map_fun_apply)
  
    ultimately show ?thesis by blast
 qed
 }
 ultimately show ?thesis by (intro Quotient3I) (assumption+)
qed

lemma abs_o_rep:
  assumes a: "Quotient3 R Abs Rep"
  shows "Abs o Rep = id"
  unfolding fun_eq_iff
  by (simp add: Quotient3_abs_rep[OF a])

lemma equals_rsp:
  assumes q: "Quotient3 R Abs Rep"
  and     a: "R xa xb" "R ya yb"
  shows "R xa ya = R xb yb"
  using a Quotient3_symp[OF q] Quotient3_transp[OF q]
  by (blast elim: sympE transpE)

lemma lambda_prs:
  assumes q1: "Quotient3 R1 Abs1 Rep1"
  and     q2: "Quotient3 R2 Abs2 Rep2"
  shows "(Rep1 ---> Abs2) (\<lambda>x. Rep2 (f (Abs1 x))) = (\<lambda>x. f x)"
  unfolding fun_eq_iff
  using Quotient3_abs_rep[OF q1] Quotient3_abs_rep[OF q2]
  by simp

lemma lambda_prs1:
  assumes q1: "Quotient3 R1 Abs1 Rep1"
  and     q2: "Quotient3 R2 Abs2 Rep2"
  shows "(Rep1 ---> Abs2) (\<lambda>x. (Abs1 ---> Rep2) f x) = (\<lambda>x. f x)"
  unfolding fun_eq_iff
  using Quotient3_abs_rep[OF q1] Quotient3_abs_rep[OF q2]
  by simp

lemma rep_abs_rsp:
  assumes q: "Quotient3 R Abs Rep"
  and     a: "R x1 x2"
  shows "R x1 (Rep (Abs x2))"
  using a Quotient3_rel[OF q] Quotient3_abs_rep[OF q] Quotient3_rep_reflp[OF q]
  by metis

lemma rep_abs_rsp_left:
  assumes q: "Quotient3 R Abs Rep"
  and     a: "R x1 x2"
  shows "R (Rep (Abs x1)) x2"
  using a Quotient3_rel[OF q] Quotient3_abs_rep[OF q] Quotient3_rep_reflp[OF q]
  by metis

text{*
  In the following theorem R1 can be instantiated with anything,
  but we know some of the types of the Rep and Abs functions;
  so by solving Quotient assumptions we can get a unique R1 that
  will be provable; which is why we need to use @{text apply_rsp} and
  not the primed version *}

lemma apply_rspQ3:
  fixes f g::"'a \<Rightarrow> 'c"
  assumes q: "Quotient3 R1 Abs1 Rep1"
  and     a: "(R1 ===> R2) f g" "R1 x y"
  shows "R2 (f x) (g y)"
  using a by (auto elim: fun_relE)

lemma apply_rspQ3'':
  assumes "Quotient3 R Abs Rep"
  and "(R ===> S) f f"
  shows "S (f (Rep x)) (f (Rep x))"
proof -
  from assms(1) have "R (Rep x) (Rep x)" by (rule Quotient3_rep_reflp)
  then show ?thesis using assms(2) by (auto intro: apply_rsp')
qed

subsection {* lemmas for regularisation of ball and bex *}

lemma ball_reg_eqv:
  fixes P :: "'a \<Rightarrow> bool"
  assumes a: "equivp R"
  shows "Ball (Respects R) P = (All P)"
  using a
  unfolding equivp_def
  by (auto simp add: in_respects)

lemma bex_reg_eqv:
  fixes P :: "'a \<Rightarrow> bool"
  assumes a: "equivp R"
  shows "Bex (Respects R) P = (Ex P)"
  using a
  unfolding equivp_def
  by (auto simp add: in_respects)

lemma ball_reg_right:
  assumes a: "\<And>x. x \<in> R \<Longrightarrow> P x \<longrightarrow> Q x"
  shows "All P \<longrightarrow> Ball R Q"
  using a by fast

lemma bex_reg_left:
  assumes a: "\<And>x. x \<in> R \<Longrightarrow> Q x \<longrightarrow> P x"
  shows "Bex R Q \<longrightarrow> Ex P"
  using a by fast

lemma ball_reg_left:
  assumes a: "equivp R"
  shows "(\<And>x. (Q x \<longrightarrow> P x)) \<Longrightarrow> Ball (Respects R) Q \<longrightarrow> All P"
  using a by (metis equivp_reflp in_respects)

lemma bex_reg_right:
  assumes a: "equivp R"
  shows "(\<And>x. (Q x \<longrightarrow> P x)) \<Longrightarrow> Ex Q \<longrightarrow> Bex (Respects R) P"
  using a by (metis equivp_reflp in_respects)

lemma ball_reg_eqv_range:
  fixes P::"'a \<Rightarrow> bool"
  and x::"'a"
  assumes a: "equivp R2"
  shows   "(Ball (Respects (R1 ===> R2)) (\<lambda>f. P (f x)) = All (\<lambda>f. P (f x)))"
  apply(rule iffI)
  apply(rule allI)
  apply(drule_tac x="\<lambda>y. f x" in bspec)
  apply(simp add: in_respects fun_rel_def)
  apply(rule impI)
  using a equivp_reflp_symp_transp[of "R2"]
  apply (auto elim: equivpE reflpE)
  done

lemma bex_reg_eqv_range:
  assumes a: "equivp R2"
  shows   "(Bex (Respects (R1 ===> R2)) (\<lambda>f. P (f x)) = Ex (\<lambda>f. P (f x)))"
  apply(auto)
  apply(rule_tac x="\<lambda>y. f x" in bexI)
  apply(simp)
  apply(simp add: Respects_def in_respects fun_rel_def)
  apply(rule impI)
  using a equivp_reflp_symp_transp[of "R2"]
  apply (auto elim: equivpE reflpE)
  done

(* Next four lemmas are unused *)
lemma all_reg:
  assumes a: "!x :: 'a. (P x --> Q x)"
  and     b: "All P"
  shows "All Q"
  using a b by fast

lemma ex_reg:
  assumes a: "!x :: 'a. (P x --> Q x)"
  and     b: "Ex P"
  shows "Ex Q"
  using a b by fast

lemma ball_reg:
  assumes a: "!x :: 'a. (x \<in> R --> P x --> Q x)"
  and     b: "Ball R P"
  shows "Ball R Q"
  using a b by fast

lemma bex_reg:
  assumes a: "!x :: 'a. (x \<in> R --> P x --> Q x)"
  and     b: "Bex R P"
  shows "Bex R Q"
  using a b by fast


lemma ball_all_comm:
  assumes "\<And>y. (\<forall>x\<in>P. A x y) \<longrightarrow> (\<forall>x. B x y)"
  shows "(\<forall>x\<in>P. \<forall>y. A x y) \<longrightarrow> (\<forall>x. \<forall>y. B x y)"
  using assms by auto

lemma bex_ex_comm:
  assumes "(\<exists>y. \<exists>x. A x y) \<longrightarrow> (\<exists>y. \<exists>x\<in>P. B x y)"
  shows "(\<exists>x. \<exists>y. A x y) \<longrightarrow> (\<exists>x\<in>P. \<exists>y. B x y)"
  using assms by auto

subsection {* Bounded abstraction *}

definition
  Babs :: "'a set \<Rightarrow> ('a \<Rightarrow> 'b) \<Rightarrow> 'a \<Rightarrow> 'b"
where
  "x \<in> p \<Longrightarrow> Babs p m x = m x"

lemma babs_rsp:
  assumes q: "Quotient3 R1 Abs1 Rep1"
  and     a: "(R1 ===> R2) f g"
  shows      "(R1 ===> R2) (Babs (Respects R1) f) (Babs (Respects R1) g)"
  apply (auto simp add: Babs_def in_respects fun_rel_def)
  apply (subgoal_tac "x \<in> Respects R1 \<and> y \<in> Respects R1")
  using a apply (simp add: Babs_def fun_rel_def)
  apply (simp add: in_respects fun_rel_def)
  using Quotient3_rel[OF q]
  by metis

lemma babs_prs:
  assumes q1: "Quotient3 R1 Abs1 Rep1"
  and     q2: "Quotient3 R2 Abs2 Rep2"
  shows "((Rep1 ---> Abs2) (Babs (Respects R1) ((Abs1 ---> Rep2) f))) = f"
  apply (rule ext)
  apply (simp add:)
  apply (subgoal_tac "Rep1 x \<in> Respects R1")
  apply (simp add: Babs_def Quotient3_abs_rep[OF q1] Quotient3_abs_rep[OF q2])
  apply (simp add: in_respects Quotient3_rel_rep[OF q1])
  done

lemma babs_simp:
  assumes q: "Quotient3 R1 Abs Rep"
  shows "((R1 ===> R2) (Babs (Respects R1) f) (Babs (Respects R1) g)) = ((R1 ===> R2) f g)"
  apply(rule iffI)
  apply(simp_all only: babs_rsp[OF q])
  apply(auto simp add: Babs_def fun_rel_def)
  apply (subgoal_tac "x \<in> Respects R1 \<and> y \<in> Respects R1")
  apply(metis Babs_def)
  apply (simp add: in_respects)
  using Quotient3_rel[OF q]
  by metis

(* If a user proves that a particular functional relation
   is an equivalence this may be useful in regularising *)
lemma babs_reg_eqv:
  shows "equivp R \<Longrightarrow> Babs (Respects R) P = P"
  by (simp add: fun_eq_iff Babs_def in_respects equivp_reflp)


(* 3 lemmas needed for proving repabs_inj *)
lemma ball_rsp:
  assumes a: "(R ===> (op =)) f g"
  shows "Ball (Respects R) f = Ball (Respects R) g"
  using a by (auto simp add: Ball_def in_respects elim: fun_relE)

lemma bex_rsp:
  assumes a: "(R ===> (op =)) f g"
  shows "(Bex (Respects R) f = Bex (Respects R) g)"
  using a by (auto simp add: Bex_def in_respects elim: fun_relE)

lemma bex1_rsp:
  assumes a: "(R ===> (op =)) f g"
  shows "Ex1 (\<lambda>x. x \<in> Respects R \<and> f x) = Ex1 (\<lambda>x. x \<in> Respects R \<and> g x)"
  using a by (auto elim: fun_relE simp add: Ex1_def in_respects) 

(* 2 lemmas needed for cleaning of quantifiers *)
lemma all_prs:
  assumes a: "Quotient3 R absf repf"
  shows "Ball (Respects R) ((absf ---> id) f) = All f"
  using a unfolding Quotient3_def Ball_def in_respects id_apply comp_def map_fun_def
  by metis

lemma ex_prs:
  assumes a: "Quotient3 R absf repf"
  shows "Bex (Respects R) ((absf ---> id) f) = Ex f"
  using a unfolding Quotient3_def Bex_def in_respects id_apply comp_def map_fun_def
  by metis

subsection {* @{text Bex1_rel} quantifier *}

definition
  Bex1_rel :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool"
where
  "Bex1_rel R P \<longleftrightarrow> (\<exists>x \<in> Respects R. P x) \<and> (\<forall>x \<in> Respects R. \<forall>y \<in> Respects R. ((P x \<and> P y) \<longrightarrow> (R x y)))"

lemma bex1_rel_aux:
  "\<lbrakk>\<forall>xa ya. R xa ya \<longrightarrow> x xa = y ya; Bex1_rel R x\<rbrakk> \<Longrightarrow> Bex1_rel R y"
  unfolding Bex1_rel_def
  apply (erule conjE)+
  apply (erule bexE)
  apply rule
  apply (rule_tac x="xa" in bexI)
  apply metis
  apply metis
  apply rule+
  apply (erule_tac x="xaa" in ballE)
  prefer 2
  apply (metis)
  apply (erule_tac x="ya" in ballE)
  prefer 2
  apply (metis)
  apply (metis in_respects)
  done

lemma bex1_rel_aux2:
  "\<lbrakk>\<forall>xa ya. R xa ya \<longrightarrow> x xa = y ya; Bex1_rel R y\<rbrakk> \<Longrightarrow> Bex1_rel R x"
  unfolding Bex1_rel_def
  apply (erule conjE)+
  apply (erule bexE)
  apply rule
  apply (rule_tac x="xa" in bexI)
  apply metis
  apply metis
  apply rule+
  apply (erule_tac x="xaa" in ballE)
  prefer 2
  apply (metis)
  apply (erule_tac x="ya" in ballE)
  prefer 2
  apply (metis)
  apply (metis in_respects)
  done

lemma bex1_rel_rsp:
  assumes a: "Quotient3 R absf repf"
  shows "((R ===> op =) ===> op =) (Bex1_rel R) (Bex1_rel R)"
  apply (simp add: fun_rel_def)
  apply clarify
  apply rule
  apply (simp_all add: bex1_rel_aux bex1_rel_aux2)
  apply (erule bex1_rel_aux2)
  apply assumption
  done


lemma ex1_prs:
  assumes a: "Quotient3 R absf repf"
  shows "((absf ---> id) ---> id) (Bex1_rel R) f = Ex1 f"
apply (simp add:)
apply (subst Bex1_rel_def)
apply (subst Bex_def)
apply (subst Ex1_def)
apply simp
apply rule
 apply (erule conjE)+
 apply (erule_tac exE)
 apply (erule conjE)
 apply (subgoal_tac "\<forall>y. R y y \<longrightarrow> f (absf y) \<longrightarrow> R x y")
  apply (rule_tac x="absf x" in exI)
  apply (simp)
  apply rule+
  using a unfolding Quotient3_def
  apply metis
 apply rule+
 apply (erule_tac x="x" in ballE)
  apply (erule_tac x="y" in ballE)
   apply simp
  apply (simp add: in_respects)
 apply (simp add: in_respects)
apply (erule_tac exE)
 apply rule
 apply (rule_tac x="repf x" in exI)
 apply (simp only: in_respects)
  apply rule
 apply (metis Quotient3_rel_rep[OF a])
using a unfolding Quotient3_def apply (simp)
apply rule+
using a unfolding Quotient3_def in_respects
apply metis
done

lemma bex1_bexeq_reg:
  shows "(\<exists>!x\<in>Respects R. P x) \<longrightarrow> (Bex1_rel R (\<lambda>x. P x))"
  apply (simp add: Ex1_def Bex1_rel_def in_respects)
  apply clarify
  apply auto
  apply (rule bexI)
  apply assumption
  apply (simp add: in_respects)
  apply (simp add: in_respects)
  apply auto
  done

lemma bex1_bexeq_reg_eqv:
  assumes a: "equivp R"
  shows "(\<exists>!x. P x) \<longrightarrow> Bex1_rel R P"
  using equivp_reflp[OF a]
  apply (intro impI)
  apply (elim ex1E)
  apply (rule mp[OF bex1_bexeq_reg])
  apply (rule_tac a="x" in ex1I)
  apply (subst in_respects)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply clarify
  apply (erule_tac x="xa" in allE)
  apply simp
  done

subsection {* Various respects and preserve lemmas *}

lemma quot_rel_rsp:
  assumes a: "Quotient3 R Abs Rep"
  shows "(R ===> R ===> op =) R R"
  apply(rule fun_relI)+
  apply(rule equals_rsp[OF a])
  apply(assumption)+
  done

lemma o_prs:
  assumes q1: "Quotient3 R1 Abs1 Rep1"
  and     q2: "Quotient3 R2 Abs2 Rep2"
  and     q3: "Quotient3 R3 Abs3 Rep3"
  shows "((Abs2 ---> Rep3) ---> (Abs1 ---> Rep2) ---> (Rep1 ---> Abs3)) op \<circ> = op \<circ>"
  and   "(id ---> (Abs1 ---> id) ---> Rep1 ---> id) op \<circ> = op \<circ>"
  using Quotient3_abs_rep[OF q1] Quotient3_abs_rep[OF q2] Quotient3_abs_rep[OF q3]
  by (simp_all add: fun_eq_iff)

lemma o_rsp:
  "((R2 ===> R3) ===> (R1 ===> R2) ===> (R1 ===> R3)) op \<circ> op \<circ>"
  "(op = ===> (R1 ===> op =) ===> R1 ===> op =) op \<circ> op \<circ>"
  by (force elim: fun_relE)+

lemma cond_prs:
  assumes a: "Quotient3 R absf repf"
  shows "absf (if a then repf b else repf c) = (if a then b else c)"
  using a unfolding Quotient3_def by auto

lemma if_prs:
  assumes q: "Quotient3 R Abs Rep"
  shows "(id ---> Rep ---> Rep ---> Abs) If = If"
  using Quotient3_abs_rep[OF q]
  by (auto simp add: fun_eq_iff)

lemma if_rsp:
  assumes q: "Quotient3 R Abs Rep"
  shows "(op = ===> R ===> R ===> R) If If"
  by force

lemma let_prs:
  assumes q1: "Quotient3 R1 Abs1 Rep1"
  and     q2: "Quotient3 R2 Abs2 Rep2"
  shows "(Rep2 ---> (Abs2 ---> Rep1) ---> Abs1) Let = Let"
  using Quotient3_abs_rep[OF q1] Quotient3_abs_rep[OF q2]
  by (auto simp add: fun_eq_iff)

lemma let_rsp:
  shows "(R1 ===> (R1 ===> R2) ===> R2) Let Let"
  by (force elim: fun_relE)

lemma id_rsp:
  shows "(R ===> R) id id"
  by auto

lemma id_prs:
  assumes a: "Quotient3 R Abs Rep"
  shows "(Rep ---> Abs) id = id"
  by (simp add: fun_eq_iff Quotient3_abs_rep [OF a])


locale quot_type =
  fixes R :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  and   Abs :: "'a set \<Rightarrow> 'b"
  and   Rep :: "'b \<Rightarrow> 'a set"
  assumes equivp: "part_equivp R"
  and     rep_prop: "\<And>y. \<exists>x. R x x \<and> Rep y = Collect (R x)"
  and     rep_inverse: "\<And>x. Abs (Rep x) = x"
  and     abs_inverse: "\<And>c. (\<exists>x. ((R x x) \<and> (c = Collect (R x)))) \<Longrightarrow> (Rep (Abs c)) = c"
  and     rep_inject: "\<And>x y. (Rep x = Rep y) = (x = y)"
begin

definition
  abs :: "'a \<Rightarrow> 'b"
where
  "abs x = Abs (Collect (R x))"

definition
  rep :: "'b \<Rightarrow> 'a"
where
  "rep a = (SOME x. x \<in> Rep a)"

lemma some_collect:
  assumes "R r r"
  shows "R (SOME x. x \<in> Collect (R r)) = R r"
  apply simp
  by (metis assms exE_some equivp[simplified part_equivp_def])

lemma Quotient:
  shows "Quotient3 R abs rep"
  unfolding Quotient3_def abs_def rep_def
  proof (intro conjI allI)
    fix a r s
    show x: "R (SOME x. x \<in> Rep a) (SOME x. x \<in> Rep a)" proof -
      obtain x where r: "R x x" and rep: "Rep a = Collect (R x)" using rep_prop[of a] by auto
      have "R (SOME x. x \<in> Rep a) x"  using r rep some_collect by metis
      then have "R x (SOME x. x \<in> Rep a)" using part_equivp_symp[OF equivp] by fast
      then show "R (SOME x. x \<in> Rep a) (SOME x. x \<in> Rep a)"
        using part_equivp_transp[OF equivp] by (metis `R (SOME x. x \<in> Rep a) x`)
    qed
    have "Collect (R (SOME x. x \<in> Rep a)) = (Rep a)" by (metis some_collect rep_prop)
    then show "Abs (Collect (R (SOME x. x \<in> Rep a))) = a" using rep_inverse by auto
    have "R r r \<Longrightarrow> R s s \<Longrightarrow> Abs (Collect (R r)) = Abs (Collect (R s)) \<longleftrightarrow> R r = R s"
    proof -
      assume "R r r" and "R s s"
      then have "Abs (Collect (R r)) = Abs (Collect (R s)) \<longleftrightarrow> Collect (R r) = Collect (R s)"
        by (metis abs_inverse)
      also have "Collect (R r) = Collect (R s) \<longleftrightarrow> (\<lambda>A x. x \<in> A) (Collect (R r)) = (\<lambda>A x. x \<in> A) (Collect (R s))"
        by rule simp_all
      finally show "Abs (Collect (R r)) = Abs (Collect (R s)) \<longleftrightarrow> R r = R s" by simp
    qed
    then show "R r s \<longleftrightarrow> R r r \<and> R s s \<and> (Abs (Collect (R r)) = Abs (Collect (R s)))"
      using equivp[simplified part_equivp_def] by metis
    qed

end

subsection {* Quotient composition *}

lemma OOO_quotient3:
  fixes R1 :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  fixes Abs1 :: "'a \<Rightarrow> 'b" and Rep1 :: "'b \<Rightarrow> 'a"
  fixes Abs2 :: "'b \<Rightarrow> 'c" and Rep2 :: "'c \<Rightarrow> 'b"
  fixes R2' :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  fixes R2 :: "'b \<Rightarrow> 'b \<Rightarrow> bool"
  assumes R1: "Quotient3 R1 Abs1 Rep1"
  assumes R2: "Quotient3 R2 Abs2 Rep2"
  assumes Abs1: "\<And>x y. R2' x y \<Longrightarrow> R1 x x \<Longrightarrow> R1 y y \<Longrightarrow> R2 (Abs1 x) (Abs1 y)"
  assumes Rep1: "\<And>x y. R2 x y \<Longrightarrow> R2' (Rep1 x) (Rep1 y)"
  shows "Quotient3 (R1 OO R2' OO R1) (Abs2 \<circ> Abs1) (Rep1 \<circ> Rep2)"
apply (rule Quotient3I)
   apply (simp add: o_def Quotient3_abs_rep [OF R2] Quotient3_abs_rep [OF R1])
  apply simp
  apply (rule_tac b="Rep1 (Rep2 a)" in relcomppI)
   apply (rule Quotient3_rep_reflp [OF R1])
  apply (rule_tac b="Rep1 (Rep2 a)" in relcomppI [rotated])
   apply (rule Quotient3_rep_reflp [OF R1])
  apply (rule Rep1)
  apply (rule Quotient3_rep_reflp [OF R2])
 apply safe
    apply (rename_tac x y)
    apply (drule Abs1)
      apply (erule Quotient3_refl2 [OF R1])
     apply (erule Quotient3_refl1 [OF R1])
    apply (drule Quotient3_refl1 [OF R2], drule Rep1)
    apply (subgoal_tac "R1 r (Rep1 (Abs1 x))")
     apply (rule_tac b="Rep1 (Abs1 x)" in relcomppI, assumption)
     apply (erule relcomppI)
     apply (erule Quotient3_symp [OF R1, THEN sympD])
    apply (rule Quotient3_rel[symmetric, OF R1, THEN iffD2])
    apply (rule conjI, erule Quotient3_refl1 [OF R1])
    apply (rule conjI, rule Quotient3_rep_reflp [OF R1])
    apply (subst Quotient3_abs_rep [OF R1])
    apply (erule Quotient3_rel_abs [OF R1])
   apply (rename_tac x y)
   apply (drule Abs1)
     apply (erule Quotient3_refl2 [OF R1])
    apply (erule Quotient3_refl1 [OF R1])
   apply (drule Quotient3_refl2 [OF R2], drule Rep1)
   apply (subgoal_tac "R1 s (Rep1 (Abs1 y))")
    apply (rule_tac b="Rep1 (Abs1 y)" in relcomppI, assumption)
    apply (erule relcomppI)
    apply (erule Quotient3_symp [OF R1, THEN sympD])
   apply (rule Quotient3_rel[symmetric, OF R1, THEN iffD2])
   apply (rule conjI, erule Quotient3_refl2 [OF R1])
   apply (rule conjI, rule Quotient3_rep_reflp [OF R1])
   apply (subst Quotient3_abs_rep [OF R1])
   apply (erule Quotient3_rel_abs [OF R1, THEN sym])
  apply simp
  apply (rule Quotient3_rel_abs [OF R2])
  apply (rule Quotient3_rel_abs [OF R1, THEN ssubst], assumption)
  apply (rule Quotient3_rel_abs [OF R1, THEN subst], assumption)
  apply (erule Abs1)
   apply (erule Quotient3_refl2 [OF R1])
  apply (erule Quotient3_refl1 [OF R1])
 apply (rename_tac a b c d)
 apply simp
 apply (rule_tac b="Rep1 (Abs1 r)" in relcomppI)
  apply (rule Quotient3_rel[symmetric, OF R1, THEN iffD2])
  apply (rule conjI, erule Quotient3_refl1 [OF R1])
  apply (simp add: Quotient3_abs_rep [OF R1] Quotient3_rep_reflp [OF R1])
 apply (rule_tac b="Rep1 (Abs1 s)" in relcomppI [rotated])
  apply (rule Quotient3_rel[symmetric, OF R1, THEN iffD2])
  apply (simp add: Quotient3_abs_rep [OF R1] Quotient3_rep_reflp [OF R1])
  apply (erule Quotient3_refl2 [OF R1])
 apply (rule Rep1)
 apply (drule Abs1)
   apply (erule Quotient3_refl2 [OF R1])
  apply (erule Quotient3_refl1 [OF R1])
 apply (drule Abs1)
  apply (erule Quotient3_refl2 [OF R1])
 apply (erule Quotient3_refl1 [OF R1])
 apply (drule Quotient3_rel_abs [OF R1])
 apply (drule Quotient3_rel_abs [OF R1])
 apply (drule Quotient3_rel_abs [OF R1])
 apply (drule Quotient3_rel_abs [OF R1])
 apply simp
 apply (rule Quotient3_rel[symmetric, OF R2, THEN iffD2])
 apply simp
done

lemma OOO_eq_quotient3:
  fixes R1 :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  fixes Abs1 :: "'a \<Rightarrow> 'b" and Rep1 :: "'b \<Rightarrow> 'a"
  fixes Abs2 :: "'b \<Rightarrow> 'c" and Rep2 :: "'c \<Rightarrow> 'b"
  assumes R1: "Quotient3 R1 Abs1 Rep1"
  assumes R2: "Quotient3 op= Abs2 Rep2"
  shows "Quotient3 (R1 OOO op=) (Abs2 \<circ> Abs1) (Rep1 \<circ> Rep2)"
using assms
by (rule OOO_quotient3) auto

subsection {* Quotient3 to Quotient *}

lemma Quotient3_to_Quotient:
assumes "Quotient3 R Abs Rep"
and "T \<equiv> \<lambda>x y. R x x \<and> Abs x = y"
shows "Quotient R Abs Rep T"
using assms unfolding Quotient3_def by (intro QuotientI) blast+

lemma Quotient3_to_Quotient_equivp:
assumes q: "Quotient3 R Abs Rep"
and T_def: "T \<equiv> \<lambda>x y. Abs x = y"
and eR: "equivp R"
shows "Quotient R Abs Rep T"
proof (intro QuotientI)
  fix a
  show "Abs (Rep a) = a" using q by(rule Quotient3_abs_rep)
next
  fix a
  show "R (Rep a) (Rep a)" using q by(rule Quotient3_rep_reflp)
next
  fix r s
  show "R r s = (R r r \<and> R s s \<and> Abs r = Abs s)" using q by(rule Quotient3_rel[symmetric])
next
  show "T = (\<lambda>x y. R x x \<and> Abs x = y)" using T_def equivp_reflp[OF eR] by simp
qed

subsection {* ML setup *}

text {* Auxiliary data for the quotient package *}

use "Tools/Quotient/quotient_info.ML"
setup Quotient_Info.setup

declare [[mapQ3 "fun" = (fun_rel, fun_quotient3)]]

lemmas [quot_thm] = fun_quotient3
lemmas [quot_respect] = quot_rel_rsp if_rsp o_rsp let_rsp id_rsp
lemmas [quot_preserve] = if_prs o_prs let_prs id_prs
lemmas [quot_equiv] = identity_equivp


text {* Lemmas about simplifying id's. *}
lemmas [id_simps] =
  id_def[symmetric]
  map_fun_id
  id_apply
  id_o
  o_id
  eq_comp_r
  vimage_id

text {* Translation functions for the lifting process. *}
use "Tools/Quotient/quotient_term.ML"


text {* Definitions of the quotient types. *}
use "Tools/Quotient/quotient_type.ML"


text {* Definitions for quotient constants. *}
use "Tools/Quotient/quotient_def.ML"


text {*
  An auxiliary constant for recording some information
  about the lifted theorem in a tactic.
*}
definition
  Quot_True :: "'a \<Rightarrow> bool"
where
  "Quot_True x \<longleftrightarrow> True"

lemma
  shows QT_all: "Quot_True (All P) \<Longrightarrow> Quot_True P"
  and   QT_ex:  "Quot_True (Ex P) \<Longrightarrow> Quot_True P"
  and   QT_ex1: "Quot_True (Ex1 P) \<Longrightarrow> Quot_True P"
  and   QT_lam: "Quot_True (\<lambda>x. P x) \<Longrightarrow> (\<And>x. Quot_True (P x))"
  and   QT_ext: "(\<And>x. Quot_True (a x) \<Longrightarrow> f x = g x) \<Longrightarrow> (Quot_True a \<Longrightarrow> f = g)"
  by (simp_all add: Quot_True_def ext)

lemma QT_imp: "Quot_True a \<equiv> Quot_True b"
  by (simp add: Quot_True_def)


text {* Tactics for proving the lifted theorems *}
use "Tools/Quotient/quotient_tacs.ML"

subsection {* Methods / Interface *}

method_setup lifting =
  {* Attrib.thms >> (fn thms => fn ctxt => 
       SIMPLE_METHOD' (Quotient_Tacs.lift_tac ctxt [] thms)) *}
  {* lift theorems to quotient types *}

method_setup lifting_setup =
  {* Attrib.thm >> (fn thm => fn ctxt => 
       SIMPLE_METHOD' (Quotient_Tacs.lift_procedure_tac ctxt [] thm)) *}
  {* set up the three goals for the quotient lifting procedure *}

method_setup descending =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.descend_tac ctxt [])) *}
  {* decend theorems to the raw level *}

method_setup descending_setup =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.descend_procedure_tac ctxt [])) *}
  {* set up the three goals for the decending theorems *}

method_setup partiality_descending =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.partiality_descend_tac ctxt [])) *}
  {* decend theorems to the raw level *}

method_setup partiality_descending_setup =
  {* Scan.succeed (fn ctxt => 
       SIMPLE_METHOD' (Quotient_Tacs.partiality_descend_procedure_tac ctxt [])) *}
  {* set up the three goals for the decending theorems *}

method_setup regularize =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.regularize_tac ctxt)) *}
  {* prove the regularization goals from the quotient lifting procedure *}

method_setup injection =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.all_injection_tac ctxt)) *}
  {* prove the rep/abs injection goals from the quotient lifting procedure *}

method_setup cleaning =
  {* Scan.succeed (fn ctxt => SIMPLE_METHOD' (Quotient_Tacs.clean_tac ctxt)) *}
  {* prove the cleaning goals from the quotient lifting procedure *}

attribute_setup quot_lifted =
  {* Scan.succeed Quotient_Tacs.lifted_attrib *}
  {* lift theorems to quotient types *}

no_notation
  rel_conj (infixr "OOO" 75) and
  map_fun (infixr "--->" 55) and
  fun_rel (infixr "===>" 55)

end

