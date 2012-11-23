(*  Title:      HOL/Isar_Examples/Mutilated_Checkerboard.thy
    Author:     Markus Wenzel, TU Muenchen (Isar document)
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory (original scripts)
*)

header {* The Mutilated Checker Board Problem *}

theory Mutilated_Checkerboard
imports Main
begin

text {* The Mutilated Checker Board Problem, formalized inductively.
  See \cite{paulson-mutilated-board} for the original tactic script version. *}

subsection {* Tilings *}

inductive_set tiling :: "'a set set => 'a set set"
  for A :: "'a set set"
where
  empty: "{} : tiling A"
| Un: "a : A ==> t : tiling A ==> a <= - t ==> a Un t : tiling A"


text "The union of two disjoint tilings is a tiling."

lemma tiling_Un:
  assumes "t : tiling A"
    and "u : tiling A"
    and "t Int u = {}"
  shows "t Un u : tiling A"
proof -
  let ?T = "tiling A"
  from `t : ?T` and `t Int u = {}`
  show "t Un u : ?T"
  proof (induct t)
    case empty
    with `u : ?T` show "{} Un u : ?T" by simp
  next
    case (Un a t)
    show "(a Un t) Un u : ?T"
    proof -
      have "a Un (t Un u) : ?T"
        using `a : A`
      proof (rule tiling.Un)
        from `(a Un t) Int u = {}` have "t Int u = {}" by blast
        then show "t Un u: ?T" by (rule Un)
        from `a <= - t` and `(a Un t) Int u = {}`
        show "a <= - (t Un u)" by blast
      qed
      also have "a Un (t Un u) = (a Un t) Un u"
        by (simp only: Un_assoc)
      finally show ?thesis .
    qed
  qed
qed


subsection {* Basic properties of ``below'' *}

definition below :: "nat => nat set"
  where "below n = {i. i < n}"

lemma below_less_iff [iff]: "(i: below k) = (i < k)"
  by (simp add: below_def)

lemma below_0: "below 0 = {}"
  by (simp add: below_def)

lemma Sigma_Suc1:
    "m = n + 1 ==> below m <*> B = ({n} <*> B) Un (below n <*> B)"
  by (simp add: below_def less_Suc_eq) blast

lemma Sigma_Suc2:
  "m = n + 2 ==> A <*> below m =
    (A <*> {n}) Un (A <*> {n + 1}) Un (A <*> below n)"
  by (auto simp add: below_def)

lemmas Sigma_Suc = Sigma_Suc1 Sigma_Suc2


subsection {* Basic properties of ``evnodd'' *}

definition evnodd :: "(nat * nat) set => nat => (nat * nat) set"
  where "evnodd A b = A Int {(i, j). (i + j) mod 2 = b}"

lemma evnodd_iff: "(i, j): evnodd A b = ((i, j): A  & (i + j) mod 2 = b)"
  by (simp add: evnodd_def)

lemma evnodd_subset: "evnodd A b <= A"
  unfolding evnodd_def by (rule Int_lower1)

lemma evnoddD: "x : evnodd A b ==> x : A"
  by (rule subsetD) (rule evnodd_subset)

lemma evnodd_finite: "finite A ==> finite (evnodd A b)"
  by (rule finite_subset) (rule evnodd_subset)

lemma evnodd_Un: "evnodd (A Un B) b = evnodd A b Un evnodd B b"
  unfolding evnodd_def by blast

lemma evnodd_Diff: "evnodd (A - B) b = evnodd A b - evnodd B b"
  unfolding evnodd_def by blast

lemma evnodd_empty: "evnodd {} b = {}"
  by (simp add: evnodd_def)

lemma evnodd_insert: "evnodd (insert (i, j) C) b =
    (if (i + j) mod 2 = b
      then insert (i, j) (evnodd C b) else evnodd C b)"
  by (simp add: evnodd_def)


subsection {* Dominoes *}

inductive_set domino :: "(nat * nat) set set"
where
  horiz: "{(i, j), (i, j + 1)} : domino"
| vertl: "{(i, j), (i + 1, j)} : domino"

lemma dominoes_tile_row:
  "{i} <*> below (2 * n) : tiling domino"
  (is "?B n : ?T")
proof (induct n)
  case 0
  show ?case by (simp add: below_0 tiling.empty)
next
  case (Suc n)
  let ?a = "{i} <*> {2 * n + 1} Un {i} <*> {2 * n}"
  have "?B (Suc n) = ?a Un ?B n"
    by (auto simp add: Sigma_Suc Un_assoc)
  also have "... : ?T"
  proof (rule tiling.Un)
    have "{(i, 2 * n), (i, 2 * n + 1)} : domino"
      by (rule domino.horiz)
    also have "{(i, 2 * n), (i, 2 * n + 1)} = ?a" by blast
    finally show "... : domino" .
    show "?B n : ?T" by (rule Suc)
    show "?a <= - ?B n" by blast
  qed
  finally show ?case .
qed

lemma dominoes_tile_matrix:
  "below m <*> below (2 * n) : tiling domino"
  (is "?B m : ?T")
proof (induct m)
  case 0
  show ?case by (simp add: below_0 tiling.empty)
next
  case (Suc m)
  let ?t = "{m} <*> below (2 * n)"
  have "?B (Suc m) = ?t Un ?B m" by (simp add: Sigma_Suc)
  also have "... : ?T"
  proof (rule tiling_Un)
    show "?t : ?T" by (rule dominoes_tile_row)
    show "?B m : ?T" by (rule Suc)
    show "?t Int ?B m = {}" by blast
  qed
  finally show ?case .
