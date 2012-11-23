(*  Title:      HOL/SEQ.thy
    Author:     Jacques D. Fleuriot, University of Cambridge
    Author:     Lawrence C Paulson
    Author:     Jeremy Avigad
    Author:     Brian Huffman

Convergence of sequences and series.
*)

header {* Sequences and Convergence *}

theory SEQ
imports Limits RComplete
begin

subsection {* Monotone sequences and subsequences *}

definition
  monoseq :: "(nat \<Rightarrow> 'a::order) \<Rightarrow> bool" where
    --{*Definition of monotonicity.
        The use of disjunction here complicates proofs considerably.
        One alternative is to add a Boolean argument to indicate the direction.
        Another is to develop the notions of increasing and decreasing first.*}
  "monoseq X = ((\<forall>m. \<forall>n\<ge>m. X m \<le> X n) | (\<forall>m. \<forall>n\<ge>m. X n \<le> X m))"

definition
  incseq :: "(nat \<Rightarrow> 'a::order) \<Rightarrow> bool" where
    --{*Increasing sequence*}
  "incseq X \<longleftrightarrow> (\<forall>m. \<forall>n\<ge>m. X m \<le> X n)"

definition
  decseq :: "(nat \<Rightarrow> 'a::order) \<Rightarrow> bool" where
    --{*Decreasing sequence*}
  "decseq X \<longleftrightarrow> (\<forall>m. \<forall>n\<ge>m. X n \<le> X m)"

definition
  subseq :: "(nat \<Rightarrow> nat) \<Rightarrow> bool" where
    --{*Definition of subsequence*}
  "subseq f \<longleftrightarrow> (\<forall>m. \<forall>n>m. f m < f n)"

lemma incseq_mono: "mono f \<longleftrightarrow> incseq f"
  unfolding mono_def incseq_def by auto

lemma incseq_SucI:
  "(\<And>n. X n \<le> X (Suc n)) \<Longrightarrow> incseq X"
  using lift_Suc_mono_le[of X]
  by (auto simp: incseq_def)

lemma incseqD: "\<And>i j. incseq f \<Longrightarrow> i \<le> j \<Longrightarrow> f i \<le> f j"
  by (auto simp: incseq_def)

lemma incseq_SucD: "incseq A \<Longrightarrow> A i \<le> A (Suc i)"
  using incseqD[of A i "Suc i"] by auto

lemma incseq_Suc_iff: "incseq f \<longleftrightarrow> (\<forall>n. f n \<le> f (Suc n))"
  by (auto intro: incseq_SucI dest: incseq_SucD)

lemma incseq_const[simp, intro]: "incseq (\<lambda>x. k)"
  unfolding incseq_def by auto

lemma decseq_SucI:
  "(\<And>n. X (Suc n) \<le> X n) \<Longrightarrow> decseq X"
  using order.lift_Suc_mono_le[OF dual_order, of X]
  by (auto simp: decseq_def)

lemma decseqD: "\<And>i j. decseq f \<Longrightarrow> i \<le> j \<Longrightarrow> f j \<le> f i"
  by (auto simp: decseq_def)

lemma decseq_SucD: "decseq A \<Longrightarrow> A (Suc i) \<le> A i"
  using decseqD[of A i "Suc i"] by auto

lemma decseq_Suc_iff: "decseq f \<longleftrightarrow> (\<forall>n. f (Suc n) \<le> f n)"
  by (auto intro: decseq_SucI dest: decseq_SucD)

lemma decseq_const[simp, intro]: "decseq (\<lambda>x. k)"
  unfolding decseq_def by auto

lemma monoseq_iff: "monoseq X \<longleftrightarrow> incseq X \<or> decseq X"
  unfolding monoseq_def incseq_def decseq_def ..

lemma monoseq_Suc:
  "monoseq X \<longleftrightarrow> (\<forall>n. X n \<le> X (Suc n)) \<or> (\<forall>n. X (Suc n) \<le> X n)"
  unfolding monoseq_iff incseq_Suc_iff decseq_Suc_iff ..

lemma monoI1: "\<forall>m. \<forall> n \<ge> m. X m \<le> X n ==> monoseq X"
by (simp add: monoseq_def)

lemma monoI2: "\<forall>m. \<forall> n \<ge> m. X n \<le> X m ==> monoseq X"
by (simp add: monoseq_def)

lemma mono_SucI1: "\<forall>n. X n \<le> X (Suc n) ==> monoseq X"
by (simp add: monoseq_Suc)

lemma mono_SucI2: "\<forall>n. X (Suc n) \<le> X n ==> monoseq X"
by (simp add: monoseq_Suc)

lemma monoseq_minus:
  fixes a :: "nat \<Rightarrow> 'a::ordered_ab_group_add"
  assumes "monoseq a"
  shows "monoseq (\<lambda> n. - a n)"
proof (cases "\<forall> m. \<forall> n \<ge> m. a m \<le> a n")
  case True
  hence "\<forall> m. \<forall> n \<ge> m. - a n \<le> - a m" by auto
  thus ?thesis by (rule monoI2)
next
  case False
  hence "\<forall> m. \<forall> n \<ge> m. - a m \<le> - a n" using `monoseq a`[unfolded monoseq_def] by auto
  thus ?thesis by (rule monoI1)
qed

