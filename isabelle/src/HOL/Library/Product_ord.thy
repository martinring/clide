(*  Title:      HOL/Library/Product_ord.thy
    Author:     Norbert Voelker
*)

header {* Order on product types *}

theory Product_ord
imports Main
begin

instantiation prod :: (ord, ord) ord
begin

definition
  prod_le_def: "x \<le> y \<longleftrightarrow> fst x < fst y \<or> fst x \<le> fst y \<and> snd x \<le> snd y"

definition
  prod_less_def: "x < y \<longleftrightarrow> fst x < fst y \<or> fst x \<le> fst y \<and> snd x < snd y"

instance ..

end

lemma [code]:
  "(x1\<Colon>'a\<Colon>{ord, equal}, y1) \<le> (x2, y2) \<longleftrightarrow> x1 < x2 \<or> x1 \<le> x2 \<and> y1 \<le> y2"
  "(x1\<Colon>'a\<Colon>{ord, equal}, y1) < (x2, y2) \<longleftrightarrow> x1 < x2 \<or> x1 \<le> x2 \<and> y1 < y2"
  unfolding prod_le_def prod_less_def by simp_all

instance prod :: (preorder, preorder) preorder proof
qed (auto simp: prod_le_def prod_less_def less_le_not_le intro: order_trans)

instance prod :: (order, order) order proof
qed (auto simp add: prod_le_def)

instance prod :: (linorder, linorder) linorder proof
qed (auto simp: prod_le_def)

instantiation prod :: (linorder, linorder) distrib_lattice
begin

definition
  inf_prod_def: "(inf \<Colon> 'a \<times> 'b \<Rightarrow> _ \<Rightarrow> _) = min"

definition
  sup_prod_def: "(sup \<Colon> 'a \<times> 'b \<Rightarrow> _ \<Rightarrow> _) = max"

instance proof
qed (auto simp add: inf_prod_def sup_prod_def min_max.sup_inf_distrib1)

end

instantiation prod :: (bot, bot) bot
begin

definition
  bot_prod_def: "bot = (bot, bot)"

instance proof
qed (auto simp add: bot_prod_def prod_le_def)

end

instantiation prod :: (top, top) top
begin

definition
  top_prod_def: "top = (top, top)"

instance proof
qed (auto simp add: top_prod_def prod_le_def)

end

text {* A stronger version of the definition holds for partial orders. *}

lemma prod_less_eq:
  fixes x y :: "'a::order \<times> 'b::ord"
  shows "x < y \<longleftrightarrow> fst x < fst y \<or> (fst x = fst y \<and> snd x < snd y)"
  unfolding prod_less_def fst_conv snd_conv le_less by auto

instance prod :: (wellorder, wellorder) wellorder
proof
  fix P :: "'a \<times> 'b \<Rightarrow> bool" and z :: "'a \<times> 'b"
  assume P: "\<And>x. (\<And>y. y < x \<Longrightarrow> P y) \<Longrightarrow> P x"
  show "P z"
  proof (induct z)
    case (Pair a b)
    show "P (a, b)"
      apply (induct a arbitrary: b rule: less_induct)
      apply (rule less_induct [where 'a='b])
      apply (rule P)
      apply (auto simp add: prod_less_eq)
      done
  qed
qed

end
