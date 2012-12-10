header {* Auxiliary Lemmas *}
theory Auxiliarities
imports Multivariate_Analysis
begin

subsection {* Euclidean Components *}

lemma sqrt_le_rsquare:
  assumes "\<bar>x\<bar> \<le> sqrt y"
  shows "x\<twosuperior> \<le> y"
  using assms real_sqrt_le_iff[of "x\<twosuperior>"] by simp

lemma fst_eq_component_zero':
  shows "fst (x, y) = (x, y) $$ 0" 
  by (simp add: euclidean_component_def basis_prod_def)

lemma snd_eq_component_plus':
  fixes x::"'a::euclidean_space"
  shows "snd (x, y) $$ i = (x, y) $$ (i + DIM('a))" 
  by (simp add: euclidean_component_def basis_prod_def)

lemma snd_eq_component_plus:
  fixes x::"real\<times>'a::euclidean_space"
  shows "snd x $$ i = x $$ (Suc i)" 
  using snd_eq_component_plus'[of "fst x" "snd x"]
  by simp

lemma pair_component_ifthenelse:
  fixes x::"'a::euclidean_space" and y::"'b::euclidean_space"
  shows "(x, y) $$ i = (if i < DIM('a) then x $$ i else y $$ (i - DIM('a)))"
  by (simp add: euclidean_component_def basis_prod_def)

lemma fst_eq_component_zero:
  shows "fst x = x $$ 0"
  using fst_eq_component_zero'[of "fst x" "snd x"]
  by simp

lemma setsum_ge_element:
  fixes f::"'a \<Rightarrow> ('b::ordered_comm_monoid_add)"
  assumes "finite s"
  assumes "i \<in> s"
  assumes "\<And>i. i \<in> s \<Longrightarrow> f i \<ge> 0"
  assumes "el = f i"
  shows "el \<le> setsum f s"
proof -
  have "el = setsum f {i}" by (simp add: assms)
  also have "... \<le> setsum f s" using assms by (intro setsum_mono2) auto
  finally show ?thesis .
qed

lemma norm_nth_le:
  fixes x::"'a::euclidean_space"
  assumes "i < DIM('a)"
  shows "norm (x $$ i) \<le> norm x"
  unfolding norm_conv_dist euclidean_dist_l2[of x] setL2_def
  by (auto intro!: real_le_rsqrt setsum_ge_element assms)

subsection {* Pairs *}

subsubsection {* Ordering on Pairs *}

lemma pair_le_intro[intro]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "a1 \<le> b1" "a2 \<le> b2"
  shows "(a1, a2) \<le> (b1, b2)"
  using assms
  by (auto simp add: eucl_le[of "(a1, a2)"] eucl_le[of a1] eucl_le[of a2]
    pair_component_ifthenelse)

lemma pair_le_elim1:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) \<le> (b1, b2)"
  shows "a1 \<le> b1"
  using assms
  by (auto simp add: pair_component_ifthenelse
    eucl_le[of a1 b1] eucl_le[of a2 b2] eucl_le[of "(a1, a2)" "(b1, b2)"]
    split: split_if_asm)

lemma pair_le_elim2:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) \<le> (b1, b2)"
  shows "a2 \<le> b2"
proof -
  { fix i assume "i < DIM('b)"
    with assms have "snd (a1, a2) $$ i \<le> snd (b1, b2) $$ i"
      unfolding snd_eq_component_plus'
      by (simp add: eucl_le[of "(a1, a2)" "(b1, b2)"])
  }
  thus ?thesis
  unfolding eucl_le[of a2 b2] by simp
qed

lemma pair_le_elim[elim]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) \<le> (b1, b2)"
  shows "a1 \<le> b1" and "a2 \<le> b2"
using assms
by (auto elim: pair_le_elim1 pair_le_elim2)

lemma pair_interval_ne_empty:
  assumes "{a1..a2} \<noteq> {}"
  assumes "{b1..b2} \<noteq> {}"
  shows "{(a1, b1)..(a2, b2)} \<noteq> {}"
  using assms
  by (simp add: interval_ne_empty pair_component_ifthenelse)

lemma pair_le_iff[simp]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  shows "(a1, a2) \<le> (b1, b2) \<longleftrightarrow> a1 \<le> b1 \<and> a2 \<le> b2"
  using pair_le_elim1 pair_le_elim2 pair_le_intro by auto

