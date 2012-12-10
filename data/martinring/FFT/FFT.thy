(*  Title:      Fast Fourier Transform
    Author:     Clemens Ballarin <ballarin at in.tum.de>, started 12 April 2005
    Maintainer: Clemens Ballarin <ballarin at in.tum.de>
*)

theory FFT
imports Complex_Main
begin

text {* We formalise a functional implementation of the FFT algorithm
  over the complex numbers, and its inverse.  Both are shown
  equivalent to the usual definitions
  of these operations through Vandermonde matrices.  They are also
  shown to be inverse to each other, more precisely, that composition
  of the inverse and the transformation yield the identity up to a
  scalar.

  The presentation closely follows Section 30.2 of Cormen \textit{et
  al.}, \emph{Introduction to Algorithms}, 2nd edition, MIT Press,
  2003. *}


section {* Preliminaries *}

lemma of_nat_cplx:
  "of_nat n = Complex (of_nat n) 0"
  by (induct n) (simp_all add: complex_one_def)


text {* The following two lemmas are useful for experimenting with the
  transformations, at a vector length of four. *}

lemma Ivl4:
  "{0..<4::nat} = {0, 1, 2, 3}"
proof -
  have "{0..<4::nat} = {0..<Suc (Suc (Suc (Suc 0)))}" by (simp add: eval_nat_numeral)
  also have "... = {0, 1, 2, 3}"
    by (simp add: atLeastLessThanSuc eval_nat_numeral insert_commute)
  finally show ?thesis .
qed

lemma Sum4:
  "(\<Sum>i=0..<4::nat. x i) = x 0 + x 1 + x 2 + x 3"
  by (simp add: Ivl4 eval_nat_numeral)


text {* A number of specialised lemmas for the summation operator,
  where the index set is the natural numbers *}

lemma setsum_add_nat_ivl_singleton:
  assumes less: "m < (n::nat)"
  shows "f m + setsum f {m<..<n} = setsum f {m..<n}"
proof -
  have "f m + setsum f {m<..<n} = setsum f ({m} \<union> {m<..<n})"
    by (simp add: setsum_Un_disjoint ivl_disj_int)
  also from less have "... = setsum f {m..<n}"
    by (simp only: ivl_disj_un)
  finally show ?thesis .
qed

lemma setsum_add_split_nat_ivl_singleton:
  assumes less: "m < (n::nat)"
    and g: "!!i. [| m < i; i < n |] ==> g i = f i"
  shows "f m + setsum g {m<..<n} = setsum f {m..<n}"
  using less g
  by(simp add: setsum_add_nat_ivl_singleton cong: strong_setsum_cong)

lemma setsum_add_split_nat_ivl:
  assumes le: "m <= (k::nat)" "k <= n"
    and g: "!!i. [| m <= i; i < k |] ==> g i = f i"
    and h: "!!i. [| k <= i; i < n |] ==> h i = f i"
  shows "setsum g {m..<k} + setsum h {k..<n} = setsum f {m..<n}"
  using le g h by (simp add: setsum_add_nat_ivl cong: strong_setsum_cong)

lemma ivl_splice_Un:
  "{0..<2*n::nat} = (op * 2 ` {0..<n}) \<union> ((%i. Suc (2*i)) ` {0..<n})"
  apply (unfold image_def Bex_def)
  apply auto
  apply arith
  done

lemma ivl_splice_Int:
  "(op * 2 ` {0..<n}) \<inter> ((%i. Suc (2*i)) ` {0..<n}) = {}"
  by auto arith

lemma double_inj_on:
  "inj_on (%i. 2*i::nat) A"
  by (simp add: inj_onI)

lemma Suc_double_inj_on:
  "inj_on (%i. Suc (2*i)) A"
  by (rule inj_onI) simp

lemma setsum_splice:
  "(\<Sum>i::nat = 0..<2*n. f i) = (\<Sum>i = 0..<n. f (2*i)) + (\<Sum>i = 0..<n. f (2*i+1))"