qed

lemma domino_singleton:
  assumes "d : domino"
    and "b < 2"
  shows "EX i j. evnodd d b = {(i, j)}"  (is "?P d")
  using assms
proof induct
  from `b < 2` have b_cases: "b = 0 | b = 1" by arith
  fix i j
  note [simp] = evnodd_empty evnodd_insert mod_Suc
  from b_cases show "?P {(i, j), (i, j + 1)}" by rule auto
  from b_cases show "?P {(i, j), (i + 1, j)}" by rule auto
qed

lemma domino_finite:
  assumes "d: domino"
  shows "finite d"
  using assms
proof induct
  fix i j :: nat
  show "finite {(i, j), (i, j + 1)}" by (intro finite.intros)
  show "finite {(i, j), (i + 1, j)}" by (intro finite.intros)
qed


subsection {* Tilings of dominoes *}

lemma tiling_domino_finite:
  assumes t: "t : tiling domino"  (is "t : ?T")
  shows "finite t"  (is "?F t")
  using t
proof induct
  show "?F {}" by (rule finite.emptyI)
  fix a t assume "?F t"
  assume "a : domino" then have "?F a" by (rule domino_finite)
  from this and `?F t` show "?F (a Un t)" by (rule finite_UnI)
qed

lemma tiling_domino_01:
  assumes t: "t : tiling domino"  (is "t : ?T")
  shows "card (evnodd t 0) = card (evnodd t 1)"
  using t
proof induct
  case empty
  show ?case by (simp add: evnodd_def)
next
  case (Un a t)
  let ?e = evnodd
  note hyp = `card (?e t 0) = card (?e t 1)`
    and at = `a <= - t`
  have card_suc:
    "!!b. b < 2 ==> card (?e (a Un t) b) = Suc (card (?e t b))"
  proof -
    fix b :: nat assume "b < 2"
    have "?e (a Un t) b = ?e a b Un ?e t b" by (rule evnodd_Un)
    also obtain i j where e: "?e a b = {(i, j)}"
    proof -
      from `a \<in> domino` and `b < 2`
      have "EX i j. ?e a b = {(i, j)}" by (rule domino_singleton)
      then show ?thesis by (blast intro: that)
    qed
    also have "... Un ?e t b = insert (i, j) (?e t b)" by simp
    also have "card ... = Suc (card (?e t b))"
    proof (rule card_insert_disjoint)
      from `t \<in> tiling domino` have "finite t"
        by (rule tiling_domino_finite)
      then show "finite (?e t b)"
        by (rule evnodd_finite)
      from e have "(i, j) : ?e a b" by simp
      with at show "(i, j) ~: ?e t b" by (blast dest: evnoddD)
    qed
    finally show "?thesis b" .
  qed
  then have "card (?e (a Un t) 0) = Suc (card (?e t 0))" by simp
  also from hyp have "card (?e t 0) = card (?e t 1)" .
  also from card_suc have "Suc ... = card (?e (a Un t) 1)"
    by simp
  finally show ?case .
qed


subsection {* Main theorem *}

definition mutilated_board :: "nat => nat => (nat * nat) set"
  where
    "mutilated_board m n =
      below (2 * (m + 1)) <*> below (2 * (n + 1))
        - {(0, 0)} - {(2 * m + 1, 2 * n + 1)}"

theorem mutil_not_tiling: "mutilated_board m n ~: tiling domino"
proof (unfold mutilated_board_def)
  let ?T = "tiling domino"
  let ?t = "below (2 * (m + 1)) <*> below (2 * (n + 1))"
  let ?t' = "?t - {(0, 0)}"
  let ?t'' = "?t' - {(2 * m + 1, 2 * n + 1)}"

  show "?t'' ~: ?T"
  proof
    have t: "?t : ?T" by (rule dominoes_tile_matrix)
    assume t'': "?t'' : ?T"

    let ?e = evnodd
    have fin: "finite (?e ?t 0)"
      by (rule evnodd_finite, rule tiling_domino_finite, rule t)

    note [simp] = evnodd_iff evnodd_empty evnodd_insert evnodd_Diff
    have "card (?e ?t'' 0) < card (?e ?t' 0)"
    proof -
      have "card (?e ?t' 0 - {(2 * m + 1, 2 * n + 1)})
        < card (?e ?t' 0)"
      proof (rule card_Diff1_less)
        from _ fin show "finite (?e ?t' 0)"
          by (rule finite_subset) auto
        show "(2 * m + 1, 2 * n + 1) : ?e ?t' 0" by simp
      qed
      then show ?thesis by simp
    qed
    also have "... < card (?e ?t 0)"
    proof -
      have "(0, 0) : ?e ?t 0" by simp
      with fin have "card (?e ?t 0 - {(0, 0)}) < card (?e ?t 0)"
        by (rule card_Diff1_less)
      then show ?thesis by simp
    qed
    also from t have "... = card (?e ?t 1)"
      by (rule tiling_domino_01)
    also have "?e ?t 1 = ?e ?t'' 1" by simp
    also from t'' have "card ... = card (?e ?t'' 0)"
      by (rule tiling_domino_01 [symmetric])
    finally have "... < ..." . then show False ..
  qed
qed

end
