
(*  Title:      List2.thy
    Date:       Oct 2006
    Author:     David Trachtenherz
*)

header {* Additional definitions and results for lists *}

theory List2
imports "../CommonSet/SetIntervalCut"
begin

subsection {* Additional definitions and results for lists *}

text {* 
  Infix syntactical abbreviations for operators @{term take} and @{term drop}.
  The abbreviations resemble to the operator symbols used later
  for take and drop operators on infinite lists in ListInf. *}

(*
syntax (xsymbols)
  "_f_take" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list" (infixl "\<down>" 100)
  "_f_drop" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list" (infixl "\<up>" 100)
translations
  "xs \<down> n" \<rightleftharpoons> "CONST take n xs"
  "xs \<up> n" \<rightleftharpoons> "CONST drop n xs"
*)

abbreviation (xsymbols)
  "f_take'" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list" (infixl "\<down>" 100)
where
  "xs \<down> n \<equiv> take n xs"
abbreviation (xsymbols)
  "f_drop'" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list" (infixl "\<up>" 100)
where
  "xs \<up> n \<equiv> drop n xs"
syntax (HTML output)
  "f_take'" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list"   (infixl "\<down>" 100)
  "f_drop'" :: "'a list \<Rightarrow> nat \<Rightarrow> 'a list"   (infixl "\<up>" 100)

term "xs \<down> n"
term "xs \<up> n"



thm List.append_Cons
lemma append_eq_Cons: "[x] @ xs = x # xs" 
by simp

lemma length_Cons: "length (x # xs) = Suc (length xs)"
by simp
lemma length_snoc: "length (xs @ [x]) = Suc (length xs)"
by simp


subsubsection {* Additional lemmata about list emptiness *}

lemma length_greater_imp_not_empty:"n < length xs \<Longrightarrow> xs \<noteq> []"
by fastforce

lemma length_ge_Suc_imp_not_empty:"Suc n \<le> length xs \<Longrightarrow> xs \<noteq> []"
by fastforce
thm length_take

lemma length_take_le: "length (xs \<down> n) \<le> length xs"
by simp

lemma take_not_empty_conv:"(xs \<down> n \<noteq> []) = (0 < n \<and> xs \<noteq> [])"
by simp

lemma drop_not_empty_conv:"(xs \<up> n \<noteq> []) = (n < length xs)"
by fastforce

lemma zip_eq_Nil: "(zip xs ys = []) = (xs = [] \<or> ys = [])"
by (force simp: length_0_conv[symmetric] min_def simp del: length_0_conv)

lemma zip_not_empty_conv: "(zip xs ys \<noteq> []) = (xs \<noteq> [] \<and> ys \<noteq> [])"
by (simp add: zip_eq_Nil)




subsubsection {* Additional lemmata about @{term take}, @{term drop}, @{term hd}, @{term last}, @{text nth} and @{text filter}  *}

lemma nth_tl_eq_nth_Suc: "
  Suc n \<le> length xs \<Longrightarrow> (tl xs) ! n = xs ! Suc n"
thm hd_Cons_tl[OF length_ge_Suc_imp_not_empty, THEN subst]
by (rule hd_Cons_tl[OF length_ge_Suc_imp_not_empty, THEN subst], simp+)
corollary nth_tl_eq_nth_Suc2: "
  n < length xs \<Longrightarrow> (tl xs) ! n = xs ! Suc n"
by (simp add: nth_tl_eq_nth_Suc)

lemma hd_eq_first: "xs \<noteq> [] \<Longrightarrow> xs ! 0 = hd xs"
by (induct xs, simp_all)
corollary take_first:"xs \<noteq> [] \<Longrightarrow> xs \<down>  (Suc 0) = [xs ! 0]"
by (induct xs, simp_all)
corollary take_hd:"xs \<noteq> [] \<Longrightarrow> xs \<down>  (Suc 0) = [hd xs]"
by (simp add: take_first hd_eq_first)

thm last_conv_nth
theorem last_nth: "xs \<noteq> [] \<Longrightarrow> last xs = xs ! (length xs - Suc 0)"
by (simp add: last_conv_nth)

lemma last_take: "n < length xs \<Longrightarrow> last (xs \<down> Suc n) = xs ! n"
by (simp add: last_nth length_greater_imp_not_empty min_eqR)
corollary last_take2:"
  \<lbrakk> 0 < n; n \<le> length xs \<rbrakk> \<Longrightarrow> last (xs \<down> n) = xs ! (n - Suc 0)"
thm diff_Suc_less[THEN order_less_le_trans]
apply (frule diff_Suc_less[THEN order_less_le_trans, of _ "length xs" 0], assumption)
thm last_take[of "n - Suc 0" xs]
apply (drule last_take[of "n - Suc 0" xs])
apply simp
done

thm List.nth_drop
corollary nth_0_drop: "n \<le> length xs \<Longrightarrow> (xs \<up> n) ! 0 = xs ! n"
by (cut_tac nth_drop[of n 0 xs], simp+)
corollary hd_drop: "n < length xs \<Longrightarrow> hd (xs \<up> n) = xs ! n"
apply (frule drop_not_empty_conv[THEN iffD2])
apply (simp add: hd_eq_first[symmetric])
done

lemma drop_eq_tl: "xs \<up> (Suc 0) = tl xs"
by (simp add: drop_Suc)

lemma drop_take_1: "
  n < length xs \<Longrightarrow> xs \<up> n \<down> (Suc 0) = [xs ! n]"
thm take_hd hd_drop
by (simp add: take_hd hd_drop)

lemma upt_append: "m \<le> n \<Longrightarrow> [0..<m] @ [m..<n] = [0..<n]"
thm upt_add_eq_append[of 0 m "n - m"]
by (insert upt_add_eq_append[of 0 m "n - m"], simp)

thm nth_append
lemma nth_append1: "n < length xs \<Longrightarrow> (xs @ ys) ! n = xs ! n"
by (simp add: nth_append)
lemma nth_append2: "length xs \<le> n \<Longrightarrow> (xs @ ys) ! n = ys ! (n - length xs)"
by (simp add: nth_append)


lemma list_all_conv: "list_all P xs = (\<forall>i<length xs. P (xs ! i))"
by (rule list_all_length)

lemma expand_list_eq: "
  \<And>ys. (xs = ys) = (length xs = length ys \<and> (\<forall>i<length xs. xs ! i = ys ! i))"
by (rule list_eq_iff_nth_eq)
lemmas list_eq_iff = expand_list_eq


lemma list_take_drop_imp_eq: "
  \<lbrakk> xs \<down> n = ys \<down> n;  xs \<up> n = ys \<up> n \<rbrakk> \<Longrightarrow> xs = ys"
apply (rule subst[OF append_take_drop_id[of n xs]])
apply (rule subst[OF append_take_drop_id[of n ys]])
apply simp
done

lemma list_take_drop_eq_conv: "
  (xs = ys) = (\<exists>n. (xs \<down> n = ys \<down> n \<and> xs \<up> n = ys \<up> n))"
by (blast intro: list_take_drop_imp_eq)

lemma list_take_eq_conv: "(xs = ys) = (\<forall>n. xs \<down> n = ys \<down> n)"
apply (rule iffI, simp)
apply (drule_tac x="max (length xs) (length ys)" in spec)
apply simp
done

lemma list_drop_eq_conv: "(xs = ys) = (\<forall>n. xs \<up> n = ys \<up> n)"
apply (rule iffI, simp)
apply (drule_tac x=0 in spec)
apply simp
done