proof -
  have "(\<Sum>i::nat = 0..<2*n. f i) =
    setsum f (op * 2 ` {0..<n}) + setsum f ((%i. 2*i+1) ` {0..<n})"
    by (simp add: ivl_splice_Un ivl_splice_Int setsum_Un_disjoint)
  also have "... = (\<Sum>i = 0..<n. f (2*i)) + (\<Sum>i = 0..<n. f (2*i+1))"
    by (simp add: setsum_reindex [OF double_inj_on]
      setsum_reindex [OF Suc_double_inj_on])
  finally show ?thesis .
qed


section {* Complex Roots of Unity *}

text {* The function @{term cis} from the complex library returns the
  point on the unity circle corresponding to the argument angle.  It
  is the base for our definition of @{text root}.  The main property,
  De Moirve's formula is already there in the library. *}

definition root :: "nat => complex" where
  "root n == cis (2*pi/(real (n::nat)))"

lemma sin_periodic_pi_diff [simp]: "sin (x - pi) = - sin x"
  by (simp add: sin_diff)

lemma sin_cos_between_zero_two_pi:
  assumes 0: "0 < x" and pi: "x < 2 * pi"
  shows "sin x \<noteq> 0 \<or> cos x \<noteq> 1"
proof -
  { assume "0 < x" and "x < pi"
    then have "sin x \<noteq> 0" by (auto dest: sin_gt_zero_pi) }
  moreover
  { assume "x = pi"
    then have "cos x \<noteq> 1" by simp }
  moreover
  { assume pi1: "pi < x" and pi2: "x < 2 * pi"
    then have "0 < x - pi" and "x - pi < pi" by arith+
    then have "sin (x - pi) \<noteq> 0" by (auto dest: sin_gt_zero_pi)
    with pi1 pi2 have "sin x \<noteq> 0" by simp }
  ultimately show ?thesis using 0 pi by arith
qed


subsection {* Basic Lemmas *}

lemma root_nonzero:
  "root n ~= 0"
  apply (unfold root_def)
  apply (unfold cis_def)
  apply auto
  apply (drule sin_zero_abs_cos_one)
  apply arith
  done

lemma root_unity:
  "root n ^ n = 1"
  apply (unfold root_def)
  apply (simp add: DeMoivre)
  apply (simp add: cis_def)
  done

lemma root_cancel:
  "0 < d ==> root (d * n) ^ (d * k) = root n ^ k"
  apply (unfold root_def)
  apply (simp add: DeMoivre)
  done

lemma root_summation:
  assumes k: "0 < k" "k < n"
  shows "(\<Sum>i=0..<n. (root n ^ k) ^ i) = 0"
proof -
  from k have real0: "0 < real k * (2 * pi) / real n"
    by (simp add: zero_less_divide_iff
      mult_strict_right_mono [where a = 0, simplified])
  from k mult_strict_right_mono [where a = "real k" and
    b = "real n" and c = "2 * pi / real n", simplified]
  have realk: "real k * (2 * pi) / real n < 2 * pi"
    by (simp add: zero_less_divide_iff)
  txt {* Main part of the proof *}
  have "(\<Sum>i=0..<n. (root n ^ k) ^ i) =
    ((root n ^ k) ^ n - 1) / (root n ^ k - 1)"
    apply (rule geometric_sum)
    apply (unfold root_def)
    apply (simp add: DeMoivre)
    using real0 realk sin_cos_between_zero_two_pi 
    apply (auto simp add: cis_def complex_one_def)
    done
  also have "... = ((root n ^ n) ^ k - 1) / (root n ^ k - 1)"
    by (simp add: power_mult [THEN sym] mult_ac)
  also have "... = 0"
    by (simp add: root_unity)
  finally show ?thesis .
qed

lemma root_summation_inv:
  assumes k: "0 < k" "k < n"
  shows "(\<Sum>i=0..<n. ((1 / root n) ^ k) ^ i) = 0"
proof -
  from k have real0: "0 < real k * (2 * pi) / real n"
    by (simp add: zero_less_divide_iff
      mult_strict_right_mono [where a = 0, simplified])
  from k mult_strict_right_mono [where a = "real k" and
    b = "real n" and c = "2 * pi / real n", simplified]
  have realk: "real k * (2 * pi) / real n < 2 * pi"
    by (simp add: zero_less_divide_iff)
  txt {* Main part of the proof *}
  have "(\<Sum>i=0..<n. ((1 / root n) ^ k) ^ i) =
    (((1 / root n) ^ k) ^ n - 1) / ((1 / root n) ^ k - 1)"
    apply (rule geometric_sum)
    apply (simp add: nonzero_inverse_eq_divide [THEN sym] root_nonzero)
    apply (unfold root_def)
    apply (simp add: DeMoivre)
    using real0 realk sin_cos_between_zero_two_pi
    apply (auto simp add: cis_def complex_one_def)
    done
  also have "... = (((1 / root n) ^ n) ^ k - 1) / ((1 / root n) ^ k - 1)"
    by (simp add: power_mult [THEN sym] mult_ac)
  also have "... = 0"
    by (simp add: power_divide root_unity)
  finally show ?thesis .
qed

lemma root0 [simp]:
  "root 0 = 1"
  by (simp add: root_def cis_def)

lemma root1 [simp]:
  "root 1 = 1"
  by (simp add: root_def cis_def)

lemma root2 [simp]:
  "root 2 = Complex -1 0"
  by (simp add: root_def cis_def)

lemma root4 [simp]:
  "root 4 = ii"
  by (simp add: root_def cis_def)


subsection {* Derived Lemmas *}

lemma root_cancel1:
  "root (2 * m) ^ (i * (2 * j)) = root m ^ (i * j)"
proof -
  have "root (2 * m) ^ (i * (2 * j)) = root (2 * m) ^ (2 * (i * j))"
    by (simp add: mult_ac)
  also have "... = root m ^ (i * j)"
    by (simp add: root_cancel)
  finally show ?thesis .
qed

lemma root_cancel2:
  "0 < n ==> root (2 * n) ^ n = - 1"
  txt {* Note the space between @{text "-"} and @{text "1"}. *}
  using root_cancel [where n = 2 and k = 1]
  apply (simp only: mult_ac)
  apply (simp add: complex_one_def)
  done


section {* Discrete Fourier Transformation *}

text {*
  We define operations  @{text DFT} and @{text IDFT} for the discrete
  Fourier Transform and its inverse.  Vectors are simply functions of
  type @{text "nat => complex"}. *}

text {*
  @{text "DFT n a"} is the transform of vector @{text a}
  of length @{text n}, @{text IDFT} its inverse. *}

definition DFT :: "nat => (nat => complex) => (nat => complex)" where
  "DFT n a == (%i. \<Sum>j=0..<n. (root n) ^ (i * j) * (a j))"

definition IDFT :: "nat => (nat => complex) => (nat => complex)" where
  "IDFT n a == (%i. (\<Sum>k=0..<n. (a k) / (root n) ^ (i * k)))"

schematic_lemma "map (DFT 4 a) [0, 1, 2, 3] = ?x"
  by(simp add: DFT_def Sum4)

text {* Lemmas for the correctness proof. *}

lemma DFT_lower:
  "DFT (2 * m) a i =
  DFT m (%i. a (2 * i)) i +
  (root (2 * m)) ^ i * DFT m (%i. a (2 * i + 1)) i"
proof (unfold DFT_def)
  have "(\<Sum>j = 0..<2 * m. root (2 * m) ^ (i * j) * a j) =
    (\<Sum>j = 0..<m. root (2 * m) ^ (i * (2 * j)) * a (2 * j)) +
    (\<Sum>j = 0..<m. root (2 * m) ^ (i * (2 * j + 1)) * a (2 * j + 1))"
    (is "?s = _")
    by (simp add: setsum_splice)
  also have "... = (\<Sum>j = 0..<m. root m ^ (i * j) * a (2 * j)) +
    root (2 * m) ^ i *
    (\<Sum>j = 0..<m. root m ^ (i * j) * a (2 * j + 1))"
    (is "_ = ?t")
    txt {* First pair of sums *}
    apply (simp add: root_cancel1)
    txt {* Second pair of sums *}
    apply (simp add: setsum_right_distrib)
    apply (simp add: power_add)
    apply (simp add: root_cancel1)
    apply (simp add: mult_ac)
    done
  finally show "?s = ?t" .
qed

lemma DFT_upper:
  assumes mbound: "0 < m" and ibound: "m <= i"
  shows "DFT (2 * m) a i =
    DFT m (%i. a (2 * i)) (i - m) -
    root (2 * m) ^ (i - m) * DFT m (%i. a (2 * i + 1)) (i - m)"
proof (unfold DFT_def)
  have "(\<Sum>j = 0..<2 * m. root (2 * m) ^ (i * j) * a j) =
    (\<Sum>j = 0..<m. root (2 * m) ^ (i * (2 * j)) * a (2 * j)) +
    (\<Sum>j = 0..<m. root (2 * m) ^ (i * (2 * j + 1)) * a (2 * j + 1))"
    (is "?s = _")
    by (simp add: setsum_splice)
  also have "... =
    (\<Sum>j = 0..<m. root m ^ ((i - m) * j) * a (2 * j)) -
    root (2 * m) ^ (i - m) *
    (\<Sum>j = 0..<m. root m ^ ((i - m) * j) * a (2 * j + 1))"
    (is "_ = ?t")
    txt {* First pair of sums *}
    apply (simp add: root_cancel1)
    apply (simp add: root_unity ibound root_nonzero power_diff power_mult)
    txt {* Second pair of sums *}
    apply (simp add: mbound root_cancel2)
    apply (simp add: setsum_right_distrib)
    apply (simp add: power_add)
    apply (simp add: root_cancel1)
    apply (simp add: power_mult)
    apply (simp add: mult_ac)
    done
  finally show "?s = ?t" .
qed

lemma IDFT_lower:
  "IDFT (2 * m) a i =
  IDFT m (%i. a (2 * i)) i +
  (1 / root (2 * m)) ^ i * IDFT m (%i. a (2 * i + 1)) i"
proof (unfold IDFT_def)
  have "(\<Sum>j = 0..<2 * m. a j / root (2 * m) ^ (i * j)) =
    (\<Sum>j = 0..<m. a (2 * j) / root (2 * m) ^ (i * (2 * j))) +
    (\<Sum>j = 0..<m. a (2 * j + 1) / root (2 * m) ^ (i * (2 * j + 1)))"
    (is "?s = _")
    by (simp add: setsum_splice)
  also have "... = (\<Sum>j = 0..<m. a (2 * j) / root m ^ (i * j)) +
    (1 / root (2 * m)) ^ i *
    (\<Sum>j = 0..<m. a (2 * j + 1) / root m ^ (i * j))"
    (is "_ = ?t")
    txt {* First pair of sums *}
    apply (simp add: root_cancel1)
    txt {* Second pair of sums *}
    apply (simp add: setsum_right_distrib)
    apply (simp add: power_add)
    apply (simp add: nonzero_power_divide root_nonzero)
    apply (simp add: root_cancel1)
    done
  finally show "?s = ?t" .
qed

lemma IDFT_upper:
  assumes mbound: "0 < m" and ibound: "m <= i"
  shows "IDFT (2 * m) a i =
    IDFT m (%i. a (2 * i)) (i - m) -
    (1 / root (2 * m)) ^ (i - m) *
    IDFT m (%i. a (2 * i + 1)) (i - m)"
proof (unfold IDFT_def)
  have "(\<Sum>j = 0..<2 * m. a j / root (2 * m) ^ (i * j)) =
    (\<Sum>j = 0..<m. a (2 * j) / root (2 * m) ^ (i * (2 * j))) +
    (\<Sum>j = 0..<m. a (2 * j + 1) / root (2 * m) ^ (i * (2 * j + 1)))"
    (is "?s = _")
    by (simp add: setsum_splice)
  also have "... =
    (\<Sum>j = 0..<m. a (2 * j) / root m ^ ((i - m) * j)) -
    (1 / root (2 * m)) ^ (i - m) *
    (\<Sum>j = 0..<m. a (2 * j + 1) / root m ^ ((i - m) * j))"
    (is "_ = ?t")
    txt {* First pair of sums *}
    apply (simp add: root_cancel1)
    apply (simp add: root_unity ibound root_nonzero power_diff power_mult)
    txt {* Second pair of sums *}
    apply (simp add: nonzero_power_divide root_nonzero)
    apply (simp add: mbound root_cancel2)
    apply (simp add: setsum_divide_distrib)
    apply (simp add: power_add)
    apply (simp add: root_cancel1)
    apply (simp add: power_mult)
    apply (simp add: mult_ac)
    done
  finally show "?s = ?t" .
qed

text {* @{text DFT} und @{text IDFT} are inverses. *}

declare divide_divide_eq_right [simp del]
  divide_divide_eq_left [simp del]

lemma power_diff_inverse:
  assumes nz: "(a::'a::field) ~= 0"
  shows "m <= n ==> (inverse a) ^ (n-m) = (a^m) / (a^n)"
  apply (induct n m rule: diff_induct)
    apply (simp add: nonzero_power_inverse
      nonzero_inverse_eq_divide [THEN sym] nz)
   apply simp
  apply (simp add: nz)
  done

lemma power_diff_rev_if:
  assumes nz: "(a::'a::field) ~= 0"
  shows "(a^m) / (a^n) = (if n <= m then a ^ (m-n) else (1/a) ^ (n-m))"
proof (cases "n <= m")
  case True with nz show ?thesis
    by (simp add: power_diff)
next
  case False with nz show ?thesis
    by (simp add: power_diff_inverse nonzero_inverse_eq_divide [THEN sym])
qed

lemma power_divides_special:
  "(a::'a::field) ~= 0 ==>
  a ^ (i * j) / a ^ (k * i) = (a ^ j / a ^ k) ^ i"
  by (simp add: nonzero_power_divide power_mult [THEN sym] mult_ac)

theorem DFT_inverse:
  assumes i_less: "i < n"
  shows  "IDFT n (DFT n a) i = of_nat n * a i"
  using [[linarith_split_limit = 0]]
  apply (unfold DFT_def IDFT_def)
  apply (simp add: setsum_divide_distrib)
  apply (subst setsum_commute)
  apply (simp only: times_divide_eq_left [THEN sym])
  apply (simp only: power_divides_special [OF root_nonzero])
  apply (simp add: power_diff_rev_if root_nonzero)
  apply (simp add: setsum_divide_distrib [THEN sym]
    setsum_left_distrib [THEN sym])
  proof -
    from i_less have i_diff: "!!k. i - k < n" by arith
    have diff_i: "!!k. k < n ==> k - i < n" by arith

    let ?sum = "%i j n. setsum (op ^ (if i <= j then root n ^ (j - i)
                  else (1 / root n) ^ (i - j))) {0..<n} * a j"
    let ?sum1 = "%i j n. setsum (op ^ (root n ^ (j - i))) {0..<n} * a j"
    let ?sum2 = "%i j n. setsum (op ^ ((1 / root n) ^ (i - j))) {0..<n} * a j"

    from i_less have "(\<Sum>j = 0..<n. ?sum i j n) =
      (\<Sum>j = 0..<i. ?sum2 i j n) + (\<Sum>j = i..<n. ?sum1 i j n)"
      (is "?s = _")
      by (simp add: root_summation_inv nat_dvd_not_less
        setsum_add_split_nat_ivl [where f = "%j. ?sum i j n"])
    also from i_less i_diff
    have "... = (\<Sum>j = i..<n. ?sum1 i j n)"
      by (simp add: root_summation_inv nat_dvd_not_less)
    also from i_less have "... =
      (\<Sum>j\<in>{i} \<union> {i<..<n}. ?sum1 i j n)"
      by (simp only: ivl_disj_un)
    also have "... =
      (?sum1 i i n + (\<Sum>j\<in>{i<..<n}. ?sum1 i j n))"
      by (simp add: setsum_Un_disjoint ivl_disj_int)
    also from i_less diff_i have "... = ?sum1 i i n"
      by (simp add: root_summation nat_dvd_not_less)
    also from i_less have "... = of_nat n * a i" (is "_ = ?t")
      by (simp add: of_nat_cplx)
    finally show "?s = ?t" .
  qed