text{*Subsequence (alternative definition, (e.g. Hoskins)*}

lemma subseq_Suc_iff: "subseq f = (\<forall>n. (f n) < (f (Suc n)))"
apply (simp add: subseq_def)
apply (auto dest!: less_imp_Suc_add)
apply (induct_tac k)
apply (auto intro: less_trans)
done

text{* for any sequence, there is a monotonic subsequence *}
lemma seq_monosub:
  fixes s :: "nat => 'a::linorder"
  shows "\<exists>f. subseq f \<and> monoseq (\<lambda> n. (s (f n)))"
proof cases
  let "?P p n" = "p > n \<and> (\<forall>m\<ge>p. s m \<le> s p)"
  assume *: "\<forall>n. \<exists>p. ?P p n"
  def f \<equiv> "nat_rec (SOME p. ?P p 0) (\<lambda>_ n. SOME p. ?P p n)"
  have f_0: "f 0 = (SOME p. ?P p 0)" unfolding f_def by simp
  have f_Suc: "\<And>i. f (Suc i) = (SOME p. ?P p (f i))" unfolding f_def nat_rec_Suc ..
  have P_0: "?P (f 0) 0" unfolding f_0 using *[rule_format] by (rule someI2_ex) auto
  have P_Suc: "\<And>i. ?P (f (Suc i)) (f i)" unfolding f_Suc using *[rule_format] by (rule someI2_ex) auto
  then have "subseq f" unfolding subseq_Suc_iff by auto
  moreover have "monoseq (\<lambda>n. s (f n))" unfolding monoseq_Suc
  proof (intro disjI2 allI)
    fix n show "s (f (Suc n)) \<le> s (f n)"
    proof (cases n)
      case 0 with P_Suc[of 0] P_0 show ?thesis by auto
    next
      case (Suc m)
      from P_Suc[of n] Suc have "f (Suc m) \<le> f (Suc (Suc m))" by simp
      with P_Suc Suc show ?thesis by simp
    qed
  qed
  ultimately show ?thesis by auto
next
  let "?P p m" = "m < p \<and> s m < s p"
  assume "\<not> (\<forall>n. \<exists>p>n. (\<forall>m\<ge>p. s m \<le> s p))"
  then obtain N where N: "\<And>p. p > N \<Longrightarrow> \<exists>m>p. s p < s m" by (force simp: not_le le_less)
  def f \<equiv> "nat_rec (SOME p. ?P p (Suc N)) (\<lambda>_ n. SOME p. ?P p n)"
  have f_0: "f 0 = (SOME p. ?P p (Suc N))" unfolding f_def by simp
  have f_Suc: "\<And>i. f (Suc i) = (SOME p. ?P p (f i))" unfolding f_def nat_rec_Suc ..
  have P_0: "?P (f 0) (Suc N)"
    unfolding f_0 some_eq_ex[of "\<lambda>p. ?P p (Suc N)"] using N[of "Suc N"] by auto
  { fix i have "N < f i \<Longrightarrow> ?P (f (Suc i)) (f i)"
      unfolding f_Suc some_eq_ex[of "\<lambda>p. ?P p (f i)"] using N[of "f i"] . }
  note P' = this
  { fix i have "N < f i \<and> ?P (f (Suc i)) (f i)"
      by (induct i) (insert P_0 P', auto) }
  then have "subseq f" "monoseq (\<lambda>x. s (f x))"
    unfolding subseq_Suc_iff monoseq_Suc by (auto simp: not_le intro: less_imp_le)
  then show ?thesis by auto
qed

lemma seq_suble: assumes sf: "subseq f" shows "n \<le> f n"
proof(induct n)
  case 0 thus ?case by simp
next
  case (Suc n)
  from sf[unfolded subseq_Suc_iff, rule_format, of n] Suc.hyps
  have "n < f (Suc n)" by arith
  thus ?case by arith
qed

lemma incseq_imp_monoseq:  "incseq X \<Longrightarrow> monoseq X"
  by (simp add: incseq_def monoseq_def)

lemma decseq_imp_monoseq:  "decseq X \<Longrightarrow> monoseq X"
  by (simp add: decseq_def monoseq_def)

lemma decseq_eq_incseq:
  fixes X :: "nat \<Rightarrow> 'a::ordered_ab_group_add" shows "decseq X = incseq (\<lambda>n. - X n)" 
  by (simp add: decseq_def incseq_def)

subsection {* Defintions of limits *}

abbreviation (in topological_space)
  LIMSEQ :: "[nat \<Rightarrow> 'a, 'a] \<Rightarrow> bool"
    ("((_)/ ----> (_))" [60, 60] 60) where
  "X ----> L \<equiv> (X ---> L) sequentially"

definition
  lim :: "(nat \<Rightarrow> 'a::t2_space) \<Rightarrow> 'a" where
    --{*Standard definition of limit using choice operator*}
  "lim X = (THE L. X ----> L)"

definition (in topological_space) convergent :: "(nat \<Rightarrow> 'a) \<Rightarrow> bool" where
  "convergent X = (\<exists>L. X ----> L)"

definition
  Bseq :: "(nat => 'a::real_normed_vector) => bool" where
    --{*Standard definition for bounded sequence*}
  "Bseq X = (\<exists>K>0.\<forall>n. norm (X n) \<le> K)"

definition (in metric_space) Cauchy :: "(nat \<Rightarrow> 'a) \<Rightarrow> bool" where
  "Cauchy X = (\<forall>e>0. \<exists>M. \<forall>m \<ge> M. \<forall>n \<ge> M. dist (X m) (X n) < e)"


subsection {* Bounded Sequences *}

lemma BseqI': assumes K: "\<And>n. norm (X n) \<le> K" shows "Bseq X"
unfolding Bseq_def
proof (intro exI conjI allI)
  show "0 < max K 1" by simp
next
  fix n::nat
  have "norm (X n) \<le> K" by (rule K)
  thus "norm (X n) \<le> max K 1" by simp
qed

lemma BseqE: "\<lbrakk>Bseq X; \<And>K. \<lbrakk>0 < K; \<forall>n. norm (X n) \<le> K\<rbrakk> \<Longrightarrow> Q\<rbrakk> \<Longrightarrow> Q"
unfolding Bseq_def by auto

lemma BseqI2': assumes K: "\<forall>n\<ge>N. norm (X n) \<le> K" shows "Bseq X"
proof (rule BseqI')
  let ?A = "norm ` X ` {..N}"
  have 1: "finite ?A" by simp
  fix n::nat
  show "norm (X n) \<le> max K (Max ?A)"
  proof (cases rule: linorder_le_cases)
    assume "n \<ge> N"
    hence "norm (X n) \<le> K" using K by simp
    thus "norm (X n) \<le> max K (Max ?A)" by simp
  next
    assume "n \<le> N"
    hence "norm (X n) \<in> ?A" by simp
    with 1 have "norm (X n) \<le> Max ?A" by (rule Max_ge)
    thus "norm (X n) \<le> max K (Max ?A)" by simp
  qed
qed

lemma Bseq_ignore_initial_segment: "Bseq X \<Longrightarrow> Bseq (\<lambda>n. X (n + k))"
unfolding Bseq_def by auto

lemma Bseq_offset: "Bseq (\<lambda>n. X (n + k)) \<Longrightarrow> Bseq X"
apply (erule BseqE)
apply (rule_tac N="k" and K="K" in BseqI2')
apply clarify
apply (drule_tac x="n - k" in spec, simp)
done

lemma Bseq_conv_Bfun: "Bseq X \<longleftrightarrow> Bfun X sequentially"
unfolding Bfun_def eventually_sequentially
apply (rule iffI)
apply (simp add: Bseq_def)
apply (auto intro: BseqI2')
done


subsection {* Limits of Sequences *}

lemma [trans]: "X=Y ==> Y ----> z ==> X ----> z"
  by simp

lemma LIMSEQ_def: "X ----> L = (\<forall>r>0. \<exists>no. \<forall>n\<ge>no. dist (X n) L < r)"
unfolding tendsto_iff eventually_sequentially ..

lemma LIMSEQ_iff:
  fixes L :: "'a::real_normed_vector"
  shows "(X ----> L) = (\<forall>r>0. \<exists>no. \<forall>n \<ge> no. norm (X n - L) < r)"
unfolding LIMSEQ_def dist_norm ..

lemma LIMSEQ_iff_nz: "X ----> L = (\<forall>r>0. \<exists>no>0. \<forall>n\<ge>no. dist (X n) L < r)"
  unfolding LIMSEQ_def by (metis Suc_leD zero_less_Suc)

lemma metric_LIMSEQ_I:
  "(\<And>r. 0 < r \<Longrightarrow> \<exists>no. \<forall>n\<ge>no. dist (X n) L < r) \<Longrightarrow> X ----> L"
by (simp add: LIMSEQ_def)

lemma metric_LIMSEQ_D:
  "\<lbrakk>X ----> L; 0 < r\<rbrakk> \<Longrightarrow> \<exists>no. \<forall>n\<ge>no. dist (X n) L < r"
by (simp add: LIMSEQ_def)

lemma LIMSEQ_I:
  fixes L :: "'a::real_normed_vector"
  shows "(\<And>r. 0 < r \<Longrightarrow> \<exists>no. \<forall>n\<ge>no. norm (X n - L) < r) \<Longrightarrow> X ----> L"
by (simp add: LIMSEQ_iff)

lemma LIMSEQ_D:
  fixes L :: "'a::real_normed_vector"
  shows "\<lbrakk>X ----> L; 0 < r\<rbrakk> \<Longrightarrow> \<exists>no. \<forall>n\<ge>no. norm (X n - L) < r"
by (simp add: LIMSEQ_iff)

lemma LIMSEQ_const_iff:
  fixes k l :: "'a::t2_space"
  shows "(\<lambda>n. k) ----> l \<longleftrightarrow> k = l"
  using trivial_limit_sequentially by (rule tendsto_const_iff)

lemma LIMSEQ_ignore_initial_segment:
  "f ----> a \<Longrightarrow> (\<lambda>n. f (n + k)) ----> a"
apply (rule topological_tendstoI)
apply (drule (2) topological_tendstoD)
apply (simp only: eventually_sequentially)
apply (erule exE, rename_tac N)
apply (rule_tac x=N in exI)
apply simp
done

lemma LIMSEQ_offset:
  "(\<lambda>n. f (n + k)) ----> a \<Longrightarrow> f ----> a"
apply (rule topological_tendstoI)
apply (drule (2) topological_tendstoD)
apply (simp only: eventually_sequentially)
apply (erule exE, rename_tac N)
apply (rule_tac x="N + k" in exI)
apply clarify
apply (drule_tac x="n - k" in spec)
apply (simp add: le_diff_conv2)
done

lemma LIMSEQ_Suc: "f ----> l \<Longrightarrow> (\<lambda>n. f (Suc n)) ----> l"
by (drule_tac k="Suc 0" in LIMSEQ_ignore_initial_segment, simp)

lemma LIMSEQ_imp_Suc: "(\<lambda>n. f (Suc n)) ----> l \<Longrightarrow> f ----> l"
by (rule_tac k="Suc 0" in LIMSEQ_offset, simp)

lemma LIMSEQ_Suc_iff: "(\<lambda>n. f (Suc n)) ----> l = f ----> l"
by (blast intro: LIMSEQ_imp_Suc LIMSEQ_Suc)

lemma LIMSEQ_linear: "\<lbrakk> X ----> x ; l > 0 \<rbrakk> \<Longrightarrow> (\<lambda> n. X (n * l)) ----> x"
  unfolding tendsto_def eventually_sequentially
  by (metis div_le_dividend div_mult_self1_is_m le_trans nat_mult_commute)

lemma LIMSEQ_unique:
  fixes a b :: "'a::t2_space"
  shows "\<lbrakk>X ----> a; X ----> b\<rbrakk> \<Longrightarrow> a = b"
  using trivial_limit_sequentially by (rule tendsto_unique)

lemma increasing_LIMSEQ:
  fixes f :: "nat \<Rightarrow> real"
  assumes inc: "!!n. f n \<le> f (Suc n)"
      and bdd: "!!n. f n \<le> l"
      and en: "!!e. 0 < e \<Longrightarrow> \<exists>n. l \<le> f n + e"
  shows "f ----> l"
proof (auto simp add: LIMSEQ_def)
  fix e :: real
  assume e: "0 < e"
  then obtain N where "l \<le> f N + e/2"
    by (metis half_gt_zero e en that)
  hence N: "l < f N + e" using e
    by simp
  { fix k
    have [simp]: "!!n. \<bar>f n - l\<bar> = l - f n"
      by (simp add: bdd) 
    have "\<bar>f (N+k) - l\<bar> < e"
    proof (induct k)
      case 0 show ?case using N
        by simp   
    next
      case (Suc k) thus ?case using N inc [of "N+k"]
        by simp
    qed 
  } note 1 = this
  { fix n
    have "N \<le> n \<Longrightarrow> \<bar>f n - l\<bar> < e" using 1 [of "n-N"]
      by simp 
  } note [intro] = this
  show " \<exists>no. \<forall>n\<ge>no. dist (f n) l < e"
    by (auto simp add: dist_real_def) 
  qed

lemma Bseq_inverse_lemma:
  fixes x :: "'a::real_normed_div_algebra"
  shows "\<lbrakk>r \<le> norm x; 0 < r\<rbrakk> \<Longrightarrow> norm (inverse x) \<le> inverse r"
apply (subst nonzero_norm_inverse, clarsimp)
apply (erule (1) le_imp_inverse_le)
done

lemma Bseq_inverse:
  fixes a :: "'a::real_normed_div_algebra"
  shows "\<lbrakk>X ----> a; a \<noteq> 0\<rbrakk> \<Longrightarrow> Bseq (\<lambda>n. inverse (X n))"
unfolding Bseq_conv_Bfun by (rule Bfun_inverse)

lemma LIMSEQ_diff_approach_zero:
  fixes L :: "'a::real_normed_vector"
  shows "g ----> L ==> (%x. f x - g x) ----> 0 ==> f ----> L"
  by (drule (1) tendsto_add, simp)

lemma LIMSEQ_diff_approach_zero2:
  fixes L :: "'a::real_normed_vector"
  shows "f ----> L ==> (%x. f x - g x) ----> 0 ==> g ----> L"
  by (drule (1) tendsto_diff, simp)

text{*An unbounded sequence's inverse tends to 0*}

lemma LIMSEQ_inverse_zero:
  "\<forall>r::real. \<exists>N. \<forall>n\<ge>N. r < X n \<Longrightarrow> (\<lambda>n. inverse (X n)) ----> 0"
apply (rule LIMSEQ_I)
apply (drule_tac x="inverse r" in spec, safe)
apply (rule_tac x="N" in exI, safe)
apply (drule_tac x="n" in spec, safe)
apply (frule positive_imp_inverse_positive)
apply (frule (1) less_imp_inverse_less)
apply (subgoal_tac "0 < X n", simp)
apply (erule (1) order_less_trans)
done

text{*The sequence @{term "1/n"} tends to 0 as @{term n} tends to infinity*}

lemma LIMSEQ_inverse_real_of_nat: "(%n. inverse(real(Suc n))) ----> 0"
apply (rule LIMSEQ_inverse_zero, safe)
apply (cut_tac x = r in reals_Archimedean2)
apply (safe, rule_tac x = n in exI)
apply (auto simp add: real_of_nat_Suc)
done

text{*The sequence @{term "r + 1/n"} tends to @{term r} as @{term n} tends to
infinity is now easily proved*}

lemma LIMSEQ_inverse_real_of_nat_add:
     "(%n. r + inverse(real(Suc n))) ----> r"
  using tendsto_add [OF tendsto_const LIMSEQ_inverse_real_of_nat] by auto

lemma LIMSEQ_inverse_real_of_nat_add_minus:
     "(%n. r + -inverse(real(Suc n))) ----> r"
  using tendsto_add [OF tendsto_const
    tendsto_minus [OF LIMSEQ_inverse_real_of_nat]] by auto

lemma LIMSEQ_inverse_real_of_nat_add_minus_mult:
     "(%n. r*( 1 + -inverse(real(Suc n)))) ----> r"
  using tendsto_mult [OF tendsto_const
    LIMSEQ_inverse_real_of_nat_add_minus [of 1]]
  by auto

lemma LIMSEQ_le_const:
  "\<lbrakk>X ----> (x::real); \<exists>N. \<forall>n\<ge>N. a \<le> X n\<rbrakk> \<Longrightarrow> a \<le> x"
apply (rule ccontr, simp only: linorder_not_le)
apply (drule_tac r="a - x" in LIMSEQ_D, simp)
apply clarsimp
apply (drule_tac x="max N no" in spec, drule mp, rule le_maxI1)
apply (drule_tac x="max N no" in spec, drule mp, rule le_maxI2)
apply simp
done

lemma LIMSEQ_le_const2:
  "\<lbrakk>X ----> (x::real); \<exists>N. \<forall>n\<ge>N. X n \<le> a\<rbrakk> \<Longrightarrow> x \<le> a"
apply (subgoal_tac "- a \<le> - x", simp)
apply (rule LIMSEQ_le_const)
apply (erule tendsto_minus)
apply simp
done

lemma LIMSEQ_le:
  "\<lbrakk>X ----> x; Y ----> y; \<exists>N. \<forall>n\<ge>N. X n \<le> Y n\<rbrakk> \<Longrightarrow> x \<le> (y::real)"
apply (subgoal_tac "0 \<le> y - x", simp)
apply (rule LIMSEQ_le_const)
apply (erule (1) tendsto_diff)
apply (simp add: le_diff_eq)
done


subsection {* Convergence *}

lemma limI: "X ----> L ==> lim X = L"
apply (simp add: lim_def)
apply (blast intro: LIMSEQ_unique)
done

lemma convergentD: "convergent X ==> \<exists>L. (X ----> L)"
by (simp add: convergent_def)

lemma convergentI: "(X ----> L) ==> convergent X"
by (auto simp add: convergent_def)

lemma convergent_LIMSEQ_iff: "convergent X = (X ----> lim X)"
by (auto intro: theI LIMSEQ_unique simp add: convergent_def lim_def)

lemma convergent_const: "convergent (\<lambda>n. c)"
  by (rule convergentI, rule tendsto_const)

lemma convergent_add:
  fixes X Y :: "nat \<Rightarrow> 'a::real_normed_vector"
  assumes "convergent (\<lambda>n. X n)"
  assumes "convergent (\<lambda>n. Y n)"
  shows "convergent (\<lambda>n. X n + Y n)"
  using assms unfolding convergent_def by (fast intro: tendsto_add)

lemma convergent_setsum:
  fixes X :: "'a \<Rightarrow> nat \<Rightarrow> 'b::real_normed_vector"
  assumes "\<And>i. i \<in> A \<Longrightarrow> convergent (\<lambda>n. X i n)"
  shows "convergent (\<lambda>n. \<Sum>i\<in>A. X i n)"
proof (cases "finite A")
  case True from this and assms show ?thesis
    by (induct A set: finite) (simp_all add: convergent_const convergent_add)
qed (simp add: convergent_const)

lemma (in bounded_linear) convergent:
  assumes "convergent (\<lambda>n. X n)"
  shows "convergent (\<lambda>n. f (X n))"
  using assms unfolding convergent_def by (fast intro: tendsto)

lemma (in bounded_bilinear) convergent:
  assumes "convergent (\<lambda>n. X n)" and "convergent (\<lambda>n. Y n)"
  shows "convergent (\<lambda>n. X n ** Y n)"
  using assms unfolding convergent_def by (fast intro: tendsto)

lemma convergent_minus_iff:
  fixes X :: "nat \<Rightarrow> 'a::real_normed_vector"
  shows "convergent X \<longleftrightarrow> convergent (\<lambda>n. - X n)"
apply (simp add: convergent_def)
apply (auto dest: tendsto_minus)
apply (drule tendsto_minus, auto)
done

lemma lim_le:
  fixes x :: real
  assumes f: "convergent f" and fn_le: "!!n. f n \<le> x"
  shows "lim f \<le> x"
proof (rule classical)
  assume "\<not> lim f \<le> x"
  hence 0: "0 < lim f - x" by arith
  have 1: "f----> lim f"
    by (metis convergent_LIMSEQ_iff f) 
  thus ?thesis
    proof (simp add: LIMSEQ_iff)
      assume "\<forall>r>0. \<exists>no. \<forall>n\<ge>no. \<bar>f n - lim f\<bar> < r"
      hence "\<exists>no. \<forall>n\<ge>no. \<bar>f n - lim f\<bar> < lim f - x"
        by (metis 0)
      from this obtain no where "\<forall>n\<ge>no. \<bar>f n - lim f\<bar> < lim f - x"
        by blast
      thus "lim f \<le> x"
        by (metis 1 LIMSEQ_le_const2 fn_le)
    qed
qed

lemma monoseq_le:
  fixes a :: "nat \<Rightarrow> real"
  assumes "monoseq a" and "a ----> x"
  shows "((\<forall> n. a n \<le> x) \<and> (\<forall>m. \<forall>n\<ge>m. a m \<le> a n)) \<or> 
         ((\<forall> n. x \<le> a n) \<and> (\<forall>m. \<forall>n\<ge>m. a n \<le> a m))"
proof -
  { fix x n fix a :: "nat \<Rightarrow> real"
    assume "a ----> x" and "\<forall> m. \<forall> n \<ge> m. a m \<le> a n"
    hence monotone: "\<And> m n. m \<le> n \<Longrightarrow> a m \<le> a n" by auto
    have "a n \<le> x"
    proof (rule ccontr)
      assume "\<not> a n \<le> x" hence "x < a n" by auto
      hence "0 < a n - x" by auto
      from `a ----> x`[THEN LIMSEQ_D, OF this]
      obtain no where "\<And>n'. no \<le> n' \<Longrightarrow> norm (a n' - x) < a n - x" by blast
      hence "norm (a (max no n) - x) < a n - x" by auto
      moreover
      { fix n' have "n \<le> n' \<Longrightarrow> x < a n'" using monotone[where m=n and n=n'] and `x < a n` by auto }
      hence "x < a (max no n)" by auto
      ultimately
      have "a (max no n) < a n" by auto
      with monotone[where m=n and n="max no n"]
      show False by (auto simp:max_def split:split_if_asm)
    qed
  } note top_down = this
  { fix x n m fix a :: "nat \<Rightarrow> real"
    assume "a ----> x" and "monoseq a" and "a m < x"
    have "a n \<le> x \<and> (\<forall> m. \<forall> n \<ge> m. a m \<le> a n)"
    proof (cases "\<forall> m. \<forall> n \<ge> m. a m \<le> a n")
      case True with top_down and `a ----> x` show ?thesis by auto
    next
      case False with `monoseq a`[unfolded monoseq_def] have "\<forall> m. \<forall> n \<ge> m. - a m \<le> - a n" by auto
      hence "- a m \<le> - x" using top_down[OF tendsto_minus[OF `a ----> x`]] by blast
      hence False using `a m < x` by auto
      thus ?thesis ..
    qed
  } note when_decided = this

  show ?thesis
  proof (cases "\<exists> m. a m \<noteq> x")
    case True then obtain m where "a m \<noteq> x" by auto
    show ?thesis
    proof (cases "a m < x")
      case True with when_decided[OF `a ----> x` `monoseq a`, where m2=m]
      show ?thesis by blast
    next
      case False hence "- a m < - x" using `a m \<noteq> x` by auto
      with when_decided[OF tendsto_minus[OF `a ----> x`] monoseq_minus[OF `monoseq a`], where m2=m]
      show ?thesis by auto
    qed
  qed auto
qed

lemma LIMSEQ_subseq_LIMSEQ:
  "\<lbrakk> X ----> L; subseq f \<rbrakk> \<Longrightarrow> (X o f) ----> L"
apply (rule topological_tendstoI)
apply (drule (2) topological_tendstoD)
apply (simp only: eventually_sequentially)
apply (clarify, rule_tac x=N in exI, clarsimp)
apply (blast intro: seq_suble le_trans dest!: spec) 
done

lemma convergent_subseq_convergent:
  "\<lbrakk>convergent X; subseq f\<rbrakk> \<Longrightarrow> convergent (X o f)"
  unfolding convergent_def by (auto intro: LIMSEQ_subseq_LIMSEQ)


subsection {* Bounded Monotonic Sequences *}

text{*Bounded Sequence*}

lemma BseqD: "Bseq X ==> \<exists>K. 0 < K & (\<forall>n. norm (X n) \<le> K)"
by (simp add: Bseq_def)

lemma BseqI: "[| 0 < K; \<forall>n. norm (X n) \<le> K |] ==> Bseq X"
by (auto simp add: Bseq_def)

lemma lemma_NBseq_def:
     "(\<exists>K > 0. \<forall>n. norm (X n) \<le> K) =
      (\<exists>N. \<forall>n. norm (X n) \<le> real(Suc N))"
proof auto
  fix K :: real
  from reals_Archimedean2 obtain n :: nat where "K < real n" ..
  then have "K \<le> real (Suc n)" by auto
  assume "\<forall>m. norm (X m) \<le> K"
  have "\<forall>m. norm (X m) \<le> real (Suc n)"
  proof
    fix m :: 'a
    from `\<forall>m. norm (X m) \<le> K` have "norm (X m) \<le> K" ..
    with `K \<le> real (Suc n)` show "norm (X m) \<le> real (Suc n)" by auto
  qed
  then show "\<exists>N. \<forall>n. norm (X n) \<le> real (Suc N)" ..
next
  fix N :: nat
  have "real (Suc N) > 0" by (simp add: real_of_nat_Suc)
  moreover assume "\<forall>n. norm (X n) \<le> real (Suc N)"
  ultimately show "\<exists>K>0. \<forall>n. norm (X n) \<le> K" by blast
qed


text{* alternative definition for Bseq *}
lemma Bseq_iff: "Bseq X = (\<exists>N. \<forall>n. norm (X n) \<le> real(Suc N))"
apply (simp add: Bseq_def)
apply (simp (no_asm) add: lemma_NBseq_def)
done

lemma lemma_NBseq_def2:
     "(\<exists>K > 0. \<forall>n. norm (X n) \<le> K) = (\<exists>N. \<forall>n. norm (X n) < real(Suc N))"
apply (subst lemma_NBseq_def, auto)
apply (rule_tac x = "Suc N" in exI)
apply (rule_tac [2] x = N in exI)
apply (auto simp add: real_of_nat_Suc)
 prefer 2 apply (blast intro: order_less_imp_le)
apply (drule_tac x = n in spec, simp)
done

(* yet another definition for Bseq *)
lemma Bseq_iff1a: "Bseq X = (\<exists>N. \<forall>n. norm (X n) < real(Suc N))"
by (simp add: Bseq_def lemma_NBseq_def2)

subsubsection{*Upper Bounds and Lubs of Bounded Sequences*}

lemma Bseq_isUb:
  "!!(X::nat=>real). Bseq X ==> \<exists>U. isUb (UNIV::real set) {x. \<exists>n. X n = x} U"
by (auto intro: isUbI setleI simp add: Bseq_def abs_le_iff)

text{* Use completeness of reals (supremum property)
   to show that any bounded sequence has a least upper bound*}

lemma Bseq_isLub:
  "!!(X::nat=>real). Bseq X ==>
   \<exists>U. isLub (UNIV::real set) {x. \<exists>n. X n = x} U"
by (blast intro: reals_complete Bseq_isUb)

subsubsection{*A Bounded and Monotonic Sequence Converges*}

(* TODO: delete *)
(* FIXME: one use in NSA/HSEQ.thy *)
lemma Bmonoseq_LIMSEQ: "\<forall>n. m \<le> n --> X n = X m ==> \<exists>L. (X ----> L)"
unfolding tendsto_def eventually_sequentially
apply (rule_tac x = "X m" in exI, safe)
apply (rule_tac x = m in exI, safe)
apply (drule spec, erule impE, auto)
done

text {* A monotone sequence converges to its least upper bound. *}

lemma isLub_mono_imp_LIMSEQ:
  fixes X :: "nat \<Rightarrow> real"
  assumes u: "isLub UNIV {x. \<exists>n. X n = x} u" (* FIXME: use 'range X' *)
  assumes X: "\<forall>m n. m \<le> n \<longrightarrow> X m \<le> X n"
  shows "X ----> u"
proof (rule LIMSEQ_I)
  have 1: "\<forall>n. X n \<le> u"
    using isLubD2 [OF u] by auto
  have "\<forall>y. (\<forall>n. X n \<le> y) \<longrightarrow> u \<le> y"
    using isLub_le_isUb [OF u] by (auto simp add: isUb_def setle_def)
  hence 2: "\<forall>y<u. \<exists>n. y < X n"
    by (metis not_le)
  fix r :: real assume "0 < r"
  hence "u - r < u" by simp
  hence "\<exists>m. u - r < X m" using 2 by simp
  then obtain m where "u - r < X m" ..
  with X have "\<forall>n\<ge>m. u - r < X n"
    by (fast intro: less_le_trans)
  hence "\<exists>m. \<forall>n\<ge>m. u - r < X n" ..
  thus "\<exists>m. \<forall>n\<ge>m. norm (X n - u) < r"
    using 1 by (simp add: diff_less_eq add_commute)
qed

text{*A standard proof of the theorem for monotone increasing sequence*}

lemma Bseq_mono_convergent:
     "[| Bseq X; \<forall>m. \<forall>n \<ge> m. X m \<le> X n |] ==> convergent (X::nat=>real)"
proof -
  assume "Bseq X"
  then obtain u where u: "isLub UNIV {x. \<exists>n. X n = x} u"
    using Bseq_isLub by fast
  assume "\<forall>m n. m \<le> n \<longrightarrow> X m \<le> X n"
  with u have "X ----> u"
    by (rule isLub_mono_imp_LIMSEQ)
  thus "convergent X"
    by (rule convergentI)
qed

lemma Bseq_minus_iff: "Bseq (%n. -(X n)) = Bseq X"
by (simp add: Bseq_def)

text{*Main monotonicity theorem*}
lemma Bseq_monoseq_convergent: "[| Bseq X; monoseq X |] ==> convergent (X::nat\<Rightarrow>real)"
apply (simp add: monoseq_def, safe)
apply (rule_tac [2] convergent_minus_iff [THEN ssubst])
apply (drule_tac [2] Bseq_minus_iff [THEN ssubst])
apply (auto intro!: Bseq_mono_convergent)
done

subsubsection{*Increasing and Decreasing Series*}

lemma incseq_le:
  fixes X :: "nat \<Rightarrow> real"
  assumes inc: "incseq X" and lim: "X ----> L" shows "X n \<le> L"
  using monoseq_le [OF incseq_imp_monoseq [OF inc] lim]
proof
  assume "(\<forall>n. X n \<le> L) \<and> (\<forall>m n. m \<le> n \<longrightarrow> X m \<le> X n)"
  thus ?thesis by simp
next
  assume "(\<forall>n. L \<le> X n) \<and> (\<forall>m n. m \<le> n \<longrightarrow> X n \<le> X m)"
  hence const: "(!!m n. m \<le> n \<Longrightarrow> X n = X m)" using inc
    by (auto simp add: incseq_def intro: order_antisym)
  have X: "!!n. X n = X 0"
    by (blast intro: const [of 0]) 
  have "X = (\<lambda>n. X 0)"
    by (blast intro: X)
  hence "L = X 0" using tendsto_const [of "X 0" sequentially]
    by (auto intro: LIMSEQ_unique lim)
  thus ?thesis
    by (blast intro: eq_refl X)
qed

lemma decseq_le:
  fixes X :: "nat \<Rightarrow> real" assumes dec: "decseq X" and lim: "X ----> L" shows "L \<le> X n"
proof -
  have inc: "incseq (\<lambda>n. - X n)" using dec
    by (simp add: decseq_eq_incseq)
  have "- X n \<le> - L" 
    by (blast intro: incseq_le [OF inc] tendsto_minus lim) 
  thus ?thesis
    by simp
qed

subsubsection{*A Few More Equivalence Theorems for Boundedness*}

text{*alternative formulation for boundedness*}
lemma Bseq_iff2: "Bseq X = (\<exists>k > 0. \<exists>x. \<forall>n. norm (X(n) + -x) \<le> k)"
apply (unfold Bseq_def, safe)
apply (rule_tac [2] x = "k + norm x" in exI)
apply (rule_tac x = K in exI, simp)
apply (rule exI [where x = 0], auto)
apply (erule order_less_le_trans, simp)
apply (drule_tac x=n in spec, fold diff_minus)
apply (drule order_trans [OF norm_triangle_ineq2])
apply simp
done

text{*alternative formulation for boundedness*}
lemma Bseq_iff3: "Bseq X = (\<exists>k > 0. \<exists>N. \<forall>n. norm(X(n) + -X(N)) \<le> k)"
apply safe
apply (simp add: Bseq_def, safe)
apply (rule_tac x = "K + norm (X N)" in exI)
apply auto
apply (erule order_less_le_trans, simp)
apply (rule_tac x = N in exI, safe)
apply (drule_tac x = n in spec)
apply (rule order_trans [OF norm_triangle_ineq], simp)
apply (auto simp add: Bseq_iff2)
done

lemma BseqI2: "(\<forall>n. k \<le> f n & f n \<le> (K::real)) ==> Bseq f"
apply (simp add: Bseq_def)
apply (rule_tac x = " (\<bar>k\<bar> + \<bar>K\<bar>) + 1" in exI, auto)
apply (drule_tac x = n in spec, arith)
done


subsection {* Cauchy Sequences *}

lemma metric_CauchyI:
  "(\<And>e. 0 < e \<Longrightarrow> \<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. dist (X m) (X n) < e) \<Longrightarrow> Cauchy X"
by (simp add: Cauchy_def)

lemma metric_CauchyD:
  "\<lbrakk>Cauchy X; 0 < e\<rbrakk> \<Longrightarrow> \<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. dist (X m) (X n) < e"
by (simp add: Cauchy_def)

lemma Cauchy_iff:
  fixes X :: "nat \<Rightarrow> 'a::real_normed_vector"
  shows "Cauchy X \<longleftrightarrow> (\<forall>e>0. \<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. norm (X m - X n) < e)"
unfolding Cauchy_def dist_norm ..

lemma Cauchy_iff2:
     "Cauchy X =
      (\<forall>j. (\<exists>M. \<forall>m \<ge> M. \<forall>n \<ge> M. \<bar>X m - X n\<bar> < inverse(real (Suc j))))"
apply (simp add: Cauchy_iff, auto)
apply (drule reals_Archimedean, safe)
apply (drule_tac x = n in spec, auto)
apply (rule_tac x = M in exI, auto)
apply (drule_tac x = m in spec, simp)
apply (drule_tac x = na in spec, auto)
done

lemma CauchyI:
  fixes X :: "nat \<Rightarrow> 'a::real_normed_vector"
  shows "(\<And>e. 0 < e \<Longrightarrow> \<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. norm (X m - X n) < e) \<Longrightarrow> Cauchy X"
by (simp add: Cauchy_iff)

lemma CauchyD:
  fixes X :: "nat \<Rightarrow> 'a::real_normed_vector"
  shows "\<lbrakk>Cauchy X; 0 < e\<rbrakk> \<Longrightarrow> \<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. norm (X m - X n) < e"
by (simp add: Cauchy_iff)

lemma Cauchy_subseq_Cauchy:
  "\<lbrakk> Cauchy X; subseq f \<rbrakk> \<Longrightarrow> Cauchy (X o f)"
apply (auto simp add: Cauchy_def)
apply (drule_tac x=e in spec, clarify)
apply (rule_tac x=M in exI, clarify)
apply (blast intro: le_trans [OF _ seq_suble] dest!: spec)
done

subsubsection {* Cauchy Sequences are Bounded *}

text{*A Cauchy sequence is bounded -- this is the standard
  proof mechanization rather than the nonstandard proof*}

lemma lemmaCauchy: "\<forall>n \<ge> M. norm (X M - X n) < (1::real)
          ==>  \<forall>n \<ge> M. norm (X n :: 'a::real_normed_vector) < 1 + norm (X M)"
apply (clarify, drule spec, drule (1) mp)
apply (simp only: norm_minus_commute)
apply (drule order_le_less_trans [OF norm_triangle_ineq2])
apply simp
done

lemma Cauchy_Bseq: "Cauchy X ==> Bseq X"
apply (simp add: Cauchy_iff)
apply (drule spec, drule mp, rule zero_less_one, safe)
apply (drule_tac x="M" in spec, simp)
apply (drule lemmaCauchy)
apply (rule_tac k="M" in Bseq_offset)
apply (simp add: Bseq_def)
apply (rule_tac x="1 + norm (X M)" in exI)
apply (rule conjI, rule order_less_le_trans [OF zero_less_one], simp)
apply (simp add: order_less_imp_le)
done

subsubsection {* Cauchy Sequences are Convergent *}

class complete_space = metric_space +
  assumes Cauchy_convergent: "Cauchy X \<Longrightarrow> convergent X"

class banach = real_normed_vector + complete_space

theorem LIMSEQ_imp_Cauchy:
  assumes X: "X ----> a" shows "Cauchy X"
proof (rule metric_CauchyI)
  fix e::real assume "0 < e"
  hence "0 < e/2" by simp
  with X have "\<exists>N. \<forall>n\<ge>N. dist (X n) a < e/2" by (rule metric_LIMSEQ_D)
  then obtain N where N: "\<forall>n\<ge>N. dist (X n) a < e/2" ..
  show "\<exists>N. \<forall>m\<ge>N. \<forall>n\<ge>N. dist (X m) (X n) < e"
  proof (intro exI allI impI)
    fix m assume "N \<le> m"
    hence m: "dist (X m) a < e/2" using N by fast
    fix n assume "N \<le> n"
    hence n: "dist (X n) a < e/2" using N by fast
    have "dist (X m) (X n) \<le> dist (X m) a + dist (X n) a"
      by (rule dist_triangle2)
    also from m n have "\<dots> < e" by simp
    finally show "dist (X m) (X n) < e" .
  qed
qed

lemma convergent_Cauchy: "convergent X \<Longrightarrow> Cauchy X"
unfolding convergent_def
by (erule exE, erule LIMSEQ_imp_Cauchy)

lemma Cauchy_convergent_iff:
  fixes X :: "nat \<Rightarrow> 'a::complete_space"
  shows "Cauchy X = convergent X"
by (fast intro: Cauchy_convergent convergent_Cauchy)

text {*
Proof that Cauchy sequences converge based on the one from
http://pirate.shu.edu/~wachsmut/ira/numseq/proofs/cauconv.html
*}

text {*
  If sequence @{term "X"} is Cauchy, then its limit is the lub of
  @{term "{r::real. \<exists>N. \<forall>n\<ge>N. r < X n}"}
*}

lemma isUb_UNIV_I: "(\<And>y. y \<in> S \<Longrightarrow> y \<le> u) \<Longrightarrow> isUb UNIV S u"
by (simp add: isUbI setleI)

locale real_Cauchy =
  fixes X :: "nat \<Rightarrow> real"
  assumes X: "Cauchy X"
  fixes S :: "real set"
  defines S_def: "S \<equiv> {x::real. \<exists>N. \<forall>n\<ge>N. x < X n}"

lemma real_CauchyI:
  assumes "Cauchy X"
  shows "real_Cauchy X"
  proof qed (fact assms)

lemma (in real_Cauchy) mem_S: "\<forall>n\<ge>N. x < X n \<Longrightarrow> x \<in> S"
by (unfold S_def, auto)

lemma (in real_Cauchy) bound_isUb:
  assumes N: "\<forall>n\<ge>N. X n < x"
  shows "isUb UNIV S x"
proof (rule isUb_UNIV_I)
  fix y::real assume "y \<in> S"
  hence "\<exists>M. \<forall>n\<ge>M. y < X n"
    by (simp add: S_def)
  then obtain M where "\<forall>n\<ge>M. y < X n" ..
  hence "y < X (max M N)" by simp
  also have "\<dots> < x" using N by simp
  finally show "y \<le> x"
    by (rule order_less_imp_le)
qed

lemma (in real_Cauchy) isLub_ex: "\<exists>u. isLub UNIV S u"
proof (rule reals_complete)
  obtain N where "\<forall>m\<ge>N. \<forall>n\<ge>N. norm (X m - X n) < 1"
    using CauchyD [OF X zero_less_one] by auto
  hence N: "\<forall>n\<ge>N. norm (X n - X N) < 1" by simp
  show "\<exists>x. x \<in> S"
  proof
    from N have "\<forall>n\<ge>N. X N - 1 < X n"
      by (simp add: abs_diff_less_iff)
    thus "X N - 1 \<in> S" by (rule mem_S)
  qed
  show "\<exists>u. isUb UNIV S u"
  proof
    from N have "\<forall>n\<ge>N. X n < X N + 1"
      by (simp add: abs_diff_less_iff)
    thus "isUb UNIV S (X N + 1)"
      by (rule bound_isUb)
  qed
qed

lemma (in real_Cauchy) isLub_imp_LIMSEQ:
  assumes x: "isLub UNIV S x"
  shows "X ----> x"
proof (rule LIMSEQ_I)
  fix r::real assume "0 < r"
  hence r: "0 < r/2" by simp
  obtain N where "\<forall>n\<ge>N. \<forall>m\<ge>N. norm (X n - X m) < r/2"
    using CauchyD [OF X r] by auto
  hence "\<forall>n\<ge>N. norm (X n - X N) < r/2" by simp
  hence N: "\<forall>n\<ge>N. X N - r/2 < X n \<and> X n < X N + r/2"
    by (simp only: real_norm_def abs_diff_less_iff)

  from N have "\<forall>n\<ge>N. X N - r/2 < X n" by fast
  hence "X N - r/2 \<in> S" by (rule mem_S)
  hence 1: "X N - r/2 \<le> x" using x isLub_isUb isUbD by fast

  from N have "\<forall>n\<ge>N. X n < X N + r/2" by fast
  hence "isUb UNIV S (X N + r/2)" by (rule bound_isUb)
  hence 2: "x \<le> X N + r/2" using x isLub_le_isUb by fast

  show "\<exists>N. \<forall>n\<ge>N. norm (X n - x) < r"
  proof (intro exI allI impI)
    fix n assume n: "N \<le> n"
    from N n have "X n < X N + r/2" and "X N - r/2 < X n" by simp+
    thus "norm (X n - x) < r" using 1 2
      by (simp add: abs_diff_less_iff)
  qed
qed

lemma (in real_Cauchy) LIMSEQ_ex: "\<exists>x. X ----> x"
proof -
  obtain x where "isLub UNIV S x"
    using isLub_ex by fast
  hence "X ----> x"
    by (rule isLub_imp_LIMSEQ)
  thus ?thesis ..
qed

lemma real_Cauchy_convergent:
  fixes X :: "nat \<Rightarrow> real"
  shows "Cauchy X \<Longrightarrow> convergent X"
unfolding convergent_def
by (rule real_Cauchy.LIMSEQ_ex)
 (rule real_CauchyI)

instance real :: banach
by intro_classes (rule real_Cauchy_convergent)


subsection {* Power Sequences *}

text{*The sequence @{term "x^n"} tends to 0 if @{term "0\<le>x"} and @{term
"x<1"}.  Proof will use (NS) Cauchy equivalence for convergence and
  also fact that bounded and monotonic sequence converges.*}

lemma Bseq_realpow: "[| 0 \<le> (x::real); x \<le> 1 |] ==> Bseq (%n. x ^ n)"
apply (simp add: Bseq_def)
apply (rule_tac x = 1 in exI)
apply (simp add: power_abs)
apply (auto dest: power_mono)
done

lemma monoseq_realpow: fixes x :: real shows "[| 0 \<le> x; x \<le> 1 |] ==> monoseq (%n. x ^ n)"
apply (clarify intro!: mono_SucI2)
apply (cut_tac n = n and N = "Suc n" and a = x in power_decreasing, auto)
done

lemma convergent_realpow:
  "[| 0 \<le> (x::real); x \<le> 1 |] ==> convergent (%n. x ^ n)"
by (blast intro!: Bseq_monoseq_convergent Bseq_realpow monoseq_realpow)

lemma LIMSEQ_inverse_realpow_zero_lemma:
  fixes x :: real
  assumes x: "0 \<le> x"
  shows "real n * x + 1 \<le> (x + 1) ^ n"
apply (induct n)
apply simp
apply simp
apply (rule order_trans)
prefer 2
apply (erule mult_left_mono)
apply (rule add_increasing [OF x], simp)
apply (simp add: real_of_nat_Suc)
apply (simp add: ring_distribs)
apply (simp add: mult_nonneg_nonneg x)
done

lemma LIMSEQ_inverse_realpow_zero:
  "1 < (x::real) \<Longrightarrow> (\<lambda>n. inverse (x ^ n)) ----> 0"
proof (rule LIMSEQ_inverse_zero [rule_format])
  fix y :: real
  assume x: "1 < x"
  hence "0 < x - 1" by simp
  hence "\<forall>y. \<exists>N::nat. y < real N * (x - 1)"
    by (rule reals_Archimedean3)
  hence "\<exists>N::nat. y < real N * (x - 1)" ..
  then obtain N::nat where "y < real N * (x - 1)" ..
  also have "\<dots> \<le> real N * (x - 1) + 1" by simp
  also have "\<dots> \<le> (x - 1 + 1) ^ N"
    by (rule LIMSEQ_inverse_realpow_zero_lemma, cut_tac x, simp)
  also have "\<dots> = x ^ N" by simp
  finally have "y < x ^ N" .
  hence "\<forall>n\<ge>N. y < x ^ n"
    apply clarify
    apply (erule order_less_le_trans)
    apply (erule power_increasing)
    apply (rule order_less_imp_le [OF x])
    done
  thus "\<exists>N. \<forall>n\<ge>N. y < x ^ n" ..
qed

lemma LIMSEQ_realpow_zero:
  "\<lbrakk>0 \<le> (x::real); x < 1\<rbrakk> \<Longrightarrow> (\<lambda>n. x ^ n) ----> 0"
proof (cases)
  assume "x = 0"
  hence "(\<lambda>n. x ^ Suc n) ----> 0" by (simp add: tendsto_const)
  thus ?thesis by (rule LIMSEQ_imp_Suc)
next
  assume "0 \<le> x" and "x \<noteq> 0"
  hence x0: "0 < x" by simp
  assume x1: "x < 1"
  from x0 x1 have "1 < inverse x"
    by (rule one_less_inverse)
  hence "(\<lambda>n. inverse (inverse x ^ n)) ----> 0"
    by (rule LIMSEQ_inverse_realpow_zero)
  thus ?thesis by (simp add: power_inverse)
qed

lemma LIMSEQ_power_zero:
  fixes x :: "'a::{real_normed_algebra_1}"
  shows "norm x < 1 \<Longrightarrow> (\<lambda>n. x ^ n) ----> 0"
apply (drule LIMSEQ_realpow_zero [OF norm_ge_zero])
apply (simp only: tendsto_Zfun_iff, erule Zfun_le)
apply (simp add: power_abs norm_power_ineq)
done

lemma LIMSEQ_divide_realpow_zero:
  "1 < (x::real) ==> (%n. a / (x ^ n)) ----> 0"
using tendsto_mult [OF tendsto_const [of a]
  LIMSEQ_realpow_zero [of "inverse x"]]
apply (auto simp add: divide_inverse power_inverse)
apply (simp add: inverse_eq_divide pos_divide_less_eq)
done

text{*Limit of @{term "c^n"} for @{term"\<bar>c\<bar> < 1"}*}

lemma LIMSEQ_rabs_realpow_zero: "\<bar>c\<bar> < (1::real) ==> (%n. \<bar>c\<bar> ^ n) ----> 0"
by (rule LIMSEQ_realpow_zero [OF abs_ge_zero])

lemma LIMSEQ_rabs_realpow_zero2: "\<bar>c\<bar> < (1::real) ==> (%n. c ^ n) ----> 0"
apply (rule tendsto_rabs_zero_cancel)
apply (auto intro: LIMSEQ_rabs_realpow_zero simp add: power_abs)
done

end