lemma pair_less_intro[intro]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "a1 < b1" "a2 < b2"
  shows "(a1, a2) < (b1, b2)"
  using assms
  by (auto simp add: eucl_less[of "(a1, a2)"] eucl_less[of a1] eucl_less[of a2]
    pair_component_ifthenelse)

lemma pair_less_elim1:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) < (b1, b2)"
  shows "a1 < b1"
  using assms
  by (auto simp add: pair_component_ifthenelse
    eucl_less[of a1 b1] eucl_less[of a2 b2] eucl_less[of "(a1, a2)" "(b1, b2)"]
    split: split_if_asm)

lemma pair_less_elim2:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) < (b1, b2)"
  shows "a2 < b2"
proof -
  { fix i assume "i < DIM('b)"
    with assms have "snd (a1, a2) $$ i < snd (b1, b2) $$ i"
      unfolding snd_eq_component_plus'
      by (simp add: eucl_less[of "(a1, a2)" "(b1, b2)"])
  }
  thus ?thesis
  unfolding eucl_less[of a2 b2] by simp
qed

lemma pair_less_elim[elim]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  assumes "(a1, a2) < (b1, b2)"
  shows "a1 < b1" and "a2 < b2"
using assms
by (auto elim: pair_less_elim1 pair_less_elim2)

lemma pair_less_iff[simp]:
  fixes a1 b1::"'a::ordered_euclidean_space"
  fixes a2 b2::"'b::ordered_euclidean_space"
  shows "(a1, a2) < (b1, b2) \<longleftrightarrow> a1 < b1 \<and> a2 < b2"
  using pair_less_elim1 pair_less_elim2 pair_less_intro by auto

lemma pair_interval_iff[simp]: "{(a1, a2)..(b1, b2)} = {a1..b1}\<times>{a2..b2}" by auto

subsubsection {* Continuity of Pair-function *}

lemma continuous_on_fst: "continuous_on X fst"
  unfolding continuous_on_def
  by (intro ballI tendsto_intros)

lemma continuous_on_snd: "continuous_on X snd"
  unfolding continuous_on_def
  by (intro ballI tendsto_intros)

lemma continuous_at_fst:
  fixes x::"'a::euclidean_space \<times> 'b::euclidean_space"
  shows "continuous (at x) fst"
  unfolding continuous_def netlimit_at
  by (intro tendsto_intros)

lemma continuous_at_snd:
  fixes x::"'a::euclidean_space \<times> 'b::euclidean_space"
  shows "continuous (at x) snd"
  unfolding continuous_def netlimit_at
  by (intro tendsto_intros)

lemma continuous_at_Pair:
  fixes x::"'a::euclidean_space \<times> 'b::euclidean_space"
  assumes "continuous (at x) f"
  assumes "continuous (at x) g"
  shows "continuous (at x) (\<lambda>x. (f x, g x))"
  using assms unfolding continuous_def
  by (intro tendsto_intros)

lemma continuous_on_Pair:
  fixes x::"'a::euclidean_space \<times> 'b::euclidean_space"
  assumes "continuous_on S f"
  assumes "continuous_on S g"
  shows "continuous_on S (\<lambda>x. (f x, g x))"
  using assms unfolding continuous_on_def
  by (auto intro: tendsto_intros)

lemmas continuous_intros = continuous_intros
  continuous_at_fst continuous_at_snd
  continuous_at_Pair
lemmas continuous_on_intros = continuous_on_intros
  continuous_on_fst continuous_on_snd
  continuous_on_Pair

subsection {* Derivatives *}

lemma has_vector_derivative_imp:
  assumes "x \<in> s"
  assumes "\<And>x. x \<in> s \<Longrightarrow> f x = g x"
  assumes f'g':"f' = g'"
  assumes "x = y" "s = t"
  assumes f': "(f has_vector_derivative f') (at x within s)"
  shows "(g has_vector_derivative g') (at y within t)"
  unfolding has_vector_derivative_def has_derivative_within'
proof (safe)
  fix e::real
  assume "0 < e"
  with assms f' have "\<exists>d>0. \<forall>x'\<in>s.
    0 < norm (x' - x) \<and> norm (x' - x) < d \<longrightarrow>
    norm (g x' - g y - (x' - y) *\<^sub>R g') / norm (x' - x) < e"
    by (auto simp add: has_vector_derivative_def has_derivative_within')
  then guess d ..
  with assms show "\<exists>d>0. \<forall>x'\<in>t. 0 < norm (x' - y) \<and> norm (x' - y) < d \<longrightarrow>
    norm (g x' - g y - (x' - y) *\<^sub>R g') / norm (x' - y) < e"
    by auto