section {* Discrete, Fast Fourier Transformation *}

text {* @{text "FFT k a"} is the transform of vector @{text a}
  of length @{text "2 ^ k"}, @{text IFFT} its inverse. *}

primrec FFT :: "nat => (nat => complex) => (nat => complex)" where
  "FFT 0 a = a"
| "FFT (Suc k) a =
     (let (x, y) = (FFT k (%i. a (2*i)), FFT k (%i. a (2*i+1)))
      in (%i. if i < 2^k
            then x i + (root (2 ^ (Suc k))) ^ i * y i
            else x (i- 2^k) - (root (2 ^ (Suc k))) ^ (i- 2^k) * y (i- 2^k)))"

primrec IFFT :: "nat => (nat => complex) => (nat => complex)" where
  "IFFT 0 a = a"
| "IFFT (Suc k) a =
     (let (x, y) = (IFFT k (%i. a (2*i)), IFFT k (%i. a (2*i+1)))
      in (%i. if i < 2^k
            then x i + (1 / root (2 ^ (Suc k))) ^ i * y i
            else x (i - 2^k) -
              (1 / root (2 ^ (Suc k))) ^ (i - 2^k) * y (i - 2^k)))"

text {* Finally, for vectors of length @{text "2 ^ k"},
  @{text DFT} and @{text FFT}, and @{text IDFT} and
  @{text IFFT} are equivalent. *}