abbreviation (xsymbols)
  "replicate'" :: "'a \<Rightarrow> nat \<Rightarrow> 'a list" ("_\<^bsup>_\<^esup>" [1000,65])
where
  "x\<^bsup>n\<^esup> \<equiv> replicate n x"

term "length x\<^bsup>(a+b)\<^esup>"

thm List.replicate_Suc
thm List.replicate_app_Cons_same
lemma replicate_snoc: "x\<^bsup>n\<^esup> @ [x] = x\<^bsup>Suc n\<^esup>"
by (simp add: replicate_app_Cons_same)

thm List.nth_replicate
lemma eq_replicate_conv: "(\<forall>i<length xs. xs ! i = m) = (xs = m\<^bsup>length xs\<^esup>)"
apply (rule iffI)
 apply (simp add: expand_list_eq)
apply clarsimp
apply (rule ssubst[of xs "replicate (length xs) m"], assumption)
apply (rule nth_replicate, simp)
done

lemma replicate_Cons_length: "length (x # a\<^bsup>n\<^esup>) = Suc n"
by simp
lemma replicate_pred_Cons_length: "0 < n \<Longrightarrow> length (x # a\<^bsup>n - Suc 0\<^esup>) = n"
by simp

thm replicate_add
lemma replicate_le_diff: "m \<le> n \<Longrightarrow> x\<^bsup>m\<^esup> @ x\<^bsup>n - m\<^esup> = x\<^bsup>n\<^esup>"
by (simp add: replicate_add[symmetric])
lemma replicate_le_diff2: "\<lbrakk> k \<le> m; m \<le> n \<rbrakk> \<Longrightarrow> x\<^bsup>m - k\<^esup> @ x\<^bsup>n - m\<^esup> = x\<^bsup>n - k\<^esup>"
by (subst replicate_add[symmetric], simp)

thm list.induct
lemma append_constant_length_induct_aux: "\<And>xs. 
  \<lbrakk> length xs div k = n; \<And>ys. k = 0 \<or> length ys < k \<Longrightarrow> P ys; 
    \<And>xs ys. \<lbrakk> length xs = k; P ys \<rbrakk> \<Longrightarrow> P (xs @ ys) \<rbrakk> \<Longrightarrow> P xs"
apply (case_tac "k = 0", blast)
apply simp
apply (induct n)
 apply (simp add: div_eq_0_conv')
apply (subgoal_tac "k \<le> length xs")
 prefer 2
 apply (rule div_gr_imp_gr_divisor[of 0], simp)
apply (simp only: atomize_all atomize_imp, clarsimp)
apply (erule_tac x="drop k xs" in allE)
apply (simp add: div_diff_self2)
apply (erule_tac x=undefined in allE)
apply (erule_tac x="take k xs" in allE)
apply (simp add: min_eqR)
apply (erule_tac x="drop k xs" in allE)
apply simp
done

lemma append_constant_length_induct: "
  \<lbrakk> \<And>ys. k = 0 \<or> length ys < k \<Longrightarrow> P ys; 
    \<And>xs ys. \<lbrakk> length xs = k; P ys \<rbrakk> \<Longrightarrow> P (xs @ ys) \<rbrakk> \<Longrightarrow> P xs"
by (simp add: append_constant_length_induct_aux[of _ _ "length xs div k"])

lemma zip_swap: "map (\<lambda>(y,x). (x,y)) (zip ys xs) = (zip xs ys)"
by (simp add: expand_list_eq)

lemma zip_takeL: "(zip xs ys) \<down> n = zip (xs \<down> n) ys"
by (simp add: expand_list_eq)

lemma zip_takeR: "(zip xs ys) \<down> n = zip xs (ys \<down> n)"
thm zip_swap[of ys]
apply (subst zip_swap[of ys, symmetric])
apply (subst take_map)
apply (subst zip_takeL)
apply (simp add: zip_swap)
done

lemma zip_take: "(zip xs ys) \<down> n = zip (xs \<down> n) (ys \<down> n)"
by (rule take_zip)

thm nth_zip
lemma hd_zip: "\<lbrakk> xs \<noteq> []; ys \<noteq> [] \<rbrakk> \<Longrightarrow> hd (zip xs ys) = (hd xs, hd ys)"
by (simp add: hd_conv_nth zip_not_empty_conv)

lemma map_id: "map id xs = xs"
by (simp add: id_def)

lemma map_id_subst: "P (map id xs) \<Longrightarrow> P xs"
by (subst map_id[symmetric])

lemma map_one: "map f [x] = [f x]"
by simp

lemma map_last: "xs \<noteq> [] \<Longrightarrow> last (map f xs) = f (last xs)"
by (rule last_map)


lemma filter_list_all: "list_all P xs \<Longrightarrow> filter P xs = xs"
by (induct xs, simp+)

lemma filter_snoc: "filter P (xs @ [x]) = (if P x then (filter P xs) @ [x] else filter P xs)"
by (case_tac "P x", simp+)

lemma filter_filter_eq: "list_all (\<lambda>x. P x = Q x) xs \<Longrightarrow> filter P xs = filter Q xs"
by (induct xs, simp+)

lemma filter_nth: "\<And>n. 
  n < length (filter P xs) \<Longrightarrow> 
  (filter P xs) ! n = 
  xs ! (LEAST k. 
    k < length xs \<and> 
    n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)})"
apply (induct xs rule: rev_induct, simp)
apply (rename_tac x xs n)
thm filter_snoc
apply (simp only: filter_snoc)
apply (simp split del: split_if)
apply (case_tac "xs = []")
 apply (simp split del: split_if)
 apply (rule_tac 
   t = "\<lambda>k i. i = 0 \<and> i \<le> k \<and> P ([x] ! i)" and
   s = "\<lambda>k i. i = 0 \<and> P x" 
   in subst)
  apply (simp add: fun_eq_iff)
  apply fastforce
 apply (fastforce simp: Least_def)
apply (rule_tac 
  t = "\<lambda>k. card {i. i \<le> k \<and> i < Suc (length xs) \<and> P ((xs @ [x]) ! i)}" and
  s = "\<lambda>k. (card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)} + 
           (if k \<ge> length xs \<and> P x then Suc 0 else 0))"
  in subst)
 apply (clarsimp simp: fun_eq_iff split del: split_if, rename_tac k)
 apply (simp split del: split_if add: less_Suc_eq conj_disj_distribL conj_disj_distribR Collect_disj_eq)
 apply (subst card_Un_disjoint)
    apply (rule_tac n="length xs" in bounded_nat_set_is_finite, blast)
   apply (rule_tac n="Suc (length xs)" in bounded_nat_set_is_finite, blast)
  apply blast
 apply (rule_tac 
   t = "\<lambda>i. i < length xs \<and> P ((xs @ [x]) ! i)" and 
   s = "\<lambda>i. i < length xs \<and> P (xs ! i)" 
   in subst)
  apply (rule fun_eq_iff[THEN iffD2])
  apply (fastforce simp: nth_append1)
 apply (rule nat_add_left_cancel[THEN iffD2])
 apply (rule_tac 
   t = "\<lambda>i. i = length xs \<and> i \<le> k \<and> P ((xs @ [x]) ! i)" and 
   s = "\<lambda>i. i = length xs \<and> i \<le> k \<and> P x" 
   in subst)
  apply (rule fun_eq_iff[THEN iffD2])
  apply fastforce
 apply (case_tac "length xs \<le> k")
  apply clarsimp
  apply (rule_tac 
    t = "\<lambda>i. i = length xs \<and> i \<le> k" and 
    s = "\<lambda>i. i = length xs" 
    in subst)
   apply (rule fun_eq_iff[THEN iffD2])
   apply fastforce
  apply simp
 apply simp
