(* Author: Johannes Hölzl <hoelzl@in.tum.de> *)

header {* Formalizing the IPv4-address allocation in ZeroConf *}

theory Zeroconf_Analysis
  imports "../Rewarded_DTMC"
begin

subsection {* Definition of a ZeroConf allocation run *}

locale Zeroconf_Analysis =
  fixes N :: nat and p q r E :: real
  assumes p: "0 < p" "p < 1" and q: "0 < q" "q < 1"
  assumes r: "0 \<le> r" and E: "0 \<le> E"

datatype zc_state = start 
                  | probe nat
                  | ok
                  | error

context Zeroconf_Analysis
begin

definition "S = probe ` {.. N} \<union> ({start} \<union> {ok} \<union> {error})"

primrec \<tau> where
  "\<tau> start     = (\<lambda>_. 0) (probe 0 := q, ok := 1 - q)"
| "\<tau> (probe n) = (if n < N then (\<lambda>_. 0) (probe (Suc n) := p, start := 1 - p) 
                           else (\<lambda>_. 0) (error := p, start := 1 - p))"
| "\<tau> ok        = (\<lambda>_. 0) (ok := 1)"
| "\<tau> error     = (\<lambda>_. 0) (error := 1)"

primrec \<rho> where
  "\<rho> start     = (\<lambda>_. 0) (probe 0 := r, ok := r * (N + 1))"
| "\<rho> (probe n) = (if n < N then (\<lambda>_. 0) (probe (Suc n) := r) else (\<lambda>_. 0) (error := E))"
| "\<rho> ok        = (\<lambda>_. 0) (ok := 0)"
| "\<rho> error     = (\<lambda>_. 0) (error := 0)"

lemma inj_probe: "inj_on probe X"
  by (simp add: inj_on_def)

lemma setsum_S:
  "(\<Sum>s\<in>S. f s) = f start + (\<Sum>p\<le>N. f (probe p)) + f ok + f error"
  unfolding S_def
  by (subst setsum_Un_disjoint) (auto simp: inj_probe setsum_reindex field_simps)

lemma SE:
  assumes "s \<in> S"
  obtains n where "n \<le> N" "s = probe n" | "s = start" | "s = ok" | "s = error"
  using assms unfolding S_def by blast

lemma SI[intro!, simp]:
  "start \<in> S"
  "ok \<in> S"
  "error \<in> S"
  "n \<le> N \<Longrightarrow> probe n \<in> S"
  by (auto simp: S_def)

end

subsection {* The allocation run is a rewarded DTMC *}

sublocale Zeroconf_Analysis \<subseteq> Rewarded_DTMC S start \<tau> \<rho> "\<lambda>s. 0"
  proof
  qed (insert p q r E,
       auto simp add: mult_nonneg_nonneg S_def \<rho>_def setsum_S setsum_cases field_simps elim!: SE)

lemma if_mult:
  "\<And>P a b c. (if P then a else b) * c =  (if P then a * c else b * c)"
  "\<And>P a b c. c * (if P then a else b) =  (if P then c * a else c * b)"
  by auto

context Zeroconf_Analysis
begin

lemma pos_neg_q_pn: "0 < 1 - q * (1 - p^Suc N)"
proof -
  have "p ^ Suc N \<le> 1 ^ Suc N"
    using p by (intro power_mono) auto
  with p q have "q * (1 - p^Suc N) < 1 * 1"
    by (intro mult_strict_mono) (auto simp: field_simps simp del: power_Suc)
  then show ?thesis by simp
qed

subsection {* Probability of a erroneous allocation *}

definition "P_err s = prob s {\<omega>\<in>UNIV \<rightarrow> S. nat_case s \<omega> \<in> until S {error}}"

lemma P_err_alt: "P_err s = prob s (nat_case s -` until S {error} \<inter> (UNIV \<rightarrow> S))"
  unfolding P_err_def by (auto intro!: arg_cong2[where f=prob])