theorem DFT_FFT:
  "!!a i. i < 2 ^ k ==> DFT (2 ^ k) a i = FFT k a i"
proof (induct k)
  case 0
  then show ?case by (simp add: DFT_def)
next
  case (Suc k)
  assume i: "i < 2 ^ Suc k"
  show ?case proof (cases "i < 2 ^ k")
    case True
    then show ?thesis apply simp apply (simp add: DFT_lower)
      apply (simp add: Suc) done
  next
    case False
    from i have "i - 2 ^ k < 2 ^ k" by simp
    with False i show ?thesis apply simp apply (simp add: DFT_upper)
      apply (simp add: Suc) done
  qed
qed

theorem IDFT_IFFT:
  "!!a i. i < 2 ^ k ==> IDFT (2 ^ k) a i = IFFT k a i"
proof (induct k)
  case 0
  then show ?case by (simp add: IDFT_def)
next
  case (Suc k)
  assume i: "i < 2 ^ Suc k"
  show ?case proof (cases "i < 2 ^ k")
    case True
    then show ?thesis apply simp apply (simp add: IDFT_lower)
      apply (simp add: Suc) done
  next
    case False
    from i have "i - 2 ^ k < 2 ^ k" by simp
    with False i show ?thesis apply simp apply (simp add: IDFT_upper)
      apply (simp add: Suc) done
  qed
qed

schematic_lemma "map (FFT (Suc (Suc 0)) a) [0, 1, 2, 3] = ?x"
  by simp

end