apply (simp split del: split_if add: less_Suc_eq conj_disj_distribL conj_disj_distribR)
apply (rule_tac 
  t = "\<lambda>k. k < length xs \<and> 
           n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)} + (if length xs \<le> k \<and> P x then Suc 0 else 0)" and
  s = "\<lambda>k. k < length xs \<and> n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)}"
  in subst)
 apply (simp add: fun_eq_iff)
apply (rule_tac 
  t = "\<lambda>k. k = length xs \<and> 
           n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)} + (if length xs \<le> k \<and> P x then Suc 0 else 0)" and
  s = "\<lambda>k. k = length xs \<and> 
           n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)} + (if P x then Suc 0 else 0)"
  in subst)
 apply (simp add: fun_eq_iff)
apply (case_tac "n < length (filter P xs)")
 apply (rule_tac
   t = "(if P x then filter P xs @ [x] else filter P xs) ! n" and
   s = "(filter P xs) ! n"
   in subst)
  apply (simp add: nth_append1)
 apply (simp split del: split_if)
 apply (subgoal_tac "\<exists>k<length xs. n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)}")
  prefer 2
  apply (rule_tac x="length xs - Suc 0" in exI)
  apply (simp add: length_filter_conv_card less_eq_le_pred[symmetric])
 apply (subgoal_tac "\<exists>k\<le>length xs. n < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)}")
  prefer 2
  apply (blast intro: less_imp_le)
 thm Least_le_imp_le_disj
 apply (subst Least_le_imp_le_disj)
   apply simp
  apply simp
 thm nth_append1
 apply (rule sym, rule nth_append1)
 apply (rule LeastI2_ex, assumption)
 apply blast
apply (simp add: linorder_not_less)
apply (subgoal_tac "P x")
 prefer 2
 apply (rule ccontr, simp)
apply (simp add: length_snoc)
apply (drule less_Suc_eq_le[THEN iffD1], drule_tac x=n in order_antisym, assumption)
apply (simp add: nth_append2)
thm length_filter_conv_card
apply (simp add: length_filter_conv_card)
apply (rule_tac 
  t = "\<lambda>k. card {i. i < length xs \<and> P (xs ! i)} < card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)}" and
  s = "\<lambda>k. False"
  in subst)
 apply (rule fun_eq_iff[THEN iffD2], rule allI, rename_tac k)
 apply (simp add: linorder_not_less)
 apply (rule card_mono)
  apply fastforce
 apply blast
apply simp
apply (rule_tac 
  t = "(LEAST k. k = length xs \<and> 
                 card {i. i < length xs \<and> P (xs ! i)} < Suc (card {i. i \<le> k \<and> i < length xs \<and> P (xs ! i)}))" and
  s = "length xs"
  in subst)
 apply (rule sym, rule Least_equality)
  apply simp
  apply (rule le_imp_less_Suc)
  apply (rule card_mono)
   apply fastforce
  apply fastforce
 apply simp
apply simp
done




subsubsection {* Ordered lists *}