next
  show "bounded_linear (\<lambda>x. x *\<^sub>R g')"
    using derivative_linear[OF f'[simplified has_vector_derivative_def], simplified f'g'] assms
    by simp
qed

lemma has_vector_derivative_cong:
  assumes "x \<in> s"
  assumes "\<And>x. x \<in> s \<Longrightarrow> f x = g x"
  assumes f'g':"f' = g'"
  assumes "x = y" "s = t"
  shows "(g has_vector_derivative g') (at y within t) =
  (f has_vector_derivative f') (at x within s)"
proof
  assume "(f has_vector_derivative f') (at x within s)"
  from has_vector_derivative_imp this assms
  show "(g has_vector_derivative g') (at y within t)"
    by blast
next
  assume g': "(g has_vector_derivative g') (at y within t)"
  show "(f has_vector_derivative f') (at x within s)"
    using assms g'
    by (intro has_vector_derivative_imp[where f=g and g=f and f'=g' and g'=f'])
      auto
qed

lemma continuous_xy:
  fixes f::"'a::real_normed_vector \<times> 'b::real_normed_vector \<Rightarrow> 'c::real_normed_vector"
  assumes defined: "\<forall>x \<in> S. y x \<in> U"
  assumes f_cont: "continuous_on (S \<times> U) f"
  assumes y_cont: "continuous_on S y"
  shows "continuous_on S (\<lambda>x. f (x, y x))"
proof -
  have "(\<lambda>x. f (x, y x)) = (f o (\<lambda>x. (x, y x)))" by auto
  moreover have "(\<lambda>x. (x, y x)) ` S \<subseteq> (S \<times> U)" using defined by auto
  ultimately show "continuous_on S (\<lambda>t. f (t, y t))" using f_cont y_cont
    by (auto intro!: continuous_on_compose continuous_on_Pair continuous_on_id
      continuous_on_subset[where t="(\<lambda>x. (x, y x)) ` S"])
qed

lemma has_derivative_within_union:
  assumes "(f has_derivative g) (at x within s)"
  assumes "(f has_derivative g) (at x within t)"
  shows  "(f has_derivative g) (at x within (s \<union> t))"
proof cases
  assume "at x within (s \<union> t) = bot"
  thus ?thesis using assms by (simp_all add: has_derivative_def)
next
  assume st: "at x within (s \<union> t) \<noteq> bot"
  thus ?thesis
    using assms
    apply (auto simp: Lim_within_union has_derivative_def)
    apply (cases "at x within s = bot", simp_all add: netlimit_within)
    apply (cases "at x within t = bot", simp_all add: netlimit_within)
    done
qed

lemma has_vector_derivative_within_union:
  assumes "(f has_vector_derivative g) (at x within s)"
  assumes "(f has_vector_derivative g) (at x within t)"
  shows  "(f has_vector_derivative g) (at x within (s \<union> t))"
using assms
by (auto simp: has_vector_derivative_def intro: has_derivative_within_union)

lemma linear_continuation:
  assumes f':"\<And>x. x \<in> {a..b} \<Longrightarrow> (f has_vector_derivative f' x) (at x within {a..b})"
  assumes g':"\<And>x. x \<in> {b..c} \<Longrightarrow> (g has_vector_derivative g' x) (at x within {b..c})"
  assumes connect: "f b = g b" "f' b = g' b"
  assumes x: "x \<in> {a..c}"
  assumes abc:"a \<le> b" "b \<le> c"
  shows "((\<lambda>x. if x \<le> b then f x else g x) has_vector_derivative
  (\<lambda>x. if x \<le> b then f' x else g' x) x) (at x within {a..c})"
  (is "(?h has_vector_derivative ?h' x) _")
  using assms
  unfolding has_vector_derivative_def has_derivative_within'
