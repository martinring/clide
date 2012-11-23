(* Author: Tobias Nipkow *)

theory Abs_Int_den2
imports Abs_Int_den1_ivl
begin

context preord
begin

definition mono where "mono f = (\<forall>x y. x \<sqsubseteq> y \<longrightarrow> f x \<sqsubseteq> f y)"

lemma monoD: "mono f \<Longrightarrow> x \<sqsubseteq> y \<Longrightarrow> f x \<sqsubseteq> f y" by(simp add: mono_def)

lemma mono_comp: "mono f \<Longrightarrow> mono g \<Longrightarrow> mono (g o f)"
by(simp add: mono_def)

declare le_trans[trans]

end


subsection "Widening and Narrowing"

text{* Jumping to the trivial post-fixed point @{const Top} in case @{text k}
rounds of iteration did not reach a post-fixed point (as in @{const iter}) is
a trivial widening step. We generalise this idea and complement it with
narrowing, a process to regain precision.

Class @{text WN} makes some assumptions about the widening and narrowing
operators. The assumptions serve two purposes. Together with a further
assumption that certain chains become stationary, they permit to prove
termination of the fixed point iteration, which we do not --- we limit the
number of iterations as before. The second purpose of the narrowing
assumptions is to prove that the narrowing iteration keeps on producing
post-fixed points and that it goes down. However, this requires the function
being iterated to be monotone. Unfortunately, abstract interpretation with
widening is not monotone. Hence the (recursive) abstract interpretation of a
loop body that again contains a loop may result in a non-monotone
function. Therefore our narrowing iteration needs to check at every step
that a post-fixed point is maintained, and we cannot prove that the precision
increases. *}

class WN = SL_top +
fixes widen :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" (infix "\<nabla>" 65)
assumes widen: "y \<sqsubseteq> x \<nabla> y"
fixes narrow :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" (infix "\<triangle>" 65)
assumes narrow1: "y \<sqsubseteq> x \<Longrightarrow> y \<sqsubseteq> x \<triangle> y"
assumes narrow2: "y \<sqsubseteq> x \<Longrightarrow> x \<triangle> y \<sqsubseteq> x"
begin

fun iter_up :: "('a \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a" where
"iter_up f 0 x = Top" |
"iter_up f (Suc n) x =
  (let fx = f x in if fx \<sqsubseteq> x then x else iter_up f n (x \<nabla> fx))"

lemma iter_up_pfp: "f(iter_up f n x) \<sqsubseteq> iter_up f n x"
apply (induction n arbitrary: x)
 apply (simp)
apply (simp add: Let_def)
done

fun iter_down :: "('a \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a" where
"iter_down f 0 x = x" |
"iter_down f (Suc n) x =
  (let y = x \<triangle> f x in if f y \<sqsubseteq> y then iter_down f n y else x)"

lemma iter_down_pfp: "f x \<sqsubseteq> x \<Longrightarrow> f(iter_down f n x) \<sqsubseteq> iter_down f n x"
apply (induction n arbitrary: x)
 apply (simp)
apply (simp add: Let_def)
done