fun
  list_ord :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> ('a::ord) list \<Rightarrow> bool"
where
  "list_ord ord (x1 # x2 # xs) = (ord x1 x2 \<and> list_ord ord (x2 # xs))"
| "list_ord ord xs = True"

thm list_ord.simps
definition list_asc :: "('a::ord) list \<Rightarrow> bool" where
  "list_asc xs \<equiv> list_ord (op \<le>) xs"
definition list_strict_asc :: "('a::ord) list \<Rightarrow> bool" where
  "list_strict_asc xs \<equiv> list_ord (op <) xs"
value "list_asc  [1::nat, 2, 2]"
value "list_strict_asc  [1::nat, 2, 2]"
definition list_desc :: "('a::ord) list \<Rightarrow> bool" where
  "list_desc xs \<equiv> list_ord (op \<ge>) xs"
definition list_strict_desc :: "('a::ord) list \<Rightarrow> bool" where
  "list_strict_desc xs \<equiv> list_ord (op >) xs"

lemma list_ord_Nil: "list_ord ord []"
by simp
lemma list_ord_one: "list_ord ord [x]"
by simp
lemma list_ord_Cons: "
  list_ord ord (x # xs) = 
  (xs = [] \<or> (ord x (hd xs) \<and> list_ord ord xs))"
by (induct xs, simp+)
lemma list_ord_Cons_imp: "\<lbrakk> list_ord ord xs; ord x (hd xs) \<rbrakk> \<Longrightarrow> list_ord ord (x # xs)"
by (induct xs, simp+)
lemma list_ord_append: "\<And>ys.
  list_ord ord (xs @ ys) = 
  (list_ord ord xs \<and>
  (ys = [] \<or> (list_ord ord ys \<and> (xs = [] \<or> ord (last xs) (hd ys)))))"
apply (induct xs, fastforce)
apply (case_tac xs, case_tac ys, fastforce+)
done
lemma list_ord_snoc: "
  list_ord ord (xs @ [x]) = 
  (xs = [] \<or> (ord (last xs) x \<and> list_ord ord xs))"
by (fastforce simp: list_ord_append)

lemma list_ord_all_conv: "
  (list_ord ord xs) = (\<forall>n < length xs - 1. ord (xs ! n) (xs ! Suc n))"
apply (rule iffI)
 apply (induct xs, simp)
 apply clarsimp
 apply (simp add: list_ord_Cons)
 apply (erule disjE, simp)
 apply clarsimp
 apply (case_tac n)
  apply (simp add: hd_conv_nth)
 apply simp
apply (induct xs, simp)
apply (simp add: list_ord_Cons)
apply (case_tac "xs = []", simp)
apply (drule meta_mp)
 apply (intro allI impI, rename_tac n)
 apply (drule_tac x="Suc n" in spec, simp)
apply (drule_tac x=0 in spec)
apply (simp add: hd_conv_nth)
done

lemma list_ord_imp: "
  \<lbrakk> \<And>x y. ord x y \<Longrightarrow> ord' x y; list_ord ord xs \<rbrakk> \<Longrightarrow>
  list_ord ord' xs"
apply (induct xs, simp)
apply (simp add: list_ord_Cons)
apply fastforce
done
corollary list_strict_asc_imp_list_asc: "
  list_strict_asc (xs::'a::preorder list) \<Longrightarrow> list_asc xs"
by (unfold list_strict_asc_def list_asc_def, rule list_ord_imp[of "op <"], rule order_less_imp_le)
corollary list_strict_desc_imp_list_desc: "
  list_strict_desc (xs::'a::preorder list) \<Longrightarrow> list_desc xs"
by (unfold list_strict_desc_def list_desc_def, rule list_ord_imp[of "op >"], rule order_less_imp_le)

lemma list_ord_trans_imp: "\<And>i.
  \<lbrakk> transP ord; list_ord ord xs; j < length xs; i < j \<rbrakk> \<Longrightarrow>
  ord (xs ! i) (xs ! j)"
apply (simp add: list_ord_all_conv)
apply (induct j, simp)
apply (case_tac "j < i", simp)
apply (simp add: linorder_not_less)
apply (case_tac "i = j", simp)
thm trans_def
apply (drule_tac x=i in meta_spec, simp)
apply (drule_tac x=j in spec, simp add: Suc_less_pred_conv)
apply (unfold trans_def)
apply (drule_tac x="xs ! i" in spec, drule_tac x="xs ! j" in spec, drule_tac x="xs ! Suc j" in spec)
apply simp
done

lemma list_ord_trans: "
  transP ord \<Longrightarrow> 
  (list_ord ord xs) = 
  (\<forall>j < length xs. \<forall>i < j. ord (xs ! i) (xs ! j))"
apply (rule iffI)
 apply (simp add: list_ord_trans_imp)
apply (simp add: list_ord_all_conv)
done

lemma list_ord_trans_refl_le: "
  \<lbrakk> transP ord; reflP ord \<rbrakk> \<Longrightarrow> 
  (list_ord ord xs) = 
  (\<forall>j < length xs. \<forall>i \<le> j. ord (xs ! i) (xs ! j))"
apply (subst list_ord_trans, simp)
apply (rule iffI)
 apply clarsimp
 apply (case_tac "i = j")
  apply (simp add: refl_on_def)
 apply simp+
done

lemma list_ord_trans_refl_le_imp: "
  \<lbrakk> transP ord; \<And>x y. ord x y \<Longrightarrow> ord' x y; reflP ord'; 
    list_ord ord xs \<rbrakk> \<Longrightarrow> 
  (\<forall>j < length xs. \<forall>i \<le> j. ord' (xs ! i) (xs ! j))"
apply clarify
apply (case_tac "i = j")
 apply (simp add: refl_on_def)
thm list_ord_trans_imp
apply (simp add: list_ord_trans_imp)
done

corollary 
  list_asc_trans: "
    (list_asc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i < j. xs ! i \<le> xs ! j)" and
  list_strict_asc_trans: "
    (list_strict_asc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i < j. xs ! i < xs ! j)" and
  list_desc_trans: "
    (list_desc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i < j. xs ! j \<le> xs ! i)" and
  list_strict_desc_trans: "
    (list_strict_desc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i < j. xs ! j < xs ! i)"
apply (unfold list_asc_def list_strict_asc_def list_desc_def list_strict_desc_def)
apply (rule list_ord_trans, unfold trans_def, blast intro: order_trans order_less_trans)+
done

corollary 
  list_asc_trans_le: "
    (list_asc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i \<le> j. xs ! i \<le> xs ! j)" and
  list_desc_trans_le: "
    (list_desc (xs::'a::preorder list)) = 
    (\<forall>j < length xs. \<forall>i \<le> j. xs ! j \<le> xs ! i)"
apply (unfold list_asc_def list_strict_asc_def list_desc_def list_strict_desc_def)
apply (rule list_ord_trans_refl_le, unfold trans_def, blast intro: order_trans, simp add: refl_on_def)+
done

corollary
  list_strict_asc_trans_le: "
    (list_strict_asc (xs::'a::preorder list)) \<Longrightarrow> 
    (\<forall>j < length xs. \<forall>i \<le> j. xs ! i \<le> xs ! j)"
apply (unfold list_strict_asc_def)
thm list_ord_trans_refl_le_imp
apply (rule list_ord_trans_refl_le_imp[where ord="op \<le>"])
   apply (unfold trans_def, blast intro: order_trans)
  apply assumption
 apply (unfold refl_on_def, clarsimp)
thm list_ord_imp
apply (rule list_ord_imp[where ord="op <"], simp_all add: less_imp_le)
done

lemma list_ord_le_sorted_eq: "list_asc xs = sorted xs"
apply (rule sym)
apply (simp add: list_asc_def)
apply (induct xs, simp)
apply (rename_tac x xs)
apply (simp add: list_ord_Cons sorted_Cons)
apply (case_tac "xs = []", simp_all)
apply (case_tac "list_ord op \<le> xs", simp_all)
apply (rule iffI)
 apply (drule_tac x="hd xs" in bspec, simp_all)
apply clarify
apply (drule in_set_conv_nth[THEN iffD1], clarsimp, rename_tac i1)
apply (simp add: hd_conv_nth)
apply (case_tac i1, simp)
apply (rename_tac i2)
apply simp
apply (fold list_asc_def)
thm list_asc_trans
apply (fastforce simp: list_asc_trans)
done
corollary list_asc_upto: "list_asc [m..n]"
by (simp add: list_ord_le_sorted_eq)

lemma list_strict_asc_upt: "list_strict_asc [m..<n]"
by (simp add: list_strict_asc_def list_ord_all_conv)
thm list_strict_asc_imp_list_asc[OF list_strict_asc_upt]


lemma list_ord_distinct_aux: "
  \<lbrakk> irrefl {(a, b). ord a b}; transP ord; list_ord ord xs; 
    i < length xs; j < length xs; i < j \<rbrakk> \<Longrightarrow> 
  xs ! i \<noteq> xs ! j"
apply (subgoal_tac "\<And>x y. ord x y \<Longrightarrow> x \<noteq> y")
 prefer 2
 apply (rule ccontr)
 apply (simp add: irrefl_def)
thm list_ord_trans
apply (simp add: list_ord_trans)
done
lemma list_ord_distinct: "
  \<lbrakk> irrefl {(a,b). ord a b}; transP ord; list_ord ord xs \<rbrakk> \<Longrightarrow> 
  distinct xs"
thm distinct_conv_nth
apply (simp add: distinct_conv_nth, intro allI impI, rename_tac i j)
apply (drule neq_iff[THEN iffD1], erule disjE)
thm list_ord_distinct_aux
 apply (simp add: list_ord_distinct_aux)
thm list_ord_distinct_aux[THEN not_sym]
apply (simp add: list_ord_distinct_aux[THEN not_sym])
done

lemma list_strict_asc_distinct: "list_strict_asc (xs::'a::preorder list) \<Longrightarrow> distinct xs"
apply (rule_tac ord="op <" in list_ord_distinct)
apply (unfold irrefl_def list_strict_asc_def trans_def)
apply (blast intro: less_trans)+
done
lemma list_strict_desc_distinct: "list_strict_desc (xs::'a::preorder list) \<Longrightarrow> distinct xs"
apply (rule_tac ord="op >" in list_ord_distinct)
apply (unfold irrefl_def list_strict_desc_def trans_def)
apply (blast intro: less_trans)+
done



subsubsection {* Additional definitions and results for sublists *}

primrec
  sublist_list :: "'a list \<Rightarrow> nat list \<Rightarrow> 'a list"
where
  "sublist_list xs [] = []"
| "sublist_list xs (y # ys) = (xs ! y) # (sublist_list xs ys)"

value "sublist_list [0::int,10::int,20,30,40,50] [1::nat,2,3]"
value "sublist_list [0::int,10::int,20,30,40,50] [1::nat,1,2,3]"
value "sublist_list [0::int,10::int,20,30,40,50] [1::nat,1,2,3,10]"


thm sublist_def
term "map fst (filter (\<lambda>p. snd p \<in> A) (zip xs [0..<length xs]))"
term "map fst ([p\<leftarrow>(zip xs [0..<length xs]). (snd p \<in> A)])"

lemma sublist_list_length: "length (sublist_list xs ys) = length ys"
by (induct ys, simp_all)

lemma sublist_list_append: "
 \<And>zs. sublist_list xs (ys @ zs) = sublist_list xs ys @ sublist_list xs zs"
by (induct ys, simp_all)

lemma sublist_list_Nil: "sublist_list xs [] =[]"
by simp

lemma sublist_list_is_Nil_conv: "
  (sublist_list xs ys = []) = (ys = [])"
apply (rule iffI)
 apply (rule ccontr)
 apply (clarsimp simp: neq_Nil_conv)
apply simp
done

lemma sublist_list_eq_imp_length_eq: "
  sublist_list xs ys = sublist_list xs zs \<Longrightarrow> length ys = length zs"
by (drule arg_cong[where f=length], simp add: sublist_list_length)

lemma sublist_list_nth: "
  \<And>n. n < length ys \<Longrightarrow> sublist_list xs ys ! n = xs ! (ys ! n)"
apply (induct ys, simp)
apply (case_tac n, simp_all)
done

lemma take_drop_eq_sublist_list: "
  m + n \<le> length xs \<Longrightarrow> xs \<up> m \<down> n = sublist_list xs [m..<m+n]"
apply (insert length_upt[of m "m+n"])
apply (simp add: expand_list_eq)
apply (simp add: sublist_list_length)
apply (frule add_le_imp_le_diff2)
apply (simp add: min_eqR)
apply (clarsimp, rename_tac i)
thm sublist_list_nth
apply (simp add: sublist_list_nth)
done



primrec
  sublist_list_if :: "'a list \<Rightarrow> nat list \<Rightarrow> 'a list"
where
  "sublist_list_if xs [] = []"
| "sublist_list_if xs (y # ys) =
    (if y < length xs then (xs ! y) # (sublist_list_if xs ys) 
     else (sublist_list_if xs ys))"

value "sublist_list_if [0::int,10::int,20,30,40,50] [1::nat,2,3]"
value "sublist_list_if [0::int,10::int,20,30,40,50] [1::nat,1,2,3]"
value "sublist_list_if [0::int,10::int,20,30,40,50] [1::nat,1,2,3,10]"

lemma sublist_list_if_sublist_list_filter_conv: "\<And>xs. 
  sublist_list_if xs ys = sublist_list xs (filter (\<lambda>i. i < length xs) ys)"
by (induct ys, simp+)
corollary sublist_list_if_sublist_list_eq: "\<And>xs.
  list_all (\<lambda>i. i < length xs) ys \<Longrightarrow>
  sublist_list_if xs ys = sublist_list xs ys"
by (simp add: sublist_list_if_sublist_list_filter_conv filter_list_all)
corollary sublist_list_if_sublist_list_eq2: "\<And>xs.
  \<forall>n<length ys. ys ! n < length xs \<Longrightarrow>
  sublist_list_if xs ys = sublist_list xs ys"
thm list_all_conv[THEN iffD2]
by (rule sublist_list_if_sublist_list_eq, rule list_all_conv[THEN iffD2])

lemma sublist_list_if_Nil_left: "sublist_list_if [] ys = []"
by (induct ys, simp+)
lemma sublist_list_if_Nil_right: "sublist_list_if xs [] = []"
by simp

lemma sublist_list_if_length: "
  length (sublist_list_if xs ys) = length (filter (\<lambda>i. i < length xs) ys)"
by (simp add: sublist_list_if_sublist_list_filter_conv sublist_list_length)
lemma sublist_list_if_append: "
  sublist_list_if xs (ys @ zs) = sublist_list_if xs ys @ sublist_list_if xs zs"
by (simp add: sublist_list_if_sublist_list_filter_conv sublist_list_append)
lemma sublist_list_if_snoc: "
  sublist_list_if xs (ys @ [y]) = sublist_list_if xs ys @ (if y < length xs then [xs ! y] else [])"
by (simp add: sublist_list_if_append)


lemma sublist_list_if_is_Nil_conv: "
  (sublist_list_if xs ys = []) = (list_all (\<lambda>i. length xs \<le> i) ys)"
by (simp add: sublist_list_if_sublist_list_filter_conv sublist_list_is_Nil_conv filter_empty_conv list_all_iff linorder_not_less)

lemma sublist_list_if_nth: "
  n < length ((filter (\<lambda>i. i < length xs) ys)) \<Longrightarrow> 
  sublist_list_if xs ys ! n = xs ! ((filter (\<lambda>i. i < length xs) ys) ! n)"
by (simp add: sublist_list_if_sublist_list_filter_conv sublist_list_nth)

lemma take_drop_eq_sublist_list_if: "
  m + n \<le> length xs \<Longrightarrow> xs \<up> m \<down> n = sublist_list_if xs [m..<m+n]"
thm take_drop_eq_sublist_list
by (simp add: sublist_list_if_sublist_list_filter_conv take_drop_eq_sublist_list)

lemma sublist_empty_conv: "(sublist xs I = []) = (\<forall>i\<in>I. length xs \<le> i)"
by (fastforce simp: set_empty[symmetric] set_sublist linorder_not_le[symmetric])

thm sublist_singleton
lemma sublist_singleton2: "sublist xs {y} = (if y < length xs then [xs ! y] else [])"
apply (unfold sublist_def)
apply (induct xs rule: rev_induct, simp)
apply (simp add: nth_append)
done

lemma sublist_take_eq: "
  \<lbrakk> finite I; Max I < n \<rbrakk> \<Longrightarrow> sublist (xs \<down> n) I = sublist xs I"
apply (case_tac "I = {}", simp)
apply (case_tac "n < length xs")
 prefer 2
 apply simp
thm append_take_drop_id
apply (rule_tac 
  t = "sublist xs I" and 
  s = "sublist (xs \<down> n @ xs \<up> n) I"
  in subst)
 apply simp
apply (subst sublist_append)
apply (simp add: min_eqR)
apply (rule_tac t="{j. j + n \<in> I}" and s="{}" in subst)
 apply blast
apply simp
done

lemma sublist_drop_eq: "
  n \<le> iMin I \<Longrightarrow> sublist (xs \<up> n) {j. j + n \<in> I} = sublist xs I"
apply (case_tac "I = {}", simp)
apply (case_tac "n < length xs")
 prefer 2
 apply (simp add: sublist_def filter_empty_conv linorder_not_less)
 apply (clarsimp, rename_tac a b)
 thm set_zip_rightD
 apply (drule set_zip_rightD)
 apply fastforce
apply (rule_tac 
  t = "sublist xs I" and 
  s = "sublist (xs \<down> n @ xs \<up> n) I"
  in subst)
 apply simp
apply (subst sublist_append)
apply (fastforce simp: sublist_empty_conv min_eqR)
done

lemma sublist_cut_less_eq: "
  length xs \<le> n \<Longrightarrow> sublist xs (I \<down>< n) = sublist xs I"
apply (simp add: sublist_def cut_less_mem_iff)
apply (rule_tac f="\<lambda>xs. map fst xs" in arg_cong)
thm filter_filter_eq
apply (rule filter_filter_eq)
apply (simp add: list_all_conv)
done

lemma sublist_disjoint_Un: "
  \<lbrakk> finite A; Max A < iMin B \<rbrakk> \<Longrightarrow> sublist xs (A \<union> B) = sublist xs A @ sublist xs B"
apply (case_tac "A = {}", simp)
apply (case_tac "B = {}", simp)
apply (case_tac "length xs \<le> iMin B")
 thm sublist_cut_less_eq
 apply (subst sublist_cut_less_eq[of xs "iMin B", symmetric], assumption)
 apply (simp (no_asm_simp) add: cut_less_Un cut_less_Min_empty cut_less_Max_all)
 apply (simp add: sublist_empty_conv iMin_ge_iff)
apply (simp add: linorder_not_le)
thm sublist_append
apply (rule_tac 
  t = "sublist xs (A \<union> B)" and 
  s = "sublist (xs \<down> (iMin B) @ xs \<up> (iMin B)) (A \<union> B)"
  in subst)
 apply simp
apply (subst sublist_append)
apply (simp add: min_eqR)
thm sublist_cut_less_eq
apply (subst sublist_cut_less_eq[where xs="xs \<down> iMin B" and n="iMin B", symmetric], simp)
apply (simp add: cut_less_Un cut_less_Min_empty cut_less_Max_all)
thm sublist_take_eq
apply (simp add: sublist_take_eq)
apply (rule_tac 
  t = "\<lambda>j. j + iMin B \<in> A \<or> j + iMin B \<in> B" and
  s = "\<lambda>j. j + iMin B \<in> B"
  in subst)
 apply (force simp: fun_eq_iff)
thm sublist_drop_eq
apply (simp add: sublist_drop_eq)
done
corollary sublist_disjoint_insert_left: "
  \<lbrakk> finite I; x < iMin I \<rbrakk> \<Longrightarrow> sublist xs (insert x I) = sublist xs {x} @ sublist xs I"
apply (rule_tac t="insert x I" and s="{x} \<union> I" in subst, simp)
apply (subst sublist_disjoint_Un)
apply simp_all
done
corollary sublist_disjoint_insert_right: "
  \<lbrakk> finite I; Max I < x \<rbrakk> \<Longrightarrow> sublist xs (insert x I) = sublist xs I @ sublist xs {x}"
apply (rule_tac t="insert x I" and s="I \<union> {x}" in subst, simp)
apply (subst sublist_disjoint_Un)
apply simp_all
done

lemma sublist_all: "{..<length xs} \<subseteq> I \<Longrightarrow> sublist xs I = xs"
apply (case_tac "xs = []", simp)
apply (rule_tac
  t = "I" and 
  s = "I \<down>< (length xs) \<union> I \<down>\<ge> (length xs)"
  in subst)
 apply (simp add: cut_less_cut_ge_ident)
apply (rule_tac
  t = "I \<down>< length xs" and
  s = "{..<length xs}"
  in subst)
 apply blast
apply (case_tac "I \<down>\<ge> (length xs) = {}", simp)
apply (subst sublist_disjoint_Un[OF finite_lessThan])
 apply (rule less_imp_Max_less_iMin[OF finite_lessThan])
   apply blast
  apply blast
 apply (blast intro: less_le_trans)
apply (fastforce simp: sublist_empty_conv)
done
corollary sublist_UNIV: "sublist xs UNIV = xs"
by (rule sublist_all[OF subset_UNIV])

lemma sublist_list_sublist_eq: "\<And>xs.
  list_strict_asc ys \<Longrightarrow> sublist_list_if xs ys = sublist xs (set ys)"
apply (case_tac "xs = []")
 apply (simp add: sublist_list_if_Nil_left)
apply (induct ys rule: rev_induct, simp)
apply (rename_tac y ys xs)
apply (case_tac "ys = []")
 apply (simp add: sublist_singleton2)
apply (unfold list_strict_asc_def)
apply (simp add: sublist_list_if_snoc split del: split_if)
thm list_ord_append
apply (frule list_ord_append[THEN iffD1])
apply (clarsimp split del: split_if)
apply (subst sublist_disjoint_insert_right)
  apply simp
 apply (clarsimp simp: in_set_conv_nth, rename_tac i) 
 thm list_strict_asc_trans[unfolded list_strict_asc_def, THEN iffD1, rule_format]
 apply (drule_tac i=i and j="length ys" in list_strict_asc_trans[unfolded list_strict_asc_def, THEN iffD1, rule_format])
 apply (simp add: nth_append split del: split_if)+
apply (simp add: sublist_singleton2)
done
lemma set_sublist_list_if: "\<And>xs. set (sublist_list_if xs ys) = {xs ! i |i. i < length xs \<and> i \<in> set ys}"
apply (induct ys, simp_all)
apply blast
done

lemma set_sublist_list: "
  list_all (\<lambda>i. i < length xs) ys \<Longrightarrow>
  set (sublist_list xs ys) = {xs ! i |i. i < length xs \<and> i \<in> set ys}"
by (simp add: sublist_list_if_sublist_list_eq[symmetric] set_sublist_list_if)

lemma set_sublist_list_if_eq_set_sublist: "set (sublist_list_if xs ys) = set (sublist xs (set ys))"
by (simp add: set_sublist set_sublist_list_if)
lemma set_sublist_list_eq_set_sublist: "
  list_all (\<lambda>i. i < length xs) ys \<Longrightarrow>
  set (sublist_list xs ys) = set (sublist xs (set ys))"
by (simp add: sublist_list_if_sublist_list_eq[symmetric] set_sublist_list_if_eq_set_sublist)






subsubsection {* Natural set images with lists *}

definition 
  f_image :: "'a list \<Rightarrow> nat set \<Rightarrow> 'a set"      (infixr "`\<^sup>f" 90) 
where
  "xs `\<^sup>f A \<equiv> {y. \<exists>n\<in>A. n < length xs \<and> y = xs ! n }"

abbreviation
  f_range :: "'a list \<Rightarrow> 'a set" 
where
  "f_range xs \<equiv> f_image xs UNIV"

thm Set.image_eqI
lemma f_image_eqI[simp, intro]: "
  \<lbrakk> x = xs ! n; n \<in> A; n < length xs \<rbrakk> \<Longrightarrow> x \<in> xs `\<^sup>f A"
by (unfold f_image_def, blast)

thm Set.imageI
lemma f_imageI: "\<lbrakk> n \<in> A; n < length xs \<rbrakk> \<Longrightarrow> xs ! n \<in> xs `\<^sup>f A"
by blast

thm Set.rev_image_eqI
lemma rev_f_imageI: "\<lbrakk> n \<in> A; n < length xs; x = xs ! n \<rbrakk> \<Longrightarrow> x \<in> xs `\<^sup>f A"
by (rule f_image_eqI)

thm Set.imageE
lemma f_imageE[elim!]: "
  \<lbrakk> x \<in> xs `\<^sup>f A; \<And>n. \<lbrakk> x = xs ! n; n \<in> A; n < length xs \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
by (unfold f_image_def, blast)

thm Set.image_Un
lemma f_image_Un: "xs `\<^sup>f (A \<union> B) = xs `\<^sup>f A \<union> xs `\<^sup>f B"
by blast

thm Set.image_mono
lemma f_image_mono: "A \<subseteq> B ==> xs `\<^sup>f A \<subseteq> xs `\<^sup>f B"
by blast

thm Set.image_iff
lemma f_image_iff: "(x \<in> xs `\<^sup>f A) = (\<exists>n\<in>A. n < length xs \<and> x = xs ! n)"
by blast

thm Set.image_subset_iff
lemma f_image_subset_iff: "
  (xs `\<^sup>f A \<subseteq> B) = (\<forall>n\<in>A. n < length xs \<longrightarrow> xs ! n \<in> B)"
by blast
thm Set.subset_image_iff
lemma subset_f_image_iff: "(B \<subseteq> xs `\<^sup>f A) = (\<exists>A'\<subseteq>A. B = xs `\<^sup>f A')"
apply (rule iffI)
 apply (rule_tac x="{ n. n \<in> A \<and> n < length xs \<and> xs ! n \<in> B }" in exI)
 apply blast
apply (blast intro: f_image_mono)
done

thm image_subsetI
lemma f_image_subsetI: "
  \<lbrakk> \<And>n. n \<in> A \<and> n < length xs \<Longrightarrow> xs ! n \<in> B \<rbrakk> \<Longrightarrow> xs `\<^sup>f A \<subseteq> B"
by blast

thm Set.image_empty
lemma f_image_empty: "xs `\<^sup>f {} = {}"
by blast

thm Set.image_insert
lemma f_image_insert_if: "
  xs `\<^sup>f (insert n A) = (
  if n < length xs then insert (xs ! n) (xs `\<^sup>f A) else (xs `\<^sup>f A))"
by (split split_if, blast)
lemma f_image_insert_eq1: "
  n < length xs \<Longrightarrow> xs `\<^sup>f (insert n A) = insert (xs ! n) (xs `\<^sup>f A)"
by (simp add: f_image_insert_if)
lemma f_image_insert_eq2: "
  length xs \<le> n \<Longrightarrow> xs `\<^sup>f (insert n A) = (xs `\<^sup>f A)"
by (simp add: f_image_insert_if)

thm Set.insert_image
lemma insert_f_image: "
  \<lbrakk> n \<in> A; n < length xs \<rbrakk> \<Longrightarrow> insert (xs ! n) (xs `\<^sup>f A) = (xs `\<^sup>f A)"
by blast
thm Set.image_is_empty
lemma f_image_is_empty: "(xs `\<^sup>f A = {}) = ({x. x \<in> A \<and> x < length xs} = {})"
by blast

thm Set.image_Collect
lemma f_image_Collect: "xs `\<^sup>f {n. P n} = {xs ! n |n. P n \<and> n < length xs}"
by blast


lemma f_image_eq_set: "\<forall>n<length xs. n \<in> A \<Longrightarrow> xs `\<^sup>f A = set xs"
by (fastforce simp: in_set_conv_nth)
lemma f_range_eq_set: "f_range xs = set xs"
by (simp add: f_image_eq_set)

lemma f_image_eq_set_sublist: "xs `\<^sup>f A = set (sublist xs A)"
by (unfold set_sublist, blast)
lemma f_image_eq_set_sublist_list_if: "xs `\<^sup>f (set ys) = set (sublist_list_if xs ys)"
by (simp add: set_sublist_list_if_eq_set_sublist f_image_eq_set_sublist)
lemma f_image_eq_set_sublist_list: "
  list_all (\<lambda>i. i < length xs) ys \<Longrightarrow> xs `\<^sup>f (set ys) = set (sublist_list xs ys)"
by (simp add: sublist_list_if_sublist_list_eq f_image_eq_set_sublist_list_if)





thm Set.range_eqI
lemma f_range_eqI: "\<lbrakk> x = xs ! n; n < length xs \<rbrakk> \<Longrightarrow> x \<in> f_range xs"
by blast
thm Set.rangeI
lemma f_rangeI: "n < length xs \<Longrightarrow> xs ! n \<in> f_range xs"
by blast
thm Set.rangeE
lemma f_rangeE[elim?]: "
  \<lbrakk> x \<in> f_range xs; \<And>n. \<lbrakk> n < length xs; x = xs ! n \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
by blast



subsubsection {* Mapping lists of functions to lists *}

primrec
  map_list :: "('a \<Rightarrow> 'b) list \<Rightarrow> 'a list \<Rightarrow> 'b list"
where
  "map_list [] xs = []"
| "map_list (f # fs) xs = f (hd xs) # map_list fs (tl xs)"

lemma map_list_Nil: "map_list [] xs = []"
by simp
lemma map_list_Cons_Cons: "
  map_list (f # fs) (x # xs) =
  (f x) # map_list fs xs"
by simp

lemma map_list_length: "\<And>xs.
  length (map_list fs xs) = length fs"
by (induct fs, simp+)
corollary map_list_empty_conv: "
  (map_list fs xs = []) = (fs = [])"
by (simp del: length_0_conv add: length_0_conv[symmetric] map_list_length)
corollary map_list_not_empty_conv: "
  (map_list fs xs \<noteq> []) = (fs \<noteq> [])"
by (simp add: map_list_empty_conv)

lemma map_list_nth: "\<And>n xs. 
  \<lbrakk> n < length fs; n < length xs \<rbrakk> \<Longrightarrow>
  (map_list fs xs ! n) =
  (fs ! n) (xs ! n)"
apply (induct fs, simp+)
apply (case_tac n)
 apply (simp add: hd_conv_nth)
apply (simp add: nth_tl_eq_nth_Suc2)
done

lemma map_list_xs_take: "\<And>n xs.
  length fs \<le> n \<Longrightarrow>
  map_list fs (xs \<down> n) =
  map_list fs xs"
apply (induct fs, simp+)
apply (rename_tac f fs n xs)
apply (simp add: tl_take)
thm arg_cong
apply (rule_tac f=f in arg_cong)
apply (case_tac "xs = []", simp)
apply (simp add: hd_conv_nth)
done

lemma map_list_take: "\<And>n xs. 
  (map_list fs xs) \<down> n =
  (map_list (fs \<down> n) xs)"
apply (induct fs, simp)
apply (case_tac n, simp+)
done
lemma map_list_take_take: "\<And>n xs. 
  (map_list fs xs) \<down> n =
  (map_list (fs \<down> n) (xs \<down> n))"
by (simp add: map_list_take map_list_xs_take)
lemma map_list_drop: "\<And>n xs. 
  (map_list fs xs) \<up> n =
  (map_list (fs \<up> n) (xs \<up> n))"
apply (induct fs, simp)
apply (case_tac n)
apply (simp add: drop_Suc)+
done



lemma map_list_append_append: "\<And>xs1 .
  length fs1 = length xs1 \<Longrightarrow>
  map_list (fs1 @ fs2) (xs1 @ xs2) =
  map_list fs1 xs1 @
  map_list fs2 xs2"
apply (induct fs1, simp+)
apply (case_tac "xs1", simp+)
done
lemma map_list_snoc_snoc: "
  length fs = length xs \<Longrightarrow>
  map_list (fs @ [f]) (xs @ [x]) =
  map_list fs xs @ [f x]"
by (simp add: map_list_append_append)
lemma map_list_snoc: "\<And>xs.
  length fs < length xs \<Longrightarrow>
  map_list (fs @ [f]) xs =
  map_list fs xs @  [f (xs ! (length fs))]"
apply (induct fs)
 apply (simp add: hd_conv_nth)
apply (simp add: nth_tl_eq_nth_Suc2)
done


lemma map_list_Cons_if: "
  map_list fs (x # xs) =
  (if (fs = []) then [] else (
    ((hd fs) x) # map_list (tl fs) xs))"
by (case_tac "fs", simp+)
lemma map_list_Cons_not_empty: "
  fs \<noteq> [] \<Longrightarrow>
  map_list fs (x # xs) =
  ((hd fs) x) # map_list (tl fs) xs"
by (simp add: map_list_Cons_if)

lemma map_eq_map_list_take: "\<And>xs.
  \<lbrakk> length fs \<le> length xs; list_all (\<lambda>x. x = f) fs \<rbrakk> \<Longrightarrow> 
  map_list fs xs = map f (xs \<down> length fs)"
apply (induct fs, simp+)
apply (case_tac xs, simp+)
done
lemma map_eq_map_list_take2: "
  \<lbrakk> length fs = length xs; list_all (\<lambda>x. x = f) fs \<rbrakk> \<Longrightarrow> 
  map_list fs xs = map f xs"
by (simp add: map_eq_map_list_take)
lemma map_eq_map_list_replicate: "
  map_list (f\<^bsup>length xs\<^esup>) xs = map f xs"
by (induct xs, simp+)




subsubsection {* Mapping functions with two arguments to lists *}

primrec map2 :: "
  (* Function taking two parameters *)
  ('a \<Rightarrow> 'b \<Rightarrow> 'c) \<Rightarrow>
  (* Lists of parameters *)
  'a list \<Rightarrow> 'b list \<Rightarrow> 
  'c list" 
where
  "map2 f [] ys = []"
| "map2 f (x # xs) ys = f x (hd ys) # map2 f xs (tl ys)"


lemma map2_map_list_conv: "\<And>ys. map2 f xs ys = map_list (map f xs) ys"
by (induct xs, simp+)

lemma map2_Nil: "map2 f [] ys = []"
by simp
lemma map2_Cons_Cons: "
  map2 f (x # xs) (y # ys) =
  (f x y) # map2 f xs ys"
by simp

lemma map2_length: "\<And>ys. length (map2 f xs ys) = length xs"
by (induct xs, simp+)
corollary map2_empty_conv: "
  (map2 f xs ys = []) = (xs = [])"
by (simp del: length_0_conv add: length_0_conv[symmetric] map2_length)
corollary map2_not_empty_conv: "
  (map2 f xs ys \<noteq> []) = (xs \<noteq> [])"
by (simp add: map2_empty_conv)

lemma map2_nth: "\<And>n ys. 
  \<lbrakk> n < length xs; n < length ys \<rbrakk> \<Longrightarrow>
  (map2 f xs ys ! n) =
  f (xs ! n) (ys ! n)"
thm map_list_nth
by (simp add: map2_map_list_conv map_list_nth)

lemma map2_ys_take: "\<And>n ys.
  length xs \<le> n \<Longrightarrow>
  map2 f xs (ys \<down> n) =
  map2 f xs ys"
thm map_list_xs_take
by (simp add: map2_map_list_conv map_list_xs_take)

lemma map2_take: "\<And>n ys. 
  (map2 f xs ys) \<down> n =
  (map2 f (xs \<down> n) ys)"
thm map_list_take
by (simp add: map2_map_list_conv take_map map_list_take)
lemma map2_take_take: "\<And>n ys. 
  (map2 f xs ys) \<down> n =
  (map2 f (xs \<down> n) (ys \<down> n))"
by (simp add: map2_take map2_ys_take)
lemma map2_drop: "\<And>n ys. 
  (map2 f xs ys) \<up> n =
  (map2 f (xs \<up> n) (ys \<up> n))"
thm map_list_drop
by (simp add: map2_map_list_conv map_list_drop drop_map)


lemma map2_append_append: "\<And>ys1 .
  length xs1 = length ys1 \<Longrightarrow>
  map2 f (xs1 @ xs2) (ys1 @ ys2) =
  map2 f xs1 ys1 @
  map2 f xs2 ys2"
thm map_list_append_append
by (simp add: map2_map_list_conv map_list_append_append)
lemma map2_snoc_snoc: "
  length xs = length ys \<Longrightarrow>
  map2 f (xs @ [x]) (ys @ [y]) =
  map2 f xs ys @
  [f x y]"
by (simp add: map2_append_append)
lemma map2_snoc: "\<And>ys.
  length xs < length ys \<Longrightarrow>
  map2 f (xs @ [x]) ys =
  map2 f xs ys @ 
  [f x (ys ! (length xs))]"
thm map_list_snoc
by (simp add: map2_map_list_conv map_list_snoc)

lemma map2_Cons_if: "
  map2 f xs (y # ys) =
  (if (xs = []) then [] else (
    (f (hd xs) y) # map2 f (tl xs) ys))"
by (case_tac "xs", simp+)
lemma map2_Cons_not_empty: "
  xs \<noteq> [] \<Longrightarrow>
  map2 f xs (y # ys) =
  (f (hd xs) y) # map2 f (tl xs) ys"
by (simp add: map2_Cons_if)

lemma map2_append1_take_drop: "
  length xs1 \<le> length ys \<Longrightarrow>
  map2 f (xs1 @ xs2) ys =
  map2 f xs1 (ys \<down> length xs1) @
  map2 f xs2 (ys \<up> length xs1)"
thm map2_append_append
thm append_take_drop_id
apply (rule_tac 
  t = "map2 f (xs1 @ xs2) ys" and
  s = "map2 f (xs1 @ xs2) (ys \<down> length xs1 @ ys \<up> length xs1)"
  in subst)
 apply simp
apply (simp add: map2_append_append del: append_take_drop_id)
done
lemma map2_append2_take_drop: "
  length ys1 \<le> length xs \<Longrightarrow>
  map2 f xs (ys1 @ ys2) =
  map2 f (xs \<down> length ys1) ys1 @
  map2 f (xs \<up> length ys1) ys2"
apply (rule_tac 
  t = "map2 f xs (ys1 @ ys2)" and
  s = "map2 f (xs \<down> length ys1 @ xs \<up> length ys1) (ys1 @ ys2)"
  in subst)
 apply simp
apply (simp add: map2_append_append del: append_take_drop_id)
done

thm List.map_cong
lemma map2_cong: "
  \<lbrakk> xs1 = xs2; ys1 = ys2; length xs2 \<le> length ys2; 
    \<And>x y. \<lbrakk> x \<in> set xs2; y \<in> set ys2 \<rbrakk> \<Longrightarrow> f x y = g x y \<rbrakk> \<Longrightarrow>
  map2 f xs1 ys1 = map2 g xs2 ys2"
by (simp (no_asm_simp) add: expand_list_eq map2_length map2_nth)

thm List.map_eq_conv
lemma map2_eq_conv: "
  length xs \<le> length ys \<Longrightarrow>
  (map2 f xs ys = map2 g xs ys) = (\<forall>i<length xs. f (xs ! i) (ys ! i) = g (xs ! i) (ys ! i))"
by (simp add: expand_list_eq map2_length map2_nth)

thm List.map_replicate
lemma map2_replicate: "map2 f x\<^bsup>n\<^esup> y\<^bsup>n\<^esup> = (f x y)\<^bsup>n\<^esup>"
by (induct n, simp+)

lemma map2_zip_conv: "\<And>ys.
  length xs \<le> length ys \<Longrightarrow> 
  map2 f xs ys = map (\<lambda>(x,y). f x y) (zip xs ys)"
apply (induct xs, simp)
apply (case_tac ys, simp+)
done

lemma map2_rev: "\<And>ys.
  length xs = length ys \<Longrightarrow>
  rev (map2 f xs ys) = map2 f (rev xs) (rev ys)"
apply (induct xs, simp)
apply (case_tac ys, simp)
apply (simp add: map2_Cons_Cons map2_snoc_snoc)
done


end