proof (safe)
  fix e::real
  assume "0 < e"
  show "\<exists>d>0. \<forall>x'\<in>{a..c}. 0 < norm (x' - x) \<and> norm (x' - x) < d \<longrightarrow>
      norm ((if x' \<le> b then f x' else g x') - (if x \<le> b then f x else g x) -
        (x' - x) *\<^sub>R (if x \<le> b then f' x else g' x)) / norm (x' - x) < e"
  proof (cases "x < b")
    case True
    moreover with x have "x \<in> {a..b}" by simp
    moreover with `0 < e` f' obtain df where "df > 0"
      "\<And>xa. xa \<in> {a..b} \<Longrightarrow> 0 < norm (xa - x) \<and> norm (xa - x) < df \<Longrightarrow>
      norm (f xa - f x - (xa - x) *\<^sub>R f' x) / norm (xa - x) < e"
      unfolding has_vector_derivative_def has_derivative_within'
      by fast
    ultimately show ?thesis
      by (auto intro!: exI[where x="min df (norm (x - b))"])
  next
    case False
    moreover with x have xbc: "x \<in> {b..c}" by simp
    moreover with `0 < e` g' obtain dg where dg: "dg > 0"
      "\<And>xa. xa \<in> {b..c} \<Longrightarrow> 0 < norm (xa - x) \<and> norm (xa - x) < dg \<Longrightarrow>
        norm (g xa - g x - (xa - x) *\<^sub>R g' x) / norm (xa - x) < e"
      unfolding has_vector_derivative_def has_derivative_within'
      by fast
    ultimately show ?thesis
    proof (cases "x = b")
      case True
      with x have xab: "x \<in> {a..b}" by simp
      with `0 < e` f' obtain df where df: "df > 0"
        "\<And>xa. xa \<in> {a..b} \<Longrightarrow> 0 < norm (xa - x) \<and> norm (xa - x) < df \<Longrightarrow>
        norm (f xa - f x - (xa - x) *\<^sub>R f' x) / norm (xa - x) < e"
        unfolding has_vector_derivative_def has_derivative_within'
        by fast
      thus ?thesis
        using xbc False dg abc connect True
        by (auto intro!:exI[where x="min df dg"])
    qed (auto intro!: exI[where x="min dg (norm (x - b))"])
  qed
qed (auto intro: bounded_linearI simp add: ac_simps)

lemma linear_continuation':
  assumes f':"\<And>x. x \<in> {a..b} \<Longrightarrow> (f has_vector_derivative f' x) (at x within {a..b})"
  assumes g':"\<And>x. x \<in> {b..c} \<Longrightarrow> (g has_vector_derivative g' x) (at x within {b..c})"
  assumes connect: "f b = g b" "f' b = g' b"
  assumes x: "x \<in> {a..c}"
  assumes abc:"a \<le> b" "b \<le> c"
  assumes fg: "fg = (\<lambda>x. if x \<le> b then f x else g x)"
  assumes fg': "fg' = (\<lambda>x. if x \<le> b then f' x else g' x)"
  shows "(fg has_vector_derivative fg' x) (at x within {a..c})"
  using linear_continuation assms unfolding fg fg' by blast

lemma has_vector_derivative_within_at:
  assumes "a < b"
  assumes "x \<in> {a<..<b}"
  assumes f':"\<And>x. x \<in> {a..b} \<Longrightarrow> (f has_vector_derivative f' x) (at x within {a..b})"
  shows "(f has_vector_derivative f' x) (at x)"
proof -
  from assms have "(f has_derivative (\<lambda>xa. xa *\<^sub>R f' x)) (at x within {a..b})"
    by (auto intro!: has_derivative_within_subset simp add: has_vector_derivative_def)
  hence "(f has_derivative (\<lambda>xa. xa *\<^sub>R f' x)) (at x within {a<..<b})"
    by (rule has_derivative_within_subset) auto
  thus "(f has_vector_derivative f' x) (at x)"
    using assms(1-2)
    by (auto simp add: has_derivative_within_subset has_vector_derivative_def
      has_derivative_within_open)
qed

lemma obtain_linear_continuation_at:
  fixes f::"real\<Rightarrow>real"
  assumes f':"\<And>x. x \<in> {a..b} \<Longrightarrow> (f has_vector_derivative f' x) (at x within {a..b})"
  obtains fc
  where "\<And>x. x\<in>{a..b} \<Longrightarrow> (fc has_vector_derivative f' x) (at x)"
  "\<And>x. x\<in>{a..b} \<Longrightarrow> (fc x = f x)"
proof
  fix x
  assume ab: "x\<in>{a..b}"
  hence a_le_b: "a \<le> b" by auto

  def fc \<equiv> "\<lambda>x. if x \<le> a then f a - f' a * (a - x) else f x"
  have "\<And>x. ((\<lambda>x. f a + f' a *\<^sub>R x + -a * f' a) has_vector_derivative 0 + f' a *\<^sub>R 1 + 0) (at x)"
    by (intro has_vector_derivative_add has_vector_derivative_const has_vector_derivative_cmul
      has_vector_derivative_id)
  hence "\<And>x. x \<in> {a - 1..a} \<Longrightarrow>
    ((\<lambda>x. f a - f' a * (a - x)) has_vector_derivative f' a) (at x within {a - 1..a})"
    by (auto simp add: field_simps has_vector_derivative_at_within)
  hence fcconn: "\<And>x. x \<in> {a - 1..b} \<Longrightarrow>
    (fc has_vector_derivative (if x \<le> a then f' a else f' x)) (at x within {a - 1..b})"
    unfolding fc_def
    using f' interval ab
    by (intro linear_continuation) auto
  
  def fcc \<equiv> "\<lambda>x. if x \<le> b then fc x else f b + f' b * (x - b)"
  have "\<And>x. ((\<lambda>x. f b + f' b *\<^sub>R x + -b * f' b) has_vector_derivative 0 + f' b *\<^sub>R 1 + 0) (at x)"
    by (intro has_vector_derivative_add has_vector_derivative_const has_vector_derivative_cmul
      has_vector_derivative_id)
  hence f0':"\<And>x. x \<in> {b..b+1} \<Longrightarrow>
    ((\<lambda>x. f b + f' b * (x - b)) has_vector_derivative f' b) (at x within {b..b+1})"
    by (auto simp add: field_simps has_vector_derivative_at_within)
  {
    assume "\<And>x. a - 1 \<le> x \<and> x \<le> b \<Longrightarrow> (fc has_vector_derivative (if x \<le> a then f' a else f' x))
      (at x within {a - 1..b})"
    hence "(fc has_vector_derivative (if b \<le> a then f' a else f' b))
      (at b within {a - 1..b})" using ab a_le_b by auto
    moreover have "(if b \<le> a then f' a else f' b) = f' b" using a_le_b by auto
    ultimately have "(fc has_vector_derivative f' b) (at b within {a - 1..b})"
       using a_le_b by (auto cong del: has_vector_derivative_cong)
    hence "(fc has_vector_derivative f' b) (at b within {b..b})"
      by (rule has_vector_derivative_within_subset)
    (insert a_le_b, simp)
  }
  hence fccconn: "\<And>x. x \<in> {a - 1..b + 1} \<Longrightarrow>
    (fcc has_vector_derivative (if x \<le> b then (if x \<le> a then f' a else f' x) else f' b)) (at x within {a - 1..b+1})"
    unfolding fcc_def
    using fcconn f0' interval a_le_b fcconn
    by (intro linear_continuation) (auto simp add: fc_def)

  have A: "a - 1 < b + 1" using a_le_b by simp
  moreover have B: "x \<in> {a - 1<..<b+1}" using ab by simp
  from has_vector_derivative_within_at[OF A B fccconn]
  have "(fcc has_vector_derivative (if x \<le> b then if x \<le> a then f' a else f' x else f' b)) (at x)"
    by simp
  thus "(fcc has_vector_derivative f' x) (at x)" using ab
    by (cases "a = x") simp_all
qed auto

subsubsection {* Experiments on total derivative *}

lemma Pair_real_function_eq_eucl:
  fixes f::"real\<Rightarrow>real\<Rightarrow>real"
  shows "(\<lambda>(a, b). f a b) = (\<lambda>ab. f (ab$$0) (ab$$1))"
proof (safe intro!: ext)
  fix a b::real
  from snd_eq_component_plus'[of a b 0] fst_eq_component_zero'[of a b]
  show "f a b = f ((a, b) $$ 0) ((a, b) $$ 1)" by simp
qed  

lemma real_Pair_euclidean_representation:
  fixes t x::real
  shows "(t, x) = t *\<^sub>R basis 0 + x *\<^sub>R basis 1"
proof -
  have "(t, x) $$ 0 = t" by (simp add: fst_eq_component_zero[symmetric])
  moreover have "(t, x) $$ 1 = x" using snd_eq_component_plus'[of t x 0, symmetric] by simp
  ultimately show "(t, x) = t *\<^sub>R basis 0 + x *\<^sub>R basis 1"
    using euclidean_representation[of "(t, x)"] by simp
qed

lemma derivative_at_real_Pair_partial_intro:
  fixes f::"real\<times>real\<Rightarrow>real"
  assumes "f differentiable (at (t, x))"
  assumes "((\<lambda>t. f (t, x)) has_derivative ft (t, x)) (at t)"
  assumes "((\<lambda>x. f (t, x)) has_derivative fx (t, x)) (at x)"
  shows "(f has_derivative (\<lambda>(dt, dx). ft (t, x) dt + fx (t, x) dx)) (at (t, x))"
proof -
  from frechet_derivative_works[of f "(at (t, x))"] assms(1)
  have f': "(f has_derivative frechet_derivative f (at (t, x))) (at (t, x))" by simp

  hence "(f o (\<lambda>t. t *\<^sub>R basis 0 + x *\<^sub>R basis 1) has_derivative (frechet_derivative f (at (t, x)) o (\<lambda>dt. dt *\<^sub>R basis 0 + 0))) (at t)"
    by (intro diff_chain_at has_derivative_intros ) (simp add: real_Pair_euclidean_representation)
  hence "((\<lambda>t. f (t, x)) has_derivative (frechet_derivative f (at (t, x)) o (\<lambda>dt. dt *\<^sub>R basis 0))) (at t)"
    by (simp add: o_def real_Pair_euclidean_representation)
  from frechet_derivative_unique_at[OF assms(2)[simplified has_vector_derivative_def] this]
  have H1: "\<And>h. frechet_derivative f (at (t, x)) (basis 0) * h = ft (t, x) h"
    using linear_frechet_derivative[OF assms(1)]
    by (auto simp add: linear_cmul)

  note f'
  hence "(f o (\<lambda>x. t *\<^sub>R basis 0 + x *\<^sub>R basis 1) has_derivative (frechet_derivative f (at (t, x)) o (\<lambda>dx. 0 + dx *\<^sub>R basis 1))) (at x)"
    by (intro diff_chain_at has_derivative_intros ) (simp add: real_Pair_euclidean_representation)
  hence "((\<lambda>x. f (t, x)) has_derivative (frechet_derivative f (at (t, x)) o (\<lambda>dx. dx *\<^sub>R basis 1))) (at x)"
    by (simp add: o_def real_Pair_euclidean_representation)
  from frechet_derivative_unique_at[OF assms(3) this]
  have H2: "\<And>h. frechet_derivative f (at (t, x)) (basis (Suc 0)) * h = fx (t, x) h"
    using linear_frechet_derivative[OF assms(1)]
    by (auto simp add: linear_cmul)

  from assms(1) Derivative.jacobian_works[of f]
  have "(f has_derivative
      (\<lambda>h. frechet_derivative f (at (t, x)) (basis 0) * h $$ 0 +
        frechet_derivative f (at (t, x)) (basis (Suc 0)) * h $$ Suc 0))
    (at (t, x))"
    by simp
  thus ?thesis
    by (simp add: H1 H2 Pair_real_function_eq_eucl)
qed

subsection {* Integration *}

lemmas content_real[simp]

lemma integral_atLeastAtMost[simp]:
  "integral {a..b} (\<lambda>x. c) = content {a .. b} *\<^sub>R c"
  by auto

lemma integral_real_singleton[simp]:
  "integral {a::real} f = 0"
  using integral_refl[of a f] by simp
lemmas integrable_continuous[intro, simp]

subsection {* Sup *}

lemma Sup_real_mult:
  fixes a::real
  assumes "0 < a"
  assumes "S \<noteq> {}" "(\<And>x. x \<in> S \<Longrightarrow> 0 \<le> x \<and> x \<le> z)"
  shows "a * Sup S = Sup ((\<lambda>x. a * x) ` S)"
using assms
proof (intro antisym)
  have "Sup S \<le> Sup (op * a ` S) / a" using assms
    by (intro Sup_least mult_imp_le_div_pos Sup_upper[where z = "a * z"]) auto
  thus "a * Sup S \<le> Sup (op * a ` S)"
    by (simp add: ac_simps pos_le_divide_eq[OF assms(1)])
qed (auto intro!: mult_mono Sup_least)

end
