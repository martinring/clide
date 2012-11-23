(*  Title: HOL/ex/Birthday_Paradox.thy
    Author: Lukas Bulwahn, TU Muenchen, 2007
*)

header {* A Formulation of the Birthday Paradox *}

theory Birthday_Paradox
imports Main "~~/src/HOL/Fact" "~~/src/HOL/Library/FuncSet"
begin

section {* Cardinality *}

lemma card_product_dependent:
  assumes "finite S"
  assumes "\<forall>x \<in> S. finite (T x)" 
  shows "card {(x, y). x \<in> S \<and> y \<in> T x} = (\<Sum>x \<in> S. card (T x))"
proof -
  note `finite S`
  moreover
  have "{(x, y). x \<in> S \<and> y \<in> T x} = (UN x : S. Pair x ` T x)" by auto
  moreover
  from `\<forall>x \<in> S. finite (T x)` have "ALL x:S. finite (Pair x ` T x)" by auto
  moreover
  have " ALL i:S. ALL j:S. i ~= j --> Pair i ` T i Int Pair j ` T j = {}" by auto
  moreover  
  ultimately have "card {(x, y). x \<in> S \<and> y \<in> T x} = (SUM i:S. card (Pair i ` T i))"
    by (auto, subst card_UN_disjoint) auto
  also have "... = (SUM x:S. card (T x))"
    by (subst card_image) (auto intro: inj_onI)
  finally show ?thesis by auto
qed

lemma card_extensional_funcset_inj_on:
  assumes "finite S" "finite T" "card S \<le> card T"
  shows "card {f \<in> extensional_funcset S T. inj_on f S} = fact (card T) div (fact (card T - card S))"
using assms
proof (induct S arbitrary: T rule: finite_induct)
  case empty
  from this show ?case by (simp add: Collect_conv_if extensional_funcset_empty_domain)
next
  case (insert x S)
  { fix x
    from `finite T` have "finite (T - {x})" by auto
    from `finite S` this have "finite (extensional_funcset S (T - {x}))"
      by (rule finite_extensional_funcset)
    moreover
    have "{f : extensional_funcset S (T - {x}). inj_on f S} \<subseteq> (extensional_funcset S (T - {x}))" by auto    
    ultimately have "finite {f : extensional_funcset S (T - {x}). inj_on f S}"
      by (auto intro: finite_subset)
  } note finite_delete = this
  from insert have hyps: "\<forall>y \<in> T. card ({g. g \<in> extensional_funcset S (T - {y}) \<and> inj_on g S}) = fact (card T - 1) div fact ((card T - 1) - card S)"(is "\<forall> _ \<in> T. _ = ?k") by auto
  from extensional_funcset_extend_domain_inj_on_eq[OF `x \<notin> S`]
  have "card {f. f : extensional_funcset (insert x S) T & inj_on f (insert x S)} =
    card ((%(y, g). g(x := y)) ` {(y, g). y : T & g : extensional_funcset S (T - {y}) & inj_on g S})"
    by metis
  also from extensional_funcset_extend_domain_inj_onI[OF `x \<notin> S`, of T] have "... =  card {(y, g). y : T & g : extensional_funcset S (T - {y}) & inj_on g S}"
    by (simp add: card_image)
  also have "card {(y, g). y \<in> T \<and> g \<in> extensional_funcset S (T - {y}) \<and> inj_on g S} =
    card {(y, g). y \<in> T \<and> g \<in> {f \<in> extensional_funcset S (T - {y}). inj_on f S}}" by auto
  also from `finite T` finite_delete have "... = (\<Sum>y \<in> T. card {g. g \<in> extensional_funcset S (T - {y}) \<and>  inj_on g S})"
    by (subst card_product_dependent) auto
  also from hyps have "... = (card T) * ?k"
    by auto
  also have "... = card T * fact (card T - 1) div fact (card T - card (insert x S))"
    using insert unfolding div_mult1_eq[of "card T" "fact (card T - 1)"]
    by (simp add: fact_mod)
  also have "... = fact (card T) div fact (card T - card (insert x S))"
    using insert by (simp add: fact_reduce_nat[of "card T"])
  finally show ?case .
qed

lemma card_extensional_funcset_not_inj_on:
  assumes "finite S" "finite T" "card S \<le> card T"
  shows "card {f \<in> extensional_funcset S T. \<not> inj_on f S} = (card T) ^ (card S) - (fact (card T)) div (fact (card T - card S))"
proof -
  have subset: "{f : extensional_funcset S T. inj_on f S} <= extensional_funcset S T" by auto
  from finite_subset[OF subset] assms have finite: "finite {f : extensional_funcset S T. inj_on f S}"
    by (auto intro!: finite_extensional_funcset)
  have "{f \<in> extensional_funcset S T. \<not> inj_on f S} = extensional_funcset S T - {f \<in> extensional_funcset S T. inj_on f S}" by auto 
  from assms this finite subset show ?thesis
    by (simp add: card_Diff_subset card_extensional_funcset card_extensional_funcset_inj_on)
qed

lemma setprod_upto_nat_unfold:
  "setprod f {m..(n::nat)} = (if n < m then 1 else (if n = 0 then f 0 else f n * setprod f {m..(n - 1)}))"
  by auto (auto simp add: gr0_conv_Suc atLeastAtMostSuc_conv)

section {* Birthday paradox *}

lemma birthday_paradox:
  assumes "card S = 23" "card T = 365"
  shows "2 * card {f \<in> extensional_funcset S T. \<not> inj_on f S} \<ge> card (extensional_funcset S T)"
proof -
  from `card S = 23` `card T = 365` have "finite S" "finite T" "card S <= card T" by (auto intro: card_ge_0_finite)
  from assms show ?thesis
    using card_extensional_funcset[OF `finite S`, of T]
      card_extensional_funcset_not_inj_on[OF `finite S` `finite T` `card S <= card T`]
    by (simp add: fact_div_fact setprod_upto_nat_unfold)
qed

end