definition iter' :: "nat \<Rightarrow> nat \<Rightarrow> ('a \<Rightarrow> 'a) \<Rightarrow> 'a \<Rightarrow> 'a" where
"iter' m n f x =
  (let f' = (\<lambda>y. x \<squnion> f y) in iter_down f' n (iter_up f' m x))"

lemma iter'_pfp_above:
shows "f(iter' m n f x0) \<sqsubseteq> iter' m n f x0"
and "x0 \<sqsubseteq> iter' m n f x0"
using iter_up_pfp[of "\<lambda>x. x0 \<squnion> f x"] iter_down_pfp[of "\<lambda>x. x0 \<squnion> f x"]
by(auto simp add: iter'_def Let_def)

text{* This is how narrowing works on monotone functions: you just iterate. *}

abbreviation iter_down_mono :: "('a \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> 'a" where
"iter_down_mono f n x == ((\<lambda>x. x \<triangle> f x)^^n) x"

text{* Narrowing always yields a post-fixed point: *}

lemma iter_down_mono_pfp: assumes "mono f" and "f x0 \<sqsubseteq> x0" 
defines "x n == iter_down_mono f n x0"
shows "f(x n) \<sqsubseteq> x n"
proof (induction n)
  case 0 show ?case by (simp add: x_def assms(2))
next
  case (Suc n)
  have "f (x (Suc n)) = f(x n \<triangle> f(x n))" by(simp add: x_def)
  also have "\<dots> \<sqsubseteq> f(x n)" by(rule monoD[OF `mono f` narrow2[OF Suc]])
  also have "\<dots> \<sqsubseteq> x n \<triangle> f(x n)" by(rule narrow1[OF Suc])
  also have "\<dots> = x(Suc n)" by(simp add: x_def)
  finally show ?case .
qed

text{* Narrowing can only increase precision: *}

lemma iter_down_down: assumes "mono f" and "f x0 \<sqsubseteq> x0" 
defines "x n == iter_down_mono f n x0"
shows "x n \<sqsubseteq> x0"
proof (induction n)
  case 0 show ?case by(simp add: x_def)
next
  case (Suc n)
  have "x(Suc n) = x n \<triangle> f(x n)" by(simp add: x_def)
  also have "\<dots> \<sqsubseteq> x n" unfolding x_def
    by(rule narrow2[OF iter_down_mono_pfp[OF assms(1), OF assms(2)]])
  also have "\<dots> \<sqsubseteq> x0" by(rule Suc)
  finally show ?case .
qed


end


instantiation ivl :: WN
begin

definition "widen_ivl ivl1 ivl2 =
  ((*if is_empty ivl1 then ivl2 else if is_empty ivl2 then ivl1 else*)
     case (ivl1,ivl2) of (I l1 h1, I l2 h2) \<Rightarrow>
       I (if le_option False l2 l1 \<and> l2 \<noteq> l1 then None else l2)
         (if le_option True h1 h2 \<and> h1 \<noteq> h2 then None else h2))"

definition "narrow_ivl ivl1 ivl2 =
  ((*if is_empty ivl1 \<or> is_empty ivl2 then empty else*)
     case (ivl1,ivl2) of (I l1 h1, I l2 h2) \<Rightarrow>
       I (if l1 = None then l2 else l1)
         (if h1 = None then h2 else h1))"

instance
proof qed
  (auto simp add: widen_ivl_def narrow_ivl_def le_option_def le_ivl_def empty_def split: ivl.split option.split if_splits)

end

instantiation astate :: (WN) WN
begin

definition "widen_astate F1 F2 =
  FunDom (\<lambda>x. fun F1 x \<nabla> fun F2 x) (inter_list (dom F1) (dom F2))"

definition "narrow_astate F1 F2 =
  FunDom (\<lambda>x. fun F1 x \<triangle> fun F2 x) (inter_list (dom F1) (dom F2))"

instance
proof
  case goal1 thus ?case
    by(simp add: widen_astate_def le_astate_def lookup_def widen)
next
  case goal2 thus ?case
    by(auto simp: narrow_astate_def le_astate_def lookup_def narrow1)
next
  case goal3 thus ?case
    by(auto simp: narrow_astate_def le_astate_def lookup_def narrow2)
qed

end

instantiation up :: (WN) WN
begin

fun widen_up where
"widen_up bot x = x" |
"widen_up x bot = x" |
"widen_up (Up x) (Up y) = Up(x \<nabla> y)"

fun narrow_up where
"narrow_up bot x = bot" |
"narrow_up x bot = bot" |
"narrow_up (Up x) (Up y) = Up(x \<triangle> y)"

instance
proof
  case goal1 show ?case
    by(induct x y rule: widen_up.induct) (simp_all add: widen)
next
  case goal2 thus ?case
    by(induct x y rule: narrow_up.induct) (simp_all add: narrow1)
next
  case goal3 thus ?case
    by(induct x y rule: narrow_up.induct) (simp_all add: narrow2)
qed

end

interpretation
  Abs_Int1 rep_ivl num_ivl plus_ivl filter_plus_ivl filter_less_ivl "(iter' 3 2)"
defines afilter_ivl' is afilter
and bfilter_ivl' is bfilter
and AI_ivl' is AI
and aval_ivl' is aval'
proof qed (auto simp: iter'_pfp_above)

value [code] "list_up(AI_ivl' test3_ivl Top)"
value [code] "list_up(AI_ivl' test4_ivl Top)"
value [code] "list_up(AI_ivl' test5_ivl Top)"

end