lemma P_err_ok: "P_err ok = 0"
proof -
  have "reachable (S - {error}) ok \<subseteq> {ok}"
    by (rule reachable_closed') auto
  then show "P_err ok = 0"
    unfolding P_err_alt
    by (subst until_eq_0_iff_not_reachable) auto
qed

lemma P_err_error[simp]: "P_err error = 1"
  by (simp add: P_err_def)

lemma P_err_sum: "s \<in> S \<Longrightarrow> 
    P_err s = \<tau> s start * P_err start + \<tau> s error + (\<Sum>p\<le>N. \<tau> s (probe p) * P_err (probe p))"
  using P_err_ok
  by (cases "s = error")
     (simp_all add: prob_eq_sum[of s] setsum_S until_Int_space_eq P_err_alt)

lemma P_err_last[simp]: "P_err (probe N) = p + (1 - p) * P_err start"
  by (subst P_err_sum) simp_all

lemma P_err_start[simp]: "P_err start = q * P_err (probe 0)"
  by (subst P_err_sum) (simp_all add: if_mult setsum_cases)

lemma P_err_probe: "n \<le> N \<Longrightarrow> P_err (probe (N - n)) = p ^ Suc n + (1 - p^Suc n) * P_err start"
proof (induct n)
  case (Suc n)
  then have "P_err (probe (N - Suc n)) =
    p * (p ^ Suc n + (1 - p^Suc n) * P_err start) + (1 - p) * P_err start"
    by (subst P_err_sum) (simp_all add: Suc_diff_Suc if_mult setsum_cases)
  also have "\<dots> = p^Suc (Suc n) + (1 - p^Suc (Suc n)) * P_err start"
    by (simp add: field_simps)
  finally show ?case .
qed simp

lemma prob_until_error: "P_err start = (q * p ^ Suc N) / (1 - q * (1 - p ^ Suc N))"
  using P_err_probe[of N] pos_neg_q_pn by (simp add: field_simps del: power_Suc)

subsection {* A allocation run terminates almost surely *}

lemma reachable_probe_error:
  assumes "n \<le> N"
  shows "error \<in> reachable (S - {error, ok}) (probe n)"
proof -
  def \<omega> \<equiv> "\<lambda>i. if i < N - n then probe (Suc (i + n)) else error"
  show ?thesis
    unfolding reachable_def
  proof (safe intro!: exI[of _ \<omega>]
      exI[of _ "N - n"] del: notI)
    fix i assume "i \<le> N - n"
    with p `n \<le> N` show "\<tau> (nat_case (probe n) \<omega> i) (\<omega> i) \<noteq> 0"
      by (auto simp: \<omega>_def split: nat.split)
  qed (auto simp: \<omega>_def)
qed

lemma reachable_start_error:
  "error \<in> reachable (S - {error, ok}) start"
  using q
  by (intro reachable_probe_error[THEN reachable_step]) auto

lemma AE_reaches_error_or_ok:
  assumes "s \<in> S"
  shows "AE \<omega> in path_space s. nat_case s \<omega> \<in> until S {error, ok}"
proof cases
  assume s: "s \<in> {start} \<union> (probe ` {..N})"
  have in_S: "s \<in> S" "S \<subseteq> S" "{error, ok} \<subseteq> S"
    using s by (auto simp: S_def)
  have "s \<notin> {error, ok}"
    using s by auto
  then show ?thesis
    unfolding until_eq_1_if_reachable[OF in_S]
    apply (simp add: insert_absorb)
  proof (intro conjI ballI)
    show "reachable (S - {error, ok}) s \<subseteq> S"
      by (auto simp: reachable_def)
    moreover
    fix t assume "t \<in> insert s (reachable (S - {error, ok}) s) - {error, ok}"
    with s have "(\<exists>n\<le>N. t = probe n) \<or> t = start"
      unfolding reachable_def by (auto simp: S_def)
    then show "error \<in> reachable (S - {error, ok}) t \<or>
      ok \<in> reachable (S - {error, ok}) t"
      using reachable_probe_error reachable_start_error by auto
  qed (insert in_S(1), auto simp: S_def)
next
  assume s: "s \<notin> {start} \<union> (probe ` {..N})"
  with assms have "s \<in> {error, ok}"
    by (auto simp: S_def)
  then show ?thesis
    by (auto simp: Pi_iff)
qed

subsection {* Expected runtime of an allocation run *}

definition "R \<equiv> \<lambda>s. \<integral>\<^isup>+ \<omega>. reward_until {error, ok} (nat_case s \<omega>) \<partial>path_space s"

lemma cost_from_start:
  "(R start::ereal) =
    (q * (r + p^Suc N * E + r * p * (1 - p^N) / (1 - p)) + (1 - q) * (r * Suc N)) /
    (1 - q + q * p^Suc N)"
proof -
  have "\<forall>s\<in>S. \<exists>r. R s = ereal r"
    unfolding R_def
    using positive_integral_reward_until_finite[OF _ _ AE_reaches_error_or_ok] by auto
  from bchoice[OF this] obtain R' where R': "\<And>s. s\<in>S \<Longrightarrow> R s = ereal (R' s)" by auto

  have R_sum: "\<And>s. s \<in> S \<Longrightarrow> s \<noteq> error \<Longrightarrow> s \<noteq> ok \<Longrightarrow>
    R s = (\<Sum>s'\<in>S. \<tau> s s' * (\<rho> s s' + R s'))"
    using R' unfolding R_def
    by (subst positive_integral_reward_until_real[OF _ _ _ AE_reaches_error_or_ok])
       (simp_all add: until_Int_space_eq)
  then have R'_sum: "\<And>s. s \<in> S \<Longrightarrow> s \<noteq> error \<Longrightarrow> s \<noteq> ok \<Longrightarrow>
    R' s = (\<Sum>s'\<in>S. \<tau> s s' * (\<rho> s s' + R' s'))"
    using R' by simp

  have "R ok = 0" "R error = 0"
    unfolding R_def by (simp_all add: reward_until_nat_case_0)
  with R' have R'_ok: "R' ok = 0" and R'_error: "R' error = 0"
    by simp_all

  then have R'_start: "R' start = q * (r + R' (probe 0)) + (1 - q) * (r * (N + 1))"
    by (subst R'_sum)
       (simp_all add: setsum_S field_simps setsum_addf if_mult setsum_cases)

  have R'_probe: "\<And>n. n < N \<Longrightarrow> R' (probe n) = p * R' (probe (Suc n)) + p * r + (1 - p) * R' start"
    using R'_error
    by (subst R'_sum)
       (simp_all add: setsum_S setsum_addf field_simps if_mult setsum_cases)

  have R'_N: "R' (probe N) = p * E + (1 - p) * R' start"
    using R'_error by (subst R'_sum) (simp_all add: setsum_S field_simps)

  { fix n
    assume "n \<le> N"
    then have "R' (probe (N - n)) =
      p ^ Suc n * E + (1 - p^n) * r * p / (1 - p) + (1 - p^Suc n) * R' start"
    proof (induct n)
      case 0 with R'_N show ?case by simp
    next
      case (Suc n)
      moreover then have "Suc (N - Suc n) = N - n" by simp
      ultimately show ?case
        using R'_probe[of "N - Suc n"] p
        by simp (simp add: field_simps)
    qed }
  from this[of N]
  have "R' (probe 0) = p ^ Suc N * E + (1 - p^N) * r * p / (1 - p) + (1 - p^Suc N) * R' start"
    by simp
  then have "R' start - q * (1 - p^Suc N) * R' start =
    q * (r + p^Suc N * E + (1 - p^N) * r * p / (1 - p)) + (1 - q) * (r * (N + 1))"
    by (subst R'_start) (simp, simp add: field_simps)
  then have "R' start = (q * (r + p^Suc N * E + (1 - p^N) * r * p / (1 - p)) + (1 - q) * (r * Suc N)) /
    (1 - q * (1 - p^Suc N))"
    using pos_neg_q_pn
    by (simp add: field_simps)
  then show ?thesis
    using R' p q by (simp add: field_simps)
qed

end

interpretation ZC: Zeroconf_Analysis 2 "16 / 65024 :: real" "0.01" "0.002" "3600"
  apply default
  apply auto
  done

lemma "ZC.P_err start \<le> 1 / 10^12"
  unfolding ZC.prob_until_error by (simp add: power_one_over[symmetric])

lemma "ZC.R start \<le> 0.007"
  unfolding ZC.cost_from_start by (simp add: power_one_over[symmetric])

end