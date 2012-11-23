(*  Title:      HOL/Matrix_LP/Matrix.thy
    Author:     Steven Obua
*)

theory Matrix
imports Main "~~/src/HOL/Library/Lattice_Algebras"
begin

type_synonym 'a infmatrix = "nat \<Rightarrow> nat \<Rightarrow> 'a"

definition nonzero_positions :: "(nat \<Rightarrow> nat \<Rightarrow> 'a::zero) \<Rightarrow> (nat \<times> nat) set" where
  "nonzero_positions A = {pos. A (fst pos) (snd pos) ~= 0}"

definition "matrix = {(f::(nat \<Rightarrow> nat \<Rightarrow> 'a::zero)). finite (nonzero_positions f)}"

typedef (open) 'a matrix = "matrix :: (nat \<Rightarrow> nat \<Rightarrow> 'a::zero) set"
  unfolding matrix_def
proof
  show "(\<lambda>j i. 0) \<in> {(f::(nat \<Rightarrow> nat \<Rightarrow> 'a::zero)). finite (nonzero_positions f)}"
    by (simp add: nonzero_positions_def)
qed

declare Rep_matrix_inverse[simp]

lemma finite_nonzero_positions : "finite (nonzero_positions (Rep_matrix A))"
  by (induct A) (simp add: Abs_matrix_inverse matrix_def)

definition nrows :: "('a::zero) matrix \<Rightarrow> nat" where
  "nrows A == if nonzero_positions(Rep_matrix A) = {} then 0 else Suc(Max ((image fst) (nonzero_positions (Rep_matrix A))))"

definition ncols :: "('a::zero) matrix \<Rightarrow> nat" where
  "ncols A == if nonzero_positions(Rep_matrix A) = {} then 0 else Suc(Max ((image snd) (nonzero_positions (Rep_matrix A))))"

lemma nrows:
  assumes hyp: "nrows A \<le> m"
  shows "(Rep_matrix A m n) = 0"
proof cases
  assume "nonzero_positions(Rep_matrix A) = {}"
  then show "(Rep_matrix A m n) = 0" by (simp add: nonzero_positions_def)
next
  assume a: "nonzero_positions(Rep_matrix A) \<noteq> {}"
  let ?S = "fst`(nonzero_positions(Rep_matrix A))"
  have c: "finite (?S)" by (simp add: finite_nonzero_positions)
  from hyp have d: "Max (?S) < m" by (simp add: a nrows_def)
  have "m \<notin> ?S"
    proof -
      have "m \<in> ?S \<Longrightarrow> m <= Max(?S)" by (simp add: Max_ge [OF c])
      moreover from d have "~(m <= Max ?S)" by (simp)
      ultimately show "m \<notin> ?S" by (auto)
    qed
  thus "Rep_matrix A m n = 0" by (simp add: nonzero_positions_def image_Collect)
qed

definition transpose_infmatrix :: "'a infmatrix \<Rightarrow> 'a infmatrix" where
  "transpose_infmatrix A j i == A i j"

definition transpose_matrix :: "('a::zero) matrix \<Rightarrow> 'a matrix" where
  "transpose_matrix == Abs_matrix o transpose_infmatrix o Rep_matrix"

declare transpose_infmatrix_def[simp]

lemma transpose_infmatrix_twice[simp]: "transpose_infmatrix (transpose_infmatrix A) = A"
by ((rule ext)+, simp)

lemma transpose_infmatrix: "transpose_infmatrix (% j i. P j i) = (% j i. P i j)"
  apply (rule ext)+
  by simp

lemma transpose_infmatrix_closed[simp]: "Rep_matrix (Abs_matrix (transpose_infmatrix (Rep_matrix x))) = transpose_infmatrix (Rep_matrix x)"
apply (rule Abs_matrix_inverse)
apply (simp add: matrix_def nonzero_positions_def image_def)
proof -
  let ?A = "{pos. Rep_matrix x (snd pos) (fst pos) \<noteq> 0}"
  let ?swap = "% pos. (snd pos, fst pos)"
  let ?B = "{pos. Rep_matrix x (fst pos) (snd pos) \<noteq> 0}"
  have swap_image: "?swap`?A = ?B"
    apply (simp add: image_def)
    apply (rule set_eqI)
    apply (simp)
    proof
      fix y
      assume hyp: "\<exists>a b. Rep_matrix x b a \<noteq> 0 \<and> y = (b, a)"
      thus "Rep_matrix x (fst y) (snd y) \<noteq> 0"
        proof -
          from hyp obtain a b where "(Rep_matrix x b a \<noteq> 0 & y = (b,a))" by blast
          then show "Rep_matrix x (fst y) (snd y) \<noteq> 0" by (simp)
        qed
    next
      fix y
      assume hyp: "Rep_matrix x (fst y) (snd y) \<noteq> 0"
      show "\<exists> a b. (Rep_matrix x b a \<noteq> 0 & y = (b,a))"
        by (rule exI[of _ "snd y"], rule exI[of _ "fst y"]) (simp add: hyp)
    qed
  then have "finite (?swap`?A)"
    proof -
      have "finite (nonzero_positions (Rep_matrix x))" by (simp add: finite_nonzero_positions)
      then have "finite ?B" by (simp add: nonzero_positions_def)
      with swap_image show "finite (?swap`?A)" by (simp)
    qed
  moreover
  have "inj_on ?swap ?A" by (simp add: inj_on_def)
  ultimately show "finite ?A"by (rule finite_imageD[of ?swap ?A])
qed

lemma infmatrixforward: "(x::'a infmatrix) = y \<Longrightarrow> \<forall> a b. x a b = y a b" by auto

lemma transpose_infmatrix_inject: "(transpose_infmatrix A = transpose_infmatrix B) = (A = B)"
apply (auto)
apply (rule ext)+
apply (simp add: transpose_infmatrix)
apply (drule infmatrixforward)
apply (simp)
done

lemma transpose_matrix_inject: "(transpose_matrix A = transpose_matrix B) = (A = B)"
apply (simp add: transpose_matrix_def)
apply (subst Rep_matrix_inject[THEN sym])+
apply (simp only: transpose_infmatrix_closed transpose_infmatrix_inject)
done

lemma transpose_matrix[simp]: "Rep_matrix(transpose_matrix A) j i = Rep_matrix A i j"
by (simp add: transpose_matrix_def)

lemma transpose_transpose_id[simp]: "transpose_matrix (transpose_matrix A) = A"
by (simp add: transpose_matrix_def)

lemma nrows_transpose[simp]: "nrows (transpose_matrix A) = ncols A"
by (simp add: nrows_def ncols_def nonzero_positions_def transpose_matrix_def image_def)

lemma ncols_transpose[simp]: "ncols (transpose_matrix A) = nrows A"
by (simp add: nrows_def ncols_def nonzero_positions_def transpose_matrix_def image_def)

lemma ncols: "ncols A <= n \<Longrightarrow> Rep_matrix A m n = 0"
proof -
  assume "ncols A <= n"
  then have "nrows (transpose_matrix A) <= n" by (simp)
  then have "Rep_matrix (transpose_matrix A) n m = 0" by (rule nrows)
  thus "Rep_matrix A m n = 0" by (simp add: transpose_matrix_def)
qed

lemma ncols_le: "(ncols A <= n) = (! j i. n <= i \<longrightarrow> (Rep_matrix A j i) = 0)" (is "_ = ?st")
apply (auto)
apply (simp add: ncols)
proof (simp add: ncols_def, auto)
  let ?P = "nonzero_positions (Rep_matrix A)"
  let ?p = "snd`?P"
  have a:"finite ?p" by (simp add: finite_nonzero_positions)
  let ?m = "Max ?p"
  assume "~(Suc (?m) <= n)"
  then have b:"n <= ?m" by (simp)
  fix a b
  assume "(a,b) \<in> ?P"
  then have "?p \<noteq> {}" by (auto)
  with a have "?m \<in>  ?p" by (simp)
  moreover have "!x. (x \<in> ?p \<longrightarrow> (? y. (Rep_matrix A y x) \<noteq> 0))" by (simp add: nonzero_positions_def image_def)
  ultimately have "? y. (Rep_matrix A y ?m) \<noteq> 0" by (simp)
  moreover assume ?st
  ultimately show "False" using b by (simp)
qed

lemma less_ncols: "(n < ncols A) = (? j i. n <= i & (Rep_matrix A j i) \<noteq> 0)"
proof -
  have a: "!! (a::nat) b. (a < b) = (~(b <= a))" by arith
  show ?thesis by (simp add: a ncols_le)
qed

lemma le_ncols: "(n <= ncols A) = (\<forall> m. (\<forall> j i. m <= i \<longrightarrow> (Rep_matrix A j i) = 0) \<longrightarrow> n <= m)"
apply (auto)
apply (subgoal_tac "ncols A <= m")
apply (simp)
apply (simp add: ncols_le)
apply (drule_tac x="ncols A" in spec)
by (simp add: ncols)

lemma nrows_le: "(nrows A <= n) = (! j i. n <= j \<longrightarrow> (Rep_matrix A j i) = 0)" (is ?s)
proof -
  have "(nrows A <= n) = (ncols (transpose_matrix A) <= n)" by (simp)
  also have "\<dots> = (! j i. n <= i \<longrightarrow> (Rep_matrix (transpose_matrix A) j i = 0))" by (rule ncols_le)
  also have "\<dots> = (! j i. n <= i \<longrightarrow> (Rep_matrix A i j) = 0)" by (simp)
  finally show "(nrows A <= n) = (! j i. n <= j \<longrightarrow> (Rep_matrix A j i) = 0)" by (auto)
qed

lemma less_nrows: "(m < nrows A) = (? j i. m <= j & (Rep_matrix A j i) \<noteq> 0)"
proof -
  have a: "!! (a::nat) b. (a < b) = (~(b <= a))" by arith
  show ?thesis by (simp add: a nrows_le)
qed

lemma le_nrows: "(n <= nrows A) = (\<forall> m. (\<forall> j i. m <= j \<longrightarrow> (Rep_matrix A j i) = 0) \<longrightarrow> n <= m)"
apply (auto)
apply (subgoal_tac "nrows A <= m")
apply (simp)
apply (simp add: nrows_le)
apply (drule_tac x="nrows A" in spec)
by (simp add: nrows)

lemma nrows_notzero: "Rep_matrix A m n \<noteq> 0 \<Longrightarrow> m < nrows A"
apply (case_tac "nrows A <= m")
apply (simp_all add: nrows)
done

lemma ncols_notzero: "Rep_matrix A m n \<noteq> 0 \<Longrightarrow> n < ncols A"
apply (case_tac "ncols A <= n")
apply (simp_all add: ncols)
done

lemma finite_natarray1: "finite {x. x < (n::nat)}"
apply (induct n)
apply (simp)
proof -
  fix n
  have "{x. x < Suc n} = insert n {x. x < n}"  by (rule set_eqI, simp, arith)
  moreover assume "finite {x. x < n}"
  ultimately show "finite {x. x < Suc n}" by (simp)
qed

lemma finite_natarray2: "finite {pos. (fst pos) < (m::nat) & (snd pos) < (n::nat)}"
  apply (induct m)
  apply (simp+)
  proof -
    fix m::nat
    let ?s0 = "{pos. fst pos < m & snd pos < n}"
    let ?s1 = "{pos. fst pos < (Suc m) & snd pos < n}"
    let ?sd = "{pos. fst pos = m & snd pos < n}"
    assume f0: "finite ?s0"
    have f1: "finite ?sd"
    proof -
      let ?f = "% x. (m, x)"
      have "{pos. fst pos = m & snd pos < n} = ?f ` {x. x < n}" by (rule set_eqI, simp add: image_def, auto)
      moreover have "finite {x. x < n}" by (simp add: finite_natarray1)
      ultimately show "finite {pos. fst pos = m & snd pos < n}" by (simp)
    qed
    have su: "?s0 \<union> ?sd = ?s1" by (rule set_eqI, simp, arith)
    from f0 f1 have "finite (?s0 \<union> ?sd)" by (rule finite_UnI)
    with su show "finite ?s1" by (simp)
qed

lemma RepAbs_matrix:
  assumes aem: "? m. ! j i. m <= j \<longrightarrow> x j i = 0" (is ?em) and aen:"? n. ! j i. (n <= i \<longrightarrow> x j i = 0)" (is ?en)
  shows "(Rep_matrix (Abs_matrix x)) = x"
apply (rule Abs_matrix_inverse)
apply (simp add: matrix_def nonzero_positions_def)
proof -
  from aem obtain m where a: "! j i. m <= j \<longrightarrow> x j i = 0" by (blast)
  from aen obtain n where b: "! j i. n <= i \<longrightarrow> x j i = 0" by (blast)
  let ?u = "{pos. x (fst pos) (snd pos) \<noteq> 0}"
  let ?v = "{pos. fst pos < m & snd pos < n}"
  have c: "!! (m::nat) a. ~(m <= a) \<Longrightarrow> a < m" by (arith)
  from a b have "(?u \<inter> (-?v)) = {}"
    apply (simp)
    apply (rule set_eqI)
    apply (simp)
    apply auto
    by (rule c, auto)+
  then have d: "?u \<subseteq> ?v" by blast
  moreover have "finite ?v" by (simp add: finite_natarray2)
  ultimately show "finite ?u" by (rule finite_subset)
qed

definition apply_infmatrix :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a infmatrix \<Rightarrow> 'b infmatrix" where
  "apply_infmatrix f == % A. (% j i. f (A j i))"

definition apply_matrix :: "('a \<Rightarrow> 'b) \<Rightarrow> ('a::zero) matrix \<Rightarrow> ('b::zero) matrix" where
  "apply_matrix f == % A. Abs_matrix (apply_infmatrix f (Rep_matrix A))"

definition combine_infmatrix :: "('a \<Rightarrow> 'b \<Rightarrow> 'c) \<Rightarrow> 'a infmatrix \<Rightarrow> 'b infmatrix \<Rightarrow> 'c infmatrix" where
  "combine_infmatrix f == % A B. (% j i. f (A j i) (B j i))"

definition combine_matrix :: "('a \<Rightarrow> 'b \<Rightarrow> 'c) \<Rightarrow> ('a::zero) matrix \<Rightarrow> ('b::zero) matrix \<Rightarrow> ('c::zero) matrix" where
  "combine_matrix f == % A B. Abs_matrix (combine_infmatrix f (Rep_matrix A) (Rep_matrix B))"

lemma expand_apply_infmatrix[simp]: "apply_infmatrix f A j i = f (A j i)"
by (simp add: apply_infmatrix_def)

lemma expand_combine_infmatrix[simp]: "combine_infmatrix f A B j i = f (A j i) (B j i)"
by (simp add: combine_infmatrix_def)

definition commutative :: "('a \<Rightarrow> 'a \<Rightarrow> 'b) \<Rightarrow> bool" where
"commutative f == ! x y. f x y = f y x"

definition associative :: "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> bool" where
"associative f == ! x y z. f (f x y) z = f x (f y z)"

text{*
To reason about associativity and commutativity of operations on matrices,
let's take a step back and look at the general situtation: Assume that we have
sets $A$ and $B$ with $B \subset A$ and an abstraction $u: A \rightarrow B$. This abstraction has to fulfill $u(b) = b$ for all $b \in B$, but is arbitrary otherwise.
Each function $f: A \times A \rightarrow A$ now induces a function $f': B \times B \rightarrow B$ by $f' = u \circ f$.
It is obvious that commutativity of $f$ implies commutativity of $f'$: $f' x y = u (f x y) = u (f y x) = f' y x.$
*}

lemma combine_infmatrix_commute:
  "commutative f \<Longrightarrow> commutative (combine_infmatrix f)"
by (simp add: commutative_def combine_infmatrix_def)

lemma combine_matrix_commute:
"commutative f \<Longrightarrow> commutative (combine_matrix f)"
by (simp add: combine_matrix_def commutative_def combine_infmatrix_def)

text{*
On the contrary, given an associative function $f$ we cannot expect $f'$ to be associative. A counterexample is given by $A=\ganz$, $B=\{-1, 0, 1\}$,
as $f$ we take addition on $\ganz$, which is clearly associative. The abstraction is given by  $u(a) = 0$ for $a \notin B$. Then we have
\[ f' (f' 1 1) -1 = u(f (u (f 1 1)) -1) = u(f (u 2) -1) = u (f 0 -1) = -1, \]
but on the other hand we have
\[ f' 1 (f' 1 -1) = u (f 1 (u (f 1 -1))) = u (f 1 0) = 1.\]
A way out of this problem is to assume that $f(A\times A)\subset A$ holds, and this is what we are going to do:
*}

lemma nonzero_positions_combine_infmatrix[simp]: "f 0 0 = 0 \<Longrightarrow> nonzero_positions (combine_infmatrix f A B) \<subseteq> (nonzero_positions A) \<union> (nonzero_positions B)"
by (rule subsetI, simp add: nonzero_positions_def combine_infmatrix_def, auto)

lemma finite_nonzero_positions_Rep[simp]: "finite (nonzero_positions (Rep_matrix A))"
by (insert Rep_matrix [of A], simp add: matrix_def)

lemma combine_infmatrix_closed [simp]:
  "f 0 0 = 0 \<Longrightarrow> Rep_matrix (Abs_matrix (combine_infmatrix f (Rep_matrix A) (Rep_matrix B))) = combine_infmatrix f (Rep_matrix A) (Rep_matrix B)"
apply (rule Abs_matrix_inverse)
apply (simp add: matrix_def)
apply (rule finite_subset[of _ "(nonzero_positions (Rep_matrix A)) \<union> (nonzero_positions (Rep_matrix B))"])
by (simp_all)

text {* We need the next two lemmas only later, but it is analog to the above one, so we prove them now: *}
lemma nonzero_positions_apply_infmatrix[simp]: "f 0 = 0 \<Longrightarrow> nonzero_positions (apply_infmatrix f A) \<subseteq> nonzero_positions A"
by (rule subsetI, simp add: nonzero_positions_def apply_infmatrix_def, auto)

lemma apply_infmatrix_closed [simp]:
  "f 0 = 0 \<Longrightarrow> Rep_matrix (Abs_matrix (apply_infmatrix f (Rep_matrix A))) = apply_infmatrix f (Rep_matrix A)"
apply (rule Abs_matrix_inverse)
apply (simp add: matrix_def)
apply (rule finite_subset[of _ "nonzero_positions (Rep_matrix A)"])
by (simp_all)

lemma combine_infmatrix_assoc[simp]: "f 0 0 = 0 \<Longrightarrow> associative f \<Longrightarrow> associative (combine_infmatrix f)"
by (simp add: associative_def combine_infmatrix_def)

lemma comb: "f = g \<Longrightarrow> x = y \<Longrightarrow> f x = g y"
by (auto)

lemma combine_matrix_assoc: "f 0 0 = 0 \<Longrightarrow> associative f \<Longrightarrow> associative (combine_matrix f)"
apply (simp(no_asm) add: associative_def combine_matrix_def, auto)
apply (rule comb [of Abs_matrix Abs_matrix])
by (auto, insert combine_infmatrix_assoc[of f], simp add: associative_def)

lemma Rep_apply_matrix[simp]: "f 0 = 0 \<Longrightarrow> Rep_matrix (apply_matrix f A) j i = f (Rep_matrix A j i)"
by (simp add: apply_matrix_def)

lemma Rep_combine_matrix[simp]: "f 0 0 = 0 \<Longrightarrow> Rep_matrix (combine_matrix f A B) j i = f (Rep_matrix A j i) (Rep_matrix B j i)"
  by(simp add: combine_matrix_def)

lemma combine_nrows_max: "f 0 0 = 0  \<Longrightarrow> nrows (combine_matrix f A B) <= max (nrows A) (nrows B)"
by (simp add: nrows_le)

lemma combine_ncols_max: "f 0 0 = 0 \<Longrightarrow> ncols (combine_matrix f A B) <= max (ncols A) (ncols B)"
by (simp add: ncols_le)

lemma combine_nrows: "f 0 0 = 0 \<Longrightarrow> nrows A <= q \<Longrightarrow> nrows B <= q \<Longrightarrow> nrows(combine_matrix f A B) <= q"
  by (simp add: nrows_le)

lemma combine_ncols: "f 0 0 = 0 \<Longrightarrow> ncols A <= q \<Longrightarrow> ncols B <= q \<Longrightarrow> ncols(combine_matrix f A B) <= q"
  by (simp add: ncols_le)

definition zero_r_neutral :: "('a \<Rightarrow> 'b::zero \<Rightarrow> 'a) \<Rightarrow> bool" where
  "zero_r_neutral f == ! a. f a 0 = a"

definition zero_l_neutral :: "('a::zero \<Rightarrow> 'b \<Rightarrow> 'b) \<Rightarrow> bool" where
  "zero_l_neutral f == ! a. f 0 a = a"

definition zero_closed :: "(('a::zero) \<Rightarrow> ('b::zero) \<Rightarrow> ('c::zero)) \<Rightarrow> bool" where
  "zero_closed f == (!x. f x 0 = 0) & (!y. f 0 y = 0)"

primrec foldseq :: "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> (nat \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow> 'a"
where
  "foldseq f s 0 = s 0"
| "foldseq f s (Suc n) = f (s 0) (foldseq f (% k. s(Suc k)) n)"

primrec foldseq_transposed ::  "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> (nat \<Rightarrow> 'a) \<Rightarrow> nat \<Rightarrow> 'a"
where
  "foldseq_transposed f s 0 = s 0"
| "foldseq_transposed f s (Suc n) = f (foldseq_transposed f s n) (s (Suc n))"

lemma foldseq_assoc : "associative f \<Longrightarrow> foldseq f = foldseq_transposed f"
proof -
  assume a:"associative f"
  then have sublemma: "!! n. ! N s. N <= n \<longrightarrow> foldseq f s N = foldseq_transposed f s N"
  proof -
    fix n
    show "!N s. N <= n \<longrightarrow> foldseq f s N = foldseq_transposed f s N"
    proof (induct n)
      show "!N s. N <= 0 \<longrightarrow> foldseq f s N = foldseq_transposed f s N" by simp
    next
      fix n
      assume b:"! N s. N <= n \<longrightarrow> foldseq f s N = foldseq_transposed f s N"
      have c:"!!N s. N <= n \<Longrightarrow> foldseq f s N = foldseq_transposed f s N" by (simp add: b)
      show "! N t. N <= Suc n \<longrightarrow> foldseq f t N = foldseq_transposed f t N"
      proof (auto)
        fix N t
        assume Nsuc: "N <= Suc n"
        show "foldseq f t N = foldseq_transposed f t N"
        proof cases
          assume "N <= n"
          then show "foldseq f t N = foldseq_transposed f t N" by (simp add: b)
        next
          assume "~(N <= n)"
          with Nsuc have Nsuceq: "N = Suc n" by simp
          have neqz: "n \<noteq> 0 \<Longrightarrow> ? m. n = Suc m & Suc m <= n" by arith
          have assocf: "!! x y z. f x (f y z) = f (f x y) z" by (insert a, simp add: associative_def)
          show "foldseq f t N = foldseq_transposed f t N"
            apply (simp add: Nsuceq)
            apply (subst c)
            apply (simp)
            apply (case_tac "n = 0")
            apply (simp)
            apply (drule neqz)
            apply (erule exE)
            apply (simp)
            apply (subst assocf)
            proof -
              fix m
              assume "n = Suc m & Suc m <= n"
              then have mless: "Suc m <= n" by arith
              then have step1: "foldseq_transposed f (% k. t (Suc k)) m = foldseq f (% k. t (Suc k)) m" (is "?T1 = ?T2")
                apply (subst c)
                by simp+
              have step2: "f (t 0) ?T2 = foldseq f t (Suc m)" (is "_ = ?T3") by simp
              have step3: "?T3 = foldseq_transposed f t (Suc m)" (is "_ = ?T4")
                apply (subst c)
                by (simp add: mless)+
              have step4: "?T4 = f (foldseq_transposed f t m) (t (Suc m))" (is "_=?T5") by simp
              from step1 step2 step3 step4 show sowhat: "f (f (t 0) ?T1) (t (Suc (Suc m))) = f ?T5 (t (Suc (Suc m)))" by simp
            qed
          qed
        qed
      qed
    qed
    show "foldseq f = foldseq_transposed f" by ((rule ext)+, insert sublemma, auto)
  qed

lemma foldseq_distr: "\<lbrakk>associative f; commutative f\<rbrakk> \<Longrightarrow> foldseq f (% k. f (u k) (v k)) n = f (foldseq f u n) (foldseq f v n)"
proof -
  assume assoc: "associative f"
  assume comm: "commutative f"
  from assoc have a:"!! x y z. f (f x y) z = f x (f y z)" by (simp add: associative_def)
  from comm have b: "!! x y. f x y = f y x" by (simp add: commutative_def)
  from assoc comm have c: "!! x y z. f x (f y z) = f y (f x z)" by (simp add: commutative_def associative_def)
  have "!! n. (! u v. foldseq f (%k. f (u k) (v k)) n = f (foldseq f u n) (foldseq f v n))"
    apply (induct_tac n)
    apply (simp+, auto)
    by (simp add: a b c)
  then show "foldseq f (% k. f (u k) (v k)) n = f (foldseq f u n) (foldseq f v n)" by simp
qed

theorem "\<lbrakk>associative f; associative g; \<forall>a b c d. g (f a b) (f c d) = f (g a c) (g b d); ? x y. (f x) \<noteq> (f y); ? x y. (g x) \<noteq> (g y); f x x = x; g x x = x\<rbrakk> \<Longrightarrow> f=g | (! y. f y x = y) | (! y. g y x = y)"
oops
(* Model found

Trying to find a model that refutes: \<lbrakk>associative f; associative g;
 \<forall>a b c d. g (f a b) (f c d) = f (g a c) (g b d); \<exists>x y. f x \<noteq> f y;
 \<exists>x y. g x \<noteq> g y; f x x = x; g x x = x\<rbrakk>
\<Longrightarrow> f = g \<or> (\<forall>y. f y x = y) \<or> (\<forall>y. g y x = y)
Searching for a model of size 1, translating term... invoking SAT solver... no model found.
Searching for a model of size 2, translating term... invoking SAT solver... no model found.
Searching for a model of size 3, translating term... invoking SAT solver...
Model found:
Size of types: 'a: 3
x: a1
g: (a0\<mapsto>(a0\<mapsto>a1, a1\<mapsto>a0, a2\<mapsto>a1), a1\<mapsto>(a0\<mapsto>a0, a1\<mapsto>a1, a2\<mapsto>a0), a2\<mapsto>(a0\<mapsto>a1, a1\<mapsto>a0, a2\<mapsto>a1))
f: (a0\<mapsto>(a0\<mapsto>a0, a1\<mapsto>a0, a2\<mapsto>a0), a1\<mapsto>(a0\<mapsto>a1, a1\<mapsto>a1, a2\<mapsto>a1), a2\<mapsto>(a0\<mapsto>a0, a1\<mapsto>a0, a2\<mapsto>a0))
*)

lemma foldseq_zero:
assumes fz: "f 0 0 = 0" and sz: "! i. i <= n \<longrightarrow> s i = 0"
shows "foldseq f s n = 0"
proof -
  have "!! n. ! s. (! i. i <= n \<longrightarrow> s i = 0) \<longrightarrow> foldseq f s n = 0"
    apply (induct_tac n)
    apply (simp)
    by (simp add: fz)
  then show "foldseq f s n = 0" by (simp add: sz)
qed

lemma foldseq_significant_positions:
  assumes p: "! i. i <= N \<longrightarrow> S i = T i"
  shows "foldseq f S N = foldseq f T N"
proof -
  have "!! m . ! s t. (! i. i<=m \<longrightarrow> s i = t i) \<longrightarrow> foldseq f s m = foldseq f t m"
    apply (induct_tac m)
    apply (simp)
    apply (simp)
    apply (auto)
    proof -
      fix n
      fix s::"nat\<Rightarrow>'a"
      fix t::"nat\<Rightarrow>'a"
      assume a: "\<forall>s t. (\<forall>i\<le>n. s i = t i) \<longrightarrow> foldseq f s n = foldseq f t n"
      assume b: "\<forall>i\<le>Suc n. s i = t i"
      have c:"!! a b. a = b \<Longrightarrow> f (t 0) a = f (t 0) b" by blast
      have d:"!! s t. (\<forall>i\<le>n. s i = t i) \<Longrightarrow> foldseq f s n = foldseq f t n" by (simp add: a)
      show "f (t 0) (foldseq f (\<lambda>k. s (Suc k)) n) = f (t 0) (foldseq f (\<lambda>k. t (Suc k)) n)" by (rule c, simp add: d b)
    qed
  with p show ?thesis by simp
qed

lemma foldseq_tail:
  assumes "M <= N"
  shows "foldseq f S N = foldseq f (% k. (if k < M then (S k) else (foldseq f (% k. S(k+M)) (N-M)))) M"
proof -
  have suc: "!! a b. \<lbrakk>a <= Suc b; a \<noteq> Suc b\<rbrakk> \<Longrightarrow> a <= b" by arith
  have a:"!! a b c . a = b \<Longrightarrow> f c a = f c b" by blast
  have "!! n. ! m s. m <= n \<longrightarrow> foldseq f s n = foldseq f (% k. (if k < m then (s k) else (foldseq f (% k. s(k+m)) (n-m)))) m"
    apply (induct_tac n)
    apply (simp)
    apply (simp)
    apply (auto)
    apply (case_tac "m = Suc na")
    apply (simp)
    apply (rule a)
    apply (rule foldseq_significant_positions)
    apply (auto)
    apply (drule suc, simp+)
    proof -
      fix na m s
      assume suba:"\<forall>m\<le>na. \<forall>s. foldseq f s na = foldseq f (\<lambda>k. if k < m then s k else foldseq f (\<lambda>k. s (k + m)) (na - m))m"
      assume subb:"m <= na"
      from suba have subc:"!! m s. m <= na \<Longrightarrow>foldseq f s na = foldseq f (\<lambda>k. if k < m then s k else foldseq f (\<lambda>k. s (k + m)) (na - m))m" by simp
      have subd: "foldseq f (\<lambda>k. if k < m then s (Suc k) else foldseq f (\<lambda>k. s (Suc (k + m))) (na - m)) m =
        foldseq f (% k. s(Suc k)) na"
        by (rule subc[of m "% k. s(Suc k)", THEN sym], simp add: subb)
      from subb have sube: "m \<noteq> 0 \<Longrightarrow> ? mm. m = Suc mm & mm <= na" by arith
      show "f (s 0) (foldseq f (\<lambda>k. if k < m then s (Suc k) else foldseq f (\<lambda>k. s (Suc (k + m))) (na - m)) m) =
        foldseq f (\<lambda>k. if k < m then s k else foldseq f (\<lambda>k. s (k + m)) (Suc na - m)) m"
        apply (simp add: subd)
        apply (cases "m = 0")
        apply (simp)
        apply (drule sube)
        apply (auto)
        apply (rule a)
        by (simp add: subc cong del: if_cong)
    qed
  then show ?thesis using assms by simp
qed

lemma foldseq_zerotail:
  assumes
  fz: "f 0 0 = 0"
  and sz: "! i.  n <= i \<longrightarrow> s i = 0"
  and nm: "n <= m"
  shows
  "foldseq f s n = foldseq f s m"
proof -
  show "foldseq f s n = foldseq f s m"
    apply (simp add: foldseq_tail[OF nm, of f s])
    apply (rule foldseq_significant_positions)
    apply (auto)
    apply (subst foldseq_zero)
    by (simp add: fz sz)+
qed

lemma foldseq_zerotail2:
  assumes "! x. f x 0 = x"
  and "! i. n < i \<longrightarrow> s i = 0"
  and nm: "n <= m"
  shows "foldseq f s n = foldseq f s m"
proof -
  have "f 0 0 = 0" by (simp add: assms)
  have b:"!! m n. n <= m \<Longrightarrow> m \<noteq> n \<Longrightarrow> ? k. m-n = Suc k" by arith
  have c: "0 <= m" by simp
  have d: "!! k. k \<noteq> 0 \<Longrightarrow> ? l. k = Suc l" by arith
  show ?thesis
    apply (subst foldseq_tail[OF nm])
    apply (rule foldseq_significant_positions)
    apply (auto)
    apply (case_tac "m=n")
    apply (simp+)
    apply (drule b[OF nm])
    apply (auto)
    apply (case_tac "k=0")
    apply (simp add: assms)
    apply (drule d)
    apply (auto)
    apply (simp add: assms foldseq_zero)
    done
qed

lemma foldseq_zerostart:
  "! x. f 0 (f 0 x) = f 0 x \<Longrightarrow>  ! i. i <= n \<longrightarrow> s i = 0 \<Longrightarrow> foldseq f s (Suc n) = f 0 (s (Suc n))"
proof -
  assume f00x: "! x. f 0 (f 0 x) = f 0 x"
  have "! s. (! i. i<=n \<longrightarrow> s i = 0) \<longrightarrow> foldseq f s (Suc n) = f 0 (s (Suc n))"
    apply (induct n)
    apply (simp)
    apply (rule allI, rule impI)
    proof -
      fix n
      fix s
      have a:"foldseq f s (Suc (Suc n)) = f (s 0) (foldseq f (% k. s(Suc k)) (Suc n))" by simp
      assume b: "! s. ((\<forall>i\<le>n. s i = 0) \<longrightarrow> foldseq f s (Suc n) = f 0 (s (Suc n)))"
      from b have c:"!! s. (\<forall>i\<le>n. s i = 0) \<Longrightarrow> foldseq f s (Suc n) = f 0 (s (Suc n))" by simp
      assume d: "! i. i <= Suc n \<longrightarrow> s i = 0"
      show "foldseq f s (Suc (Suc n)) = f 0 (s (Suc (Suc n)))"
        apply (subst a)
        apply (subst c)
        by (simp add: d f00x)+
    qed
  then show "! i. i <= n \<longrightarrow> s i = 0 \<Longrightarrow> foldseq f s (Suc n) = f 0 (s (Suc n))" by simp
qed

lemma foldseq_zerostart2:
  "! x. f 0 x = x \<Longrightarrow>  ! i. i < n \<longrightarrow> s i = 0 \<Longrightarrow> foldseq f s n = s n"
proof -
  assume a:"! i. i<n \<longrightarrow> s i = 0"
  assume x:"! x. f 0 x = x"
  from x have f00x: "! x. f 0 (f 0 x) = f 0 x" by blast
  have b: "!! i l. i < Suc l = (i <= l)" by arith
  have d: "!! k. k \<noteq> 0 \<Longrightarrow> ? l. k = Suc l" by arith
  show "foldseq f s n = s n"
  apply (case_tac "n=0")
  apply (simp)
  apply (insert a)
  apply (drule d)
  apply (auto)
  apply (simp add: b)
  apply (insert f00x)
  apply (drule foldseq_zerostart)
  by (simp add: x)+
qed

lemma foldseq_almostzero:
  assumes f0x:"! x. f 0 x = x" and fx0: "! x. f x 0 = x" and s0:"! i. i \<noteq> j \<longrightarrow> s i = 0"
  shows "foldseq f s n = (if (j <= n) then (s j) else 0)"
proof -
  from s0 have a: "! i. i < j \<longrightarrow> s i = 0" by simp
  from s0 have b: "! i. j < i \<longrightarrow> s i = 0" by simp
  show ?thesis
    apply auto
    apply (subst foldseq_zerotail2[of f, OF fx0, of j, OF b, of n, THEN sym])
    apply simp
    apply (subst foldseq_zerostart2)
    apply (simp add: f0x a)+
    apply (subst foldseq_zero)
    by (simp add: s0 f0x)+
qed

lemma foldseq_distr_unary:
  assumes "!! a b. g (f a b) = f (g a) (g b)"
  shows "g(foldseq f s n) = foldseq f (% x. g(s x)) n"
proof -
  have "! s. g(foldseq f s n) = foldseq f (% x. g(s x)) n"
    apply (induct_tac n)
    apply (simp)
    apply (simp)
    apply (auto)
    apply (drule_tac x="% k. s (Suc k)" in spec)
    by (simp add: assms)
  then show ?thesis by simp
qed

definition mult_matrix_n :: "nat \<Rightarrow> (('a::zero) \<Rightarrow> ('b::zero) \<Rightarrow> ('c::zero)) \<Rightarrow> ('c \<Rightarrow> 'c \<Rightarrow> 'c) \<Rightarrow> 'a matrix \<Rightarrow> 'b matrix \<Rightarrow> 'c matrix" where
  "mult_matrix_n n fmul fadd A B == Abs_matrix(% j i. foldseq fadd (% k. fmul (Rep_matrix A j k) (Rep_matrix B k i)) n)"

definition mult_matrix :: "(('a::zero) \<Rightarrow> ('b::zero) \<Rightarrow> ('c::zero)) \<Rightarrow> ('c \<Rightarrow> 'c \<Rightarrow> 'c) \<Rightarrow> 'a matrix \<Rightarrow> 'b matrix \<Rightarrow> 'c matrix" where
  "mult_matrix fmul fadd A B == mult_matrix_n (max (ncols A) (nrows B)) fmul fadd A B"

lemma mult_matrix_n:
  assumes "ncols A \<le>  n" (is ?An) "nrows B \<le> n" (is ?Bn) "fadd 0 0 = 0" "fmul 0 0 = 0"
  shows c:"mult_matrix fmul fadd A B = mult_matrix_n n fmul fadd A B"
proof -
  show ?thesis using assms
    apply (simp add: mult_matrix_def mult_matrix_n_def)
    apply (rule comb[of "Abs_matrix" "Abs_matrix"], simp, (rule ext)+)
    apply (rule foldseq_zerotail, simp_all add: nrows_le ncols_le assms)
    done
qed

lemma mult_matrix_nm:
  assumes "ncols A <= n" "nrows B <= n" "ncols A <= m" "nrows B <= m" "fadd 0 0 = 0" "fmul 0 0 = 0"
  shows "mult_matrix_n n fmul fadd A B = mult_matrix_n m fmul fadd A B"
proof -
  from assms have "mult_matrix_n n fmul fadd A B = mult_matrix fmul fadd A B"
    by (simp add: mult_matrix_n)
  also from assms have "\<dots> = mult_matrix_n m fmul fadd A B"
    by (simp add: mult_matrix_n[THEN sym])
  finally show "mult_matrix_n n fmul fadd A B = mult_matrix_n m fmul fadd A B" by simp
qed

definition r_distributive :: "('a \<Rightarrow> 'b \<Rightarrow> 'b) \<Rightarrow> ('b \<Rightarrow> 'b \<Rightarrow> 'b) \<Rightarrow> bool" where
  "r_distributive fmul fadd == ! a u v. fmul a (fadd u v) = fadd (fmul a u) (fmul a v)"

definition l_distributive :: "('a \<Rightarrow> 'b \<Rightarrow> 'a) \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> bool" where
  "l_distributive fmul fadd == ! a u v. fmul (fadd u v) a = fadd (fmul u a) (fmul v a)"

definition distributive :: "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> bool" where
  "distributive fmul fadd == l_distributive fmul fadd & r_distributive fmul fadd"

lemma max1: "!! a x y. (a::nat) <= x \<Longrightarrow> a <= max x y" by (arith)
lemma max2: "!! b x y. (b::nat) <= y \<Longrightarrow> b <= max x y" by (arith)

lemma r_distributive_matrix:
 assumes
  "r_distributive fmul fadd"
  "associative fadd"
  "commutative fadd"
  "fadd 0 0 = 0"
  "! a. fmul a 0 = 0"
  "! a. fmul 0 a = 0"
 shows "r_distributive (mult_matrix fmul fadd) (combine_matrix fadd)"
proof -
  from assms show ?thesis
    apply (simp add: r_distributive_def mult_matrix_def, auto)
    proof -
      fix a::"'a matrix"
      fix u::"'b matrix"
      fix v::"'b matrix"
      let ?mx = "max (ncols a) (max (nrows u) (nrows v))"
      from assms show "mult_matrix_n (max (ncols a) (nrows (combine_matrix fadd u v))) fmul fadd a (combine_matrix fadd u v) =
        combine_matrix fadd (mult_matrix_n (max (ncols a) (nrows u)) fmul fadd a u) (mult_matrix_n (max (ncols a) (nrows v)) fmul fadd a v)"
        apply (subst mult_matrix_nm[of _ _ _ ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (subst mult_matrix_nm[of _ _ v ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (subst mult_matrix_nm[of _ _ u ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (simp add: mult_matrix_n_def r_distributive_def foldseq_distr[of fadd])
        apply (simp add: combine_matrix_def combine_infmatrix_def)
        apply (rule comb[of "Abs_matrix" "Abs_matrix"], simp, (rule ext)+)
        apply (simplesubst RepAbs_matrix)
        apply (simp, auto)
        apply (rule exI[of _ "nrows a"], simp add: nrows_le foldseq_zero)
        apply (rule exI[of _ "ncols v"], simp add: ncols_le foldseq_zero)
        apply (subst RepAbs_matrix)
        apply (simp, auto)
        apply (rule exI[of _ "nrows a"], simp add: nrows_le foldseq_zero)
        apply (rule exI[of _ "ncols u"], simp add: ncols_le foldseq_zero)
        done
    qed
qed

lemma l_distributive_matrix:
 assumes
  "l_distributive fmul fadd"
  "associative fadd"
  "commutative fadd"
  "fadd 0 0 = 0"
  "! a. fmul a 0 = 0"
  "! a. fmul 0 a = 0"
 shows "l_distributive (mult_matrix fmul fadd) (combine_matrix fadd)"
proof -
  from assms show ?thesis
    apply (simp add: l_distributive_def mult_matrix_def, auto)
    proof -
      fix a::"'b matrix"
      fix u::"'a matrix"
      fix v::"'a matrix"
      let ?mx = "max (nrows a) (max (ncols u) (ncols v))"
      from assms show "mult_matrix_n (max (ncols (combine_matrix fadd u v)) (nrows a)) fmul fadd (combine_matrix fadd u v) a =
               combine_matrix fadd (mult_matrix_n (max (ncols u) (nrows a)) fmul fadd u a) (mult_matrix_n (max (ncols v) (nrows a)) fmul fadd v a)"
        apply (subst mult_matrix_nm[of v _ _ ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (subst mult_matrix_nm[of u _ _ ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (subst mult_matrix_nm[of _ _ _ ?mx fadd fmul])
        apply (simp add: max1 max2 combine_nrows combine_ncols)+
        apply (simp add: mult_matrix_n_def l_distributive_def foldseq_distr[of fadd])
        apply (simp add: combine_matrix_def combine_infmatrix_def)
        apply (rule comb[of "Abs_matrix" "Abs_matrix"], simp, (rule ext)+)
        apply (simplesubst RepAbs_matrix)
        apply (simp, auto)
        apply (rule exI[of _ "nrows v"], simp add: nrows_le foldseq_zero)
        apply (rule exI[of _ "ncols a"], simp add: ncols_le foldseq_zero)
        apply (subst RepAbs_matrix)
        apply (simp, auto)
        apply (rule exI[of _ "nrows u"], simp add: nrows_le foldseq_zero)
        apply (rule exI[of _ "ncols a"], simp add: ncols_le foldseq_zero)
        done
    qed
qed

instantiation matrix :: (zero) zero
begin

definition zero_matrix_def: "0 = Abs_matrix (\<lambda>j i. 0)"

instance ..

end

lemma Rep_zero_matrix_def[simp]: "Rep_matrix 0 j i = 0"
  apply (simp add: zero_matrix_def)
  apply (subst RepAbs_matrix)
  by (auto)

lemma zero_matrix_def_nrows[simp]: "nrows 0 = 0"
proof -
  have a:"!! (x::nat). x <= 0 \<Longrightarrow> x = 0" by (arith)
  show "nrows 0 = 0" by (rule a, subst nrows_le, simp)
qed

lemma zero_matrix_def_ncols[simp]: "ncols 0 = 0"
proof -
  have a:"!! (x::nat). x <= 0 \<Longrightarrow> x = 0" by (arith)
  show "ncols 0 = 0" by (rule a, subst ncols_le, simp)
qed

lemma combine_matrix_zero_l_neutral: "zero_l_neutral f \<Longrightarrow> zero_l_neutral (combine_matrix f)"
  by (simp add: zero_l_neutral_def combine_matrix_def combine_infmatrix_def)

lemma combine_matrix_zero_r_neutral: "zero_r_neutral f \<Longrightarrow> zero_r_neutral (combine_matrix f)"
  by (simp add: zero_r_neutral_def combine_matrix_def combine_infmatrix_def)

lemma mult_matrix_zero_closed: "\<lbrakk>fadd 0 0 = 0; zero_closed fmul\<rbrakk> \<Longrightarrow> zero_closed (mult_matrix fmul fadd)"
  apply (simp add: zero_closed_def mult_matrix_def mult_matrix_n_def)
  apply (auto)
  by (subst foldseq_zero, (simp add: zero_matrix_def)+)+

lemma mult_matrix_n_zero_right[simp]: "\<lbrakk>fadd 0 0 = 0; !a. fmul a 0 = 0\<rbrakk> \<Longrightarrow> mult_matrix_n n fmul fadd A 0 = 0"
  apply (simp add: mult_matrix_n_def)
  apply (subst foldseq_zero)
  by (simp_all add: zero_matrix_def)

lemma mult_matrix_n_zero_left[simp]: "\<lbrakk>fadd 0 0 = 0; !a. fmul 0 a = 0\<rbrakk> \<Longrightarrow> mult_matrix_n n fmul fadd 0 A = 0"
  apply (simp add: mult_matrix_n_def)
  apply (subst foldseq_zero)
  by (simp_all add: zero_matrix_def)

lemma mult_matrix_zero_left[simp]: "\<lbrakk>fadd 0 0 = 0; !a. fmul 0 a = 0\<rbrakk> \<Longrightarrow> mult_matrix fmul fadd 0 A = 0"
by (simp add: mult_matrix_def)

lemma mult_matrix_zero_right[simp]: "\<lbrakk>fadd 0 0 = 0; !a. fmul a 0 = 0\<rbrakk> \<Longrightarrow> mult_matrix fmul fadd A 0 = 0"
by (simp add: mult_matrix_def)

lemma apply_matrix_zero[simp]: "f 0 = 0 \<Longrightarrow> apply_matrix f 0 = 0"
  apply (simp add: apply_matrix_def apply_infmatrix_def)
  by (simp add: zero_matrix_def)

lemma combine_matrix_zero: "f 0 0 = 0 \<Longrightarrow> combine_matrix f 0 0 = 0"
  apply (simp add: combine_matrix_def combine_infmatrix_def)
  by (simp add: zero_matrix_def)

lemma transpose_matrix_zero[simp]: "transpose_matrix 0 = 0"
apply (simp add: transpose_matrix_def zero_matrix_def RepAbs_matrix)
apply (subst Rep_matrix_inject[symmetric], (rule ext)+)
apply (simp add: RepAbs_matrix)
done

lemma apply_zero_matrix_def[simp]: "apply_matrix (% x. 0) A = 0"
  apply (simp add: apply_matrix_def apply_infmatrix_def)
  by (simp add: zero_matrix_def)

definition singleton_matrix :: "nat \<Rightarrow> nat \<Rightarrow> ('a::zero) \<Rightarrow> 'a matrix" where
  "singleton_matrix j i a == Abs_matrix(% m n. if j = m & i = n then a else 0)"

definition move_matrix :: "('a::zero) matrix \<Rightarrow> int \<Rightarrow> int \<Rightarrow> 'a matrix" where
  "move_matrix A y x == Abs_matrix(% j i. if (((int j)-y) < 0) | (((int i)-x) < 0) then 0 else Rep_matrix A (nat ((int j)-y)) (nat ((int i)-x)))"

definition take_rows :: "('a::zero) matrix \<Rightarrow> nat \<Rightarrow> 'a matrix" where
  "take_rows A r == Abs_matrix(% j i. if (j < r) then (Rep_matrix A j i) else 0)"

definition take_columns :: "('a::zero) matrix \<Rightarrow> nat \<Rightarrow> 'a matrix" where
  "take_columns A c == Abs_matrix(% j i. if (i < c) then (Rep_matrix A j i) else 0)"

definition column_of_matrix :: "('a::zero) matrix \<Rightarrow> nat \<Rightarrow> 'a matrix" where
  "column_of_matrix A n == take_columns (move_matrix A 0 (- int n)) 1"

definition row_of_matrix :: "('a::zero) matrix \<Rightarrow> nat \<Rightarrow> 'a matrix" where
  "row_of_matrix A m == take_rows (move_matrix A (- int m) 0) 1"

lemma Rep_singleton_matrix[simp]: "Rep_matrix (singleton_matrix j i e) m n = (if j = m & i = n then e else 0)"
apply (simp add: singleton_matrix_def)
apply (auto)
apply (subst RepAbs_matrix)
apply (rule exI[of _ "Suc m"], simp)
apply (rule exI[of _ "Suc n"], simp+)
by (subst RepAbs_matrix, rule exI[of _ "Suc j"], simp, rule exI[of _ "Suc i"], simp+)+

lemma apply_singleton_matrix[simp]: "f 0 = 0 \<Longrightarrow> apply_matrix f (singleton_matrix j i x) = (singleton_matrix j i (f x))"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (simp)
done

lemma singleton_matrix_zero[simp]: "singleton_matrix j i 0 = 0"
  by (simp add: singleton_matrix_def zero_matrix_def)

lemma nrows_singleton[simp]: "nrows(singleton_matrix j i e) = (if e = 0 then 0 else Suc j)"
proof-
have th: "\<not> (\<forall>m. m \<le> j)" "\<exists>n. \<not> n \<le> i" by arith+
from th show ?thesis 
apply (auto)
apply (rule le_antisym)
apply (subst nrows_le)
apply (simp add: singleton_matrix_def, auto)
apply (subst RepAbs_matrix)
apply auto
apply (simp add: Suc_le_eq)
apply (rule not_leE)
apply (subst nrows_le)
by simp
qed

lemma ncols_singleton[simp]: "ncols(singleton_matrix j i e) = (if e = 0 then 0 else Suc i)"
proof-
have th: "\<not> (\<forall>m. m \<le> j)" "\<exists>n. \<not> n \<le> i" by arith+
from th show ?thesis 
apply (auto)
apply (rule le_antisym)
apply (subst ncols_le)
apply (simp add: singleton_matrix_def, auto)
apply (subst RepAbs_matrix)
apply auto
apply (simp add: Suc_le_eq)
apply (rule not_leE)
apply (subst ncols_le)
by simp
qed

lemma combine_singleton: "f 0 0 = 0 \<Longrightarrow> combine_matrix f (singleton_matrix j i a) (singleton_matrix j i b) = singleton_matrix j i (f a b)"
apply (simp add: singleton_matrix_def combine_matrix_def combine_infmatrix_def)
apply (subst RepAbs_matrix)
apply (rule exI[of _ "Suc j"], simp)
apply (rule exI[of _ "Suc i"], simp)
apply (rule comb[of "Abs_matrix" "Abs_matrix"], simp, (rule ext)+)
apply (subst RepAbs_matrix)
apply (rule exI[of _ "Suc j"], simp)
apply (rule exI[of _ "Suc i"], simp)
by simp

lemma transpose_singleton[simp]: "transpose_matrix (singleton_matrix j i a) = singleton_matrix i j a"
apply (subst Rep_matrix_inject[symmetric], (rule ext)+)
apply (simp)
done

lemma Rep_move_matrix[simp]:
  "Rep_matrix (move_matrix A y x) j i =
  (if (((int j)-y) < 0) | (((int i)-x) < 0) then 0 else Rep_matrix A (nat((int j)-y)) (nat((int i)-x)))"
apply (simp add: move_matrix_def)
apply (auto)
by (subst RepAbs_matrix,
  rule exI[of _ "(nrows A)+(nat (abs y))"], auto, rule nrows, arith,
  rule exI[of _ "(ncols A)+(nat (abs x))"], auto, rule ncols, arith)+

lemma move_matrix_0_0[simp]: "move_matrix A 0 0 = A"
by (simp add: move_matrix_def)

lemma move_matrix_ortho: "move_matrix A j i = move_matrix (move_matrix A j 0) 0 i"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (simp)
done

lemma transpose_move_matrix[simp]:
  "transpose_matrix (move_matrix A x y) = move_matrix (transpose_matrix A) y x"
apply (subst Rep_matrix_inject[symmetric], (rule ext)+)
apply (simp)
done

lemma move_matrix_singleton[simp]: "move_matrix (singleton_matrix u v x) j i = 
  (if (j + int u < 0) | (i + int v < 0) then 0 else (singleton_matrix (nat (j + int u)) (nat (i + int v)) x))"
  apply (subst Rep_matrix_inject[symmetric])
  apply (rule ext)+
  apply (case_tac "j + int u < 0")
  apply (simp, arith)
  apply (case_tac "i + int v < 0")
  apply (simp, arith)
  apply simp
  apply arith
  done

lemma Rep_take_columns[simp]:
  "Rep_matrix (take_columns A c) j i =
  (if i < c then (Rep_matrix A j i) else 0)"
apply (simp add: take_columns_def)
apply (simplesubst RepAbs_matrix)
apply (rule exI[of _ "nrows A"], auto, simp add: nrows_le)
apply (rule exI[of _ "ncols A"], auto, simp add: ncols_le)
done

lemma Rep_take_rows[simp]:
  "Rep_matrix (take_rows A r) j i =
  (if j < r then (Rep_matrix A j i) else 0)"
apply (simp add: take_rows_def)
apply (simplesubst RepAbs_matrix)
apply (rule exI[of _ "nrows A"], auto, simp add: nrows_le)
apply (rule exI[of _ "ncols A"], auto, simp add: ncols_le)
done

lemma Rep_column_of_matrix[simp]:
  "Rep_matrix (column_of_matrix A c) j i = (if i = 0 then (Rep_matrix A j c) else 0)"
  by (simp add: column_of_matrix_def)

lemma Rep_row_of_matrix[simp]:
  "Rep_matrix (row_of_matrix A r) j i = (if j = 0 then (Rep_matrix A r i) else 0)"
  by (simp add: row_of_matrix_def)

lemma column_of_matrix: "ncols A <= n \<Longrightarrow> column_of_matrix A n = 0"
apply (subst Rep_matrix_inject[THEN sym])
apply (rule ext)+
by (simp add: ncols)

lemma row_of_matrix: "nrows A <= n \<Longrightarrow> row_of_matrix A n = 0"
apply (subst Rep_matrix_inject[THEN sym])
apply (rule ext)+
by (simp add: nrows)

lemma mult_matrix_singleton_right[simp]:
  assumes
  "! x. fmul x 0 = 0"
  "! x. fmul 0 x = 0"
  "! x. fadd 0 x = x"
  "! x. fadd x 0 = x"
  shows "(mult_matrix fmul fadd A (singleton_matrix j i e)) = apply_matrix (% x. fmul x e) (move_matrix (column_of_matrix A j) 0 (int i))"
  apply (simp add: mult_matrix_def)
  apply (subst mult_matrix_nm[of _ _ _ "max (ncols A) (Suc j)"])
  apply (auto)
  apply (simp add: assms)+
  apply (simp add: mult_matrix_n_def apply_matrix_def apply_infmatrix_def)
  apply (rule comb[of "Abs_matrix" "Abs_matrix"], auto, (rule ext)+)
  apply (subst foldseq_almostzero[of _ j])
  apply (simp add: assms)+
  apply (auto)
  done

lemma mult_matrix_ext:
  assumes
  eprem:
  "? e. (! a b. a \<noteq> b \<longrightarrow> fmul a e \<noteq> fmul b e)"
  and fprems:
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "! a. fadd a 0 = a"
  "! a. fadd 0 a = a"
  and contraprems:
  "mult_matrix fmul fadd A = mult_matrix fmul fadd B"
  shows
  "A = B"
proof(rule contrapos_np[of "False"], simp)
  assume a: "A \<noteq> B"
  have b: "!! f g. (! x y. f x y = g x y) \<Longrightarrow> f = g" by ((rule ext)+, auto)
  have "? j i. (Rep_matrix A j i) \<noteq> (Rep_matrix B j i)"
    apply (rule contrapos_np[of "False"], simp+)
    apply (insert b[of "Rep_matrix A" "Rep_matrix B"], simp)
    by (simp add: Rep_matrix_inject a)
  then obtain J I where c:"(Rep_matrix A J I) \<noteq> (Rep_matrix B J I)" by blast
  from eprem obtain e where eprops:"(! a b. a \<noteq> b \<longrightarrow> fmul a e \<noteq> fmul b e)" by blast
  let ?S = "singleton_matrix I 0 e"
  let ?comp = "mult_matrix fmul fadd"
  have d: "!!x f g. f = g \<Longrightarrow> f x = g x" by blast
  have e: "(% x. fmul x e) 0 = 0" by (simp add: assms)
  have "~(?comp A ?S = ?comp B ?S)"
    apply (rule notI)
    apply (simp add: fprems eprops)
    apply (simp add: Rep_matrix_inject[THEN sym])
    apply (drule d[of _ _ "J"], drule d[of _ _ "0"])
    by (simp add: e c eprops)
  with contraprems show "False" by simp
qed

definition foldmatrix :: "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> ('a infmatrix) \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a" where
  "foldmatrix f g A m n == foldseq_transposed g (% j. foldseq f (A j) n) m"

definition foldmatrix_transposed :: "('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> 'a) \<Rightarrow> ('a infmatrix) \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> 'a" where
  "foldmatrix_transposed f g A m n == foldseq g (% j. foldseq_transposed f (A j) n) m"

lemma foldmatrix_transpose:
  assumes
  "! a b c d. g(f a b) (f c d) = f (g a c) (g b d)"
  shows
  "foldmatrix f g A m n = foldmatrix_transposed g f (transpose_infmatrix A) n m"
proof -
  have forall:"!! P x. (! x. P x) \<Longrightarrow> P x" by auto
  have tworows:"! A. foldmatrix f g A 1 n = foldmatrix_transposed g f (transpose_infmatrix A) n 1"
    apply (induct n)
    apply (simp add: foldmatrix_def foldmatrix_transposed_def assms)+
    apply (auto)
    by (drule_tac x="(% j i. A j (Suc i))" in forall, simp)
  show "foldmatrix f g A m n = foldmatrix_transposed g f (transpose_infmatrix A) n m"
    apply (simp add: foldmatrix_def foldmatrix_transposed_def)
    apply (induct m, simp)
    apply (simp)
    apply (insert tworows)
    apply (drule_tac x="% j i. (if j = 0 then (foldseq_transposed g (\<lambda>u. A u i) m) else (A (Suc m) i))" in spec)
    by (simp add: foldmatrix_def foldmatrix_transposed_def)
qed

lemma foldseq_foldseq:
assumes
  "associative f"
  "associative g"
  "! a b c d. g(f a b) (f c d) = f (g a c) (g b d)"
shows
  "foldseq g (% j. foldseq f (A j) n) m = foldseq f (% j. foldseq g ((transpose_infmatrix A) j) m) n"
  apply (insert foldmatrix_transpose[of g f A m n])
  by (simp add: foldmatrix_def foldmatrix_transposed_def foldseq_assoc[THEN sym] assms)

lemma mult_n_nrows:
assumes
"! a. fmul 0 a = 0"
"! a. fmul a 0 = 0"
"fadd 0 0 = 0"
shows "nrows (mult_matrix_n n fmul fadd A B) \<le> nrows A"
apply (subst nrows_le)
apply (simp add: mult_matrix_n_def)
apply (subst RepAbs_matrix)
apply (rule_tac x="nrows A" in exI)
apply (simp add: nrows assms foldseq_zero)
apply (rule_tac x="ncols B" in exI)
apply (simp add: ncols assms foldseq_zero)
apply (simp add: nrows assms foldseq_zero)
done

lemma mult_n_ncols:
assumes
"! a. fmul 0 a = 0"
"! a. fmul a 0 = 0"
"fadd 0 0 = 0"
shows "ncols (mult_matrix_n n fmul fadd A B) \<le> ncols B"
apply (subst ncols_le)
apply (simp add: mult_matrix_n_def)
apply (subst RepAbs_matrix)
apply (rule_tac x="nrows A" in exI)
apply (simp add: nrows assms foldseq_zero)
apply (rule_tac x="ncols B" in exI)
apply (simp add: ncols assms foldseq_zero)
apply (simp add: ncols assms foldseq_zero)
done

lemma mult_nrows:
assumes
"! a. fmul 0 a = 0"
"! a. fmul a 0 = 0"
"fadd 0 0 = 0"
shows "nrows (mult_matrix fmul fadd A B) \<le> nrows A"
by (simp add: mult_matrix_def mult_n_nrows assms)

lemma mult_ncols:
assumes
"! a. fmul 0 a = 0"
"! a. fmul a 0 = 0"
"fadd 0 0 = 0"
shows "ncols (mult_matrix fmul fadd A B) \<le> ncols B"
by (simp add: mult_matrix_def mult_n_ncols assms)

lemma nrows_move_matrix_le: "nrows (move_matrix A j i) <= nat((int (nrows A)) + j)"
  apply (auto simp add: nrows_le)
  apply (rule nrows)
  apply (arith)
  done

lemma ncols_move_matrix_le: "ncols (move_matrix A j i) <= nat((int (ncols A)) + i)"
  apply (auto simp add: ncols_le)
  apply (rule ncols)
  apply (arith)
  done

lemma mult_matrix_assoc:
  assumes
  "! a. fmul1 0 a = 0"
  "! a. fmul1 a 0 = 0"
  "! a. fmul2 0 a = 0"
  "! a. fmul2 a 0 = 0"
  "fadd1 0 0 = 0"
  "fadd2 0 0 = 0"
  "! a b c d. fadd2 (fadd1 a b) (fadd1 c d) = fadd1 (fadd2 a c) (fadd2 b d)"
  "associative fadd1"
  "associative fadd2"
  "! a b c. fmul2 (fmul1 a b) c = fmul1 a (fmul2 b c)"
  "! a b c. fmul2 (fadd1 a b) c = fadd1 (fmul2 a c) (fmul2 b c)"
  "! a b c. fmul1 c (fadd2 a b) = fadd2 (fmul1 c a) (fmul1 c b)"
  shows "mult_matrix fmul2 fadd2 (mult_matrix fmul1 fadd1 A B) C = mult_matrix fmul1 fadd1 A (mult_matrix fmul2 fadd2 B C)"
proof -
  have comb_left:  "!! A B x y. A = B \<Longrightarrow> (Rep_matrix (Abs_matrix A)) x y = (Rep_matrix(Abs_matrix B)) x y" by blast
  have fmul2fadd1fold: "!! x s n. fmul2 (foldseq fadd1 s n)  x = foldseq fadd1 (% k. fmul2 (s k) x) n"
    by (rule_tac g1 = "% y. fmul2 y x" in ssubst [OF foldseq_distr_unary], insert assms, simp_all)
  have fmul1fadd2fold: "!! x s n. fmul1 x (foldseq fadd2 s n) = foldseq fadd2 (% k. fmul1 x (s k)) n"
    using assms by (rule_tac g1 = "% y. fmul1 x y" in ssubst [OF foldseq_distr_unary], simp_all)
  let ?N = "max (ncols A) (max (ncols B) (max (nrows B) (nrows C)))"
  show ?thesis
    apply (simp add: Rep_matrix_inject[THEN sym])
    apply (rule ext)+
    apply (simp add: mult_matrix_def)
    apply (simplesubst mult_matrix_nm[of _ "max (ncols (mult_matrix_n (max (ncols A) (nrows B)) fmul1 fadd1 A B)) (nrows C)" _ "max (ncols B) (nrows C)"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simplesubst mult_matrix_nm[of _ "max (ncols A) (nrows (mult_matrix_n (max (ncols B) (nrows C)) fmul2 fadd2 B C))" _ "max (ncols A) (nrows B)"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simplesubst mult_matrix_nm[of _ _ _ "?N"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simplesubst mult_matrix_nm[of _ _ _ "?N"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simplesubst mult_matrix_nm[of _ _ _ "?N"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simplesubst mult_matrix_nm[of _ _ _ "?N"])
    apply (simp add: max1 max2 mult_n_ncols mult_n_nrows assms)+
    apply (simp add: mult_matrix_n_def)
    apply (rule comb_left)
    apply ((rule ext)+, simp)
    apply (simplesubst RepAbs_matrix)
    apply (rule exI[of _ "nrows B"])
    apply (simp add: nrows assms foldseq_zero)
    apply (rule exI[of _ "ncols C"])
    apply (simp add: assms ncols foldseq_zero)
    apply (subst RepAbs_matrix)
    apply (rule exI[of _ "nrows A"])
    apply (simp add: nrows assms foldseq_zero)
    apply (rule exI[of _ "ncols B"])
    apply (simp add: assms ncols foldseq_zero)
    apply (simp add: fmul2fadd1fold fmul1fadd2fold assms)
    apply (subst foldseq_foldseq)
    apply (simp add: assms)+
    apply (simp add: transpose_infmatrix)
    done
qed

lemma
  assumes
  "! a. fmul1 0 a = 0"
  "! a. fmul1 a 0 = 0"
  "! a. fmul2 0 a = 0"
  "! a. fmul2 a 0 = 0"
  "fadd1 0 0 = 0"
  "fadd2 0 0 = 0"
  "! a b c d. fadd2 (fadd1 a b) (fadd1 c d) = fadd1 (fadd2 a c) (fadd2 b d)"
  "associative fadd1"
  "associative fadd2"
  "! a b c. fmul2 (fmul1 a b) c = fmul1 a (fmul2 b c)"
  "! a b c. fmul2 (fadd1 a b) c = fadd1 (fmul2 a c) (fmul2 b c)"
  "! a b c. fmul1 c (fadd2 a b) = fadd2 (fmul1 c a) (fmul1 c b)"
  shows
  "(mult_matrix fmul1 fadd1 A) o (mult_matrix fmul2 fadd2 B) = mult_matrix fmul2 fadd2 (mult_matrix fmul1 fadd1 A B)"
apply (rule ext)+
apply (simp add: comp_def )
apply (simp add: mult_matrix_assoc assms)
done

lemma mult_matrix_assoc_simple:
  assumes
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "fadd 0 0 = 0"
  "associative fadd"
  "commutative fadd"
  "associative fmul"
  "distributive fmul fadd"
  shows "mult_matrix fmul fadd (mult_matrix fmul fadd A B) C = mult_matrix fmul fadd A (mult_matrix fmul fadd B C)"
proof -
  have "!! a b c d. fadd (fadd a b) (fadd c d) = fadd (fadd a c) (fadd b d)"
    using assms by (simp add: associative_def commutative_def)
  then show ?thesis
    apply (subst mult_matrix_assoc)
    using assms
    apply simp_all
    apply (simp_all add: associative_def distributive_def l_distributive_def r_distributive_def)
    done
qed

lemma transpose_apply_matrix: "f 0 = 0 \<Longrightarrow> transpose_matrix (apply_matrix f A) = apply_matrix f (transpose_matrix A)"
apply (simp add: Rep_matrix_inject[THEN sym])
apply (rule ext)+
by simp

lemma transpose_combine_matrix: "f 0 0 = 0 \<Longrightarrow> transpose_matrix (combine_matrix f A B) = combine_matrix f (transpose_matrix A) (transpose_matrix B)"
apply (simp add: Rep_matrix_inject[THEN sym])
apply (rule ext)+
by simp

lemma Rep_mult_matrix:
  assumes
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "fadd 0 0 = 0"
  shows
  "Rep_matrix(mult_matrix fmul fadd A B) j i =
  foldseq fadd (% k. fmul (Rep_matrix A j k) (Rep_matrix B k i)) (max (ncols A) (nrows B))"
apply (simp add: mult_matrix_def mult_matrix_n_def)
apply (subst RepAbs_matrix)
apply (rule exI[of _ "nrows A"], insert assms, simp add: nrows foldseq_zero)
apply (rule exI[of _ "ncols B"], insert assms, simp add: ncols foldseq_zero)
apply simp
done

lemma transpose_mult_matrix:
  assumes
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "fadd 0 0 = 0"
  "! x y. fmul y x = fmul x y"
  shows
  "transpose_matrix (mult_matrix fmul fadd A B) = mult_matrix fmul fadd (transpose_matrix B) (transpose_matrix A)"
  apply (simp add: Rep_matrix_inject[THEN sym])
  apply (rule ext)+
  using assms
  apply (simp add: Rep_mult_matrix max_ac)
  done

lemma column_transpose_matrix: "column_of_matrix (transpose_matrix A) n = transpose_matrix (row_of_matrix A n)"
apply (simp add:  Rep_matrix_inject[THEN sym])
apply (rule ext)+
by simp

lemma take_columns_transpose_matrix: "take_columns (transpose_matrix A) n = transpose_matrix (take_rows A n)"
apply (simp add: Rep_matrix_inject[THEN sym])
apply (rule ext)+
by simp

instantiation matrix :: ("{zero, ord}") ord
begin

definition
  le_matrix_def: "A \<le> B \<longleftrightarrow> (\<forall>j i. Rep_matrix A j i \<le> Rep_matrix B j i)"

definition
  less_def: "A < (B\<Colon>'a matrix) \<longleftrightarrow> A \<le> B \<and> \<not> B \<le> A"

instance ..

end

instance matrix :: ("{zero, order}") order
apply intro_classes
apply (simp_all add: le_matrix_def less_def)
apply (auto)
apply (drule_tac x=j in spec, drule_tac x=j in spec)
apply (drule_tac x=i in spec, drule_tac x=i in spec)
apply (simp)
apply (simp add: Rep_matrix_inject[THEN sym])
apply (rule ext)+
apply (drule_tac x=xa in spec, drule_tac x=xa in spec)
apply (drule_tac x=xb in spec, drule_tac x=xb in spec)
apply simp
done

lemma le_apply_matrix:
  assumes
  "f 0 = 0"
  "! x y. x <= y \<longrightarrow> f x <= f y"
  "(a::('a::{ord, zero}) matrix) <= b"
  shows
  "apply_matrix f a <= apply_matrix f b"
  using assms by (simp add: le_matrix_def)

lemma le_combine_matrix:
  assumes
  "f 0 0 = 0"
  "! a b c d. a <= b & c <= d \<longrightarrow> f a c <= f b d"
  "A <= B"
  "C <= D"
  shows
  "combine_matrix f A C <= combine_matrix f B D"
  using assms by (simp add: le_matrix_def)

lemma le_left_combine_matrix:
  assumes
  "f 0 0 = 0"
  "! a b c. a <= b \<longrightarrow> f c a <= f c b"
  "A <= B"
  shows
  "combine_matrix f C A <= combine_matrix f C B"
  using assms by (simp add: le_matrix_def)

lemma le_right_combine_matrix:
  assumes
  "f 0 0 = 0"
  "! a b c. a <= b \<longrightarrow> f a c <= f b c"
  "A <= B"
  shows
  "combine_matrix f A C <= combine_matrix f B C"
  using assms by (simp add: le_matrix_def)

lemma le_transpose_matrix: "(A <= B) = (transpose_matrix A <= transpose_matrix B)"
  by (simp add: le_matrix_def, auto)

lemma le_foldseq:
  assumes
  "! a b c d . a <= b & c <= d \<longrightarrow> f a c <= f b d"
  "! i. i <= n \<longrightarrow> s i <= t i"
  shows
  "foldseq f s n <= foldseq f t n"
proof -
  have "! s t. (! i. i<=n \<longrightarrow> s i <= t i) \<longrightarrow> foldseq f s n <= foldseq f t n"
    by (induct n) (simp_all add: assms)
  then show "foldseq f s n <= foldseq f t n" using assms by simp
qed

lemma le_left_mult:
  assumes
  "! a b c d. a <= b & c <= d \<longrightarrow> fadd a c <= fadd b d"
  "! c a b.   0 <= c & a <= b \<longrightarrow> fmul c a <= fmul c b"
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "fadd 0 0 = 0"
  "0 <= C"
  "A <= B"
  shows
  "mult_matrix fmul fadd C A <= mult_matrix fmul fadd C B"
  using assms
  apply (simp add: le_matrix_def Rep_mult_matrix)
  apply (auto)
  apply (simplesubst foldseq_zerotail[of _ _ _ "max (ncols C) (max (nrows A) (nrows B))"], simp_all add: nrows ncols max1 max2)+
  apply (rule le_foldseq)
  apply (auto)
  done

lemma le_right_mult:
  assumes
  "! a b c d. a <= b & c <= d \<longrightarrow> fadd a c <= fadd b d"
  "! c a b. 0 <= c & a <= b \<longrightarrow> fmul a c <= fmul b c"
  "! a. fmul 0 a = 0"
  "! a. fmul a 0 = 0"
  "fadd 0 0 = 0"
  "0 <= C"
  "A <= B"
  shows
  "mult_matrix fmul fadd A C <= mult_matrix fmul fadd B C"
  using assms
  apply (simp add: le_matrix_def Rep_mult_matrix)
  apply (auto)
  apply (simplesubst foldseq_zerotail[of _ _ _ "max (nrows C) (max (ncols A) (ncols B))"], simp_all add: nrows ncols max1 max2)+
  apply (rule le_foldseq)
  apply (auto)
  done

lemma spec2: "! j i. P j i \<Longrightarrow> P j i" by blast
lemma neg_imp: "(\<not> Q \<longrightarrow> \<not> P) \<Longrightarrow> P \<longrightarrow> Q" by blast

lemma singleton_matrix_le[simp]: "(singleton_matrix j i a <= singleton_matrix j i b) = (a <= (b::_::order))"
  by (auto simp add: le_matrix_def)

lemma singleton_le_zero[simp]: "(singleton_matrix j i x <= 0) = (x <= (0::'a::{order,zero}))"
  apply (auto)
  apply (simp add: le_matrix_def)
  apply (drule_tac j=j and i=i in spec2)
  apply (simp)
  apply (simp add: le_matrix_def)
  done

lemma singleton_ge_zero[simp]: "(0 <= singleton_matrix j i x) = ((0::'a::{order,zero}) <= x)"
  apply (auto)
  apply (simp add: le_matrix_def)
  apply (drule_tac j=j and i=i in spec2)
  apply (simp)
  apply (simp add: le_matrix_def)
  done

lemma move_matrix_le_zero[simp]: "0 <= j \<Longrightarrow> 0 <= i \<Longrightarrow> (move_matrix A j i <= 0) = (A <= (0::('a::{order,zero}) matrix))"
  apply (auto simp add: le_matrix_def)
  apply (drule_tac j="ja+(nat j)" and i="ia+(nat i)" in spec2)
  apply (auto)
  done

lemma move_matrix_zero_le[simp]: "0 <= j \<Longrightarrow> 0 <= i \<Longrightarrow> (0 <= move_matrix A j i) = ((0::('a::{order,zero}) matrix) <= A)"
  apply (auto simp add: le_matrix_def)
  apply (drule_tac j="ja+(nat j)" and i="ia+(nat i)" in spec2)
  apply (auto)
  done

lemma move_matrix_le_move_matrix_iff[simp]: "0 <= j \<Longrightarrow> 0 <= i \<Longrightarrow> (move_matrix A j i <= move_matrix B j i) = (A <= (B::('a::{order,zero}) matrix))"
  apply (auto simp add: le_matrix_def)
  apply (drule_tac j="ja+(nat j)" and i="ia+(nat i)" in spec2)
  apply (auto)
  done  

instantiation matrix :: ("{lattice, zero}") lattice
begin

definition "inf = combine_matrix inf"

definition "sup = combine_matrix sup"

instance
  by default (auto simp add: le_infI le_matrix_def inf_matrix_def sup_matrix_def)

end

instantiation matrix :: ("{plus, zero}") plus
begin

definition
  plus_matrix_def: "A + B = combine_matrix (op +) A B"

instance ..

end

instantiation matrix :: ("{uminus, zero}") uminus
begin

definition
  minus_matrix_def: "- A = apply_matrix uminus A"

instance ..

end

instantiation matrix :: ("{minus, zero}") minus
begin

definition
  diff_matrix_def: "A - B = combine_matrix (op -) A B"

instance ..

end

instantiation matrix :: ("{plus, times, zero}") times
begin

definition
  times_matrix_def: "A * B = mult_matrix (op *) (op +) A B"

instance ..

end

instantiation matrix :: ("{lattice, uminus, zero}") abs
begin

definition
  abs_matrix_def: "abs (A \<Colon> 'a matrix) = sup A (- A)"

instance ..

end

instance matrix :: (monoid_add) monoid_add
proof
  fix A B C :: "'a matrix"
  show "A + B + C = A + (B + C)"    
    apply (simp add: plus_matrix_def)
    apply (rule combine_matrix_assoc[simplified associative_def, THEN spec, THEN spec, THEN spec])
    apply (simp_all add: add_assoc)
    done
  show "0 + A = A"
    apply (simp add: plus_matrix_def)
    apply (rule combine_matrix_zero_l_neutral[simplified zero_l_neutral_def, THEN spec])
    apply (simp)
    done
  show "A + 0 = A"
    apply (simp add: plus_matrix_def)
    apply (rule combine_matrix_zero_r_neutral [simplified zero_r_neutral_def, THEN spec])
    apply (simp)
    done
qed

instance matrix :: (comm_monoid_add) comm_monoid_add
proof
  fix A B :: "'a matrix"
  show "A + B = B + A"
    apply (simp add: plus_matrix_def)
    apply (rule combine_matrix_commute[simplified commutative_def, THEN spec, THEN spec])
    apply (simp_all add: add_commute)
    done
  show "0 + A = A"
    apply (simp add: plus_matrix_def)
    apply (rule combine_matrix_zero_l_neutral[simplified zero_l_neutral_def, THEN spec])
    apply (simp)
    done
qed

instance matrix :: (group_add) group_add
proof
  fix A B :: "'a matrix"
  show "- A + A = 0" 
    by (simp add: plus_matrix_def minus_matrix_def Rep_matrix_inject[symmetric] ext)
  show "A - B = A + - B"
    by (simp add: plus_matrix_def diff_matrix_def minus_matrix_def Rep_matrix_inject [symmetric] ext diff_minus)
qed

instance matrix :: (ab_group_add) ab_group_add
proof
  fix A B :: "'a matrix"
  show "- A + A = 0" 
    by (simp add: plus_matrix_def minus_matrix_def Rep_matrix_inject[symmetric] ext)
  show "A - B = A + - B" 
    by (simp add: plus_matrix_def diff_matrix_def minus_matrix_def Rep_matrix_inject[symmetric] ext)
qed

instance matrix :: (ordered_ab_group_add) ordered_ab_group_add
proof
  fix A B C :: "'a matrix"
  assume "A <= B"
  then show "C + A <= C + B"
    apply (simp add: plus_matrix_def)
    apply (rule le_left_combine_matrix)
    apply (simp_all)
    done
qed
  
instance matrix :: (lattice_ab_group_add) semilattice_inf_ab_group_add ..
instance matrix :: (lattice_ab_group_add) semilattice_sup_ab_group_add ..

instance matrix :: (semiring_0) semiring_0
proof
  fix A B C :: "'a matrix"
  show "A * B * C = A * (B * C)"
    apply (simp add: times_matrix_def)
    apply (rule mult_matrix_assoc)
    apply (simp_all add: associative_def algebra_simps)
    done
  show "(A + B) * C = A * C + B * C"
    apply (simp add: times_matrix_def plus_matrix_def)
    apply (rule l_distributive_matrix[simplified l_distributive_def, THEN spec, THEN spec, THEN spec])
    apply (simp_all add: associative_def commutative_def algebra_simps)
    done
  show "A * (B + C) = A * B + A * C"
    apply (simp add: times_matrix_def plus_matrix_def)
    apply (rule r_distributive_matrix[simplified r_distributive_def, THEN spec, THEN spec, THEN spec])
    apply (simp_all add: associative_def commutative_def algebra_simps)
    done
  show "0 * A = 0" by (simp add: times_matrix_def)
  show "A * 0 = 0" by (simp add: times_matrix_def)
qed

instance matrix :: (ring) ring ..

instance matrix :: (ordered_ring) ordered_ring
proof
  fix A B C :: "'a matrix"
  assume a: "A \<le> B"
  assume b: "0 \<le> C"
  from a b show "C * A \<le> C * B"
    apply (simp add: times_matrix_def)
    apply (rule le_left_mult)
    apply (simp_all add: add_mono mult_left_mono)
    done
  from a b show "A * C \<le> B * C"
    apply (simp add: times_matrix_def)
    apply (rule le_right_mult)
    apply (simp_all add: add_mono mult_right_mono)
    done
qed

instance matrix :: (lattice_ring) lattice_ring
proof
  fix A B C :: "('a :: lattice_ring) matrix"
  show "abs A = sup A (-A)" 
    by (simp add: abs_matrix_def)
qed

lemma Rep_matrix_add[simp]:
  "Rep_matrix ((a::('a::monoid_add)matrix)+b) j i  = (Rep_matrix a j i) + (Rep_matrix b j i)"
  by (simp add: plus_matrix_def)

lemma Rep_matrix_mult: "Rep_matrix ((a::('a::semiring_0) matrix) * b) j i = 
  foldseq (op +) (% k.  (Rep_matrix a j k) * (Rep_matrix b k i)) (max (ncols a) (nrows b))"
apply (simp add: times_matrix_def)
apply (simp add: Rep_mult_matrix)
done

lemma apply_matrix_add: "! x y. f (x+y) = (f x) + (f y) \<Longrightarrow> f 0 = (0::'a)
  \<Longrightarrow> apply_matrix f ((a::('a::monoid_add) matrix) + b) = (apply_matrix f a) + (apply_matrix f b)"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (simp)
done

lemma singleton_matrix_add: "singleton_matrix j i ((a::_::monoid_add)+b) = (singleton_matrix j i a) + (singleton_matrix j i b)"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (simp)
done

lemma nrows_mult: "nrows ((A::('a::semiring_0) matrix) * B) <= nrows A"
by (simp add: times_matrix_def mult_nrows)

lemma ncols_mult: "ncols ((A::('a::semiring_0) matrix) * B) <= ncols B"
by (simp add: times_matrix_def mult_ncols)

definition
  one_matrix :: "nat \<Rightarrow> ('a::{zero,one}) matrix" where
  "one_matrix n = Abs_matrix (% j i. if j = i & j < n then 1 else 0)"

lemma Rep_one_matrix[simp]: "Rep_matrix (one_matrix n) j i = (if (j = i & j < n) then 1 else 0)"
apply (simp add: one_matrix_def)
apply (simplesubst RepAbs_matrix)
apply (rule exI[of _ n], simp add: split_if)+
by (simp add: split_if)

lemma nrows_one_matrix[simp]: "nrows ((one_matrix n) :: ('a::zero_neq_one)matrix) = n" (is "?r = _")
proof -
  have "?r <= n" by (simp add: nrows_le)
  moreover have "n <= ?r" by (simp add:le_nrows, arith)
  ultimately show "?r = n" by simp
qed

lemma ncols_one_matrix[simp]: "ncols ((one_matrix n) :: ('a::zero_neq_one)matrix) = n" (is "?r = _")
proof -
  have "?r <= n" by (simp add: ncols_le)
  moreover have "n <= ?r" by (simp add: le_ncols, arith)
  ultimately show "?r = n" by simp
qed

lemma one_matrix_mult_right[simp]: "ncols A <= n \<Longrightarrow> (A::('a::{semiring_1}) matrix) * (one_matrix n) = A"
apply (subst Rep_matrix_inject[THEN sym])
apply (rule ext)+
apply (simp add: times_matrix_def Rep_mult_matrix)
apply (rule_tac j1="xa" in ssubst[OF foldseq_almostzero])
apply (simp_all)
by (simp add: ncols)

lemma one_matrix_mult_left[simp]: "nrows A <= n \<Longrightarrow> (one_matrix n) * A = (A::('a::semiring_1) matrix)"
apply (subst Rep_matrix_inject[THEN sym])
apply (rule ext)+
apply (simp add: times_matrix_def Rep_mult_matrix)
apply (rule_tac j1="x" in ssubst[OF foldseq_almostzero])
apply (simp_all)
by (simp add: nrows)

lemma transpose_matrix_mult: "transpose_matrix ((A::('a::comm_ring) matrix)*B) = (transpose_matrix B) * (transpose_matrix A)"
apply (simp add: times_matrix_def)
apply (subst transpose_mult_matrix)
apply (simp_all add: mult_commute)
done

lemma transpose_matrix_add: "transpose_matrix ((A::('a::monoid_add) matrix)+B) = transpose_matrix A + transpose_matrix B"
by (simp add: plus_matrix_def transpose_combine_matrix)

lemma transpose_matrix_diff: "transpose_matrix ((A::('a::group_add) matrix)-B) = transpose_matrix A - transpose_matrix B"
by (simp add: diff_matrix_def transpose_combine_matrix)

lemma transpose_matrix_minus: "transpose_matrix (-(A::('a::group_add) matrix)) = - transpose_matrix (A::'a matrix)"
by (simp add: minus_matrix_def transpose_apply_matrix)

definition right_inverse_matrix :: "('a::{ring_1}) matrix \<Rightarrow> 'a matrix \<Rightarrow> bool" where
  "right_inverse_matrix A X == (A * X = one_matrix (max (nrows A) (ncols X))) \<and> nrows X \<le> ncols A" 

definition left_inverse_matrix :: "('a::{ring_1}) matrix \<Rightarrow> 'a matrix \<Rightarrow> bool" where
  "left_inverse_matrix A X == (X * A = one_matrix (max(nrows X) (ncols A))) \<and> ncols X \<le> nrows A" 

definition inverse_matrix :: "('a::{ring_1}) matrix \<Rightarrow> 'a matrix \<Rightarrow> bool" where
  "inverse_matrix A X == (right_inverse_matrix A X) \<and> (left_inverse_matrix A X)"

lemma right_inverse_matrix_dim: "right_inverse_matrix A X \<Longrightarrow> nrows A = ncols X"
apply (insert ncols_mult[of A X], insert nrows_mult[of A X])
by (simp add: right_inverse_matrix_def)

lemma left_inverse_matrix_dim: "left_inverse_matrix A Y \<Longrightarrow> ncols A = nrows Y"
apply (insert ncols_mult[of Y A], insert nrows_mult[of Y A]) 
by (simp add: left_inverse_matrix_def)

lemma left_right_inverse_matrix_unique: 
  assumes "left_inverse_matrix A Y" "right_inverse_matrix A X"
  shows "X = Y"
proof -
  have "Y = Y * one_matrix (nrows A)" 
    apply (subst one_matrix_mult_right)
    using assms
    apply (simp_all add: left_inverse_matrix_def)
    done
  also have "\<dots> = Y * (A * X)" 
    apply (insert assms)
    apply (frule right_inverse_matrix_dim)
    by (simp add: right_inverse_matrix_def)
  also have "\<dots> = (Y * A) * X" by (simp add: mult_assoc)
  also have "\<dots> = X" 
    apply (insert assms)
    apply (frule left_inverse_matrix_dim)
    apply (simp_all add:  left_inverse_matrix_def right_inverse_matrix_def one_matrix_mult_left)
    done
  ultimately show "X = Y" by (simp)
qed

lemma inverse_matrix_inject: "\<lbrakk> inverse_matrix A X; inverse_matrix A Y \<rbrakk> \<Longrightarrow> X = Y"
  by (auto simp add: inverse_matrix_def left_right_inverse_matrix_unique)

lemma one_matrix_inverse: "inverse_matrix (one_matrix n) (one_matrix n)"
  by (simp add: inverse_matrix_def left_inverse_matrix_def right_inverse_matrix_def)

lemma zero_imp_mult_zero: "(a::'a::semiring_0) = 0 | b = 0 \<Longrightarrow> a * b = 0"
by auto

lemma Rep_matrix_zero_imp_mult_zero:
  "! j i k. (Rep_matrix A j k = 0) | (Rep_matrix B k i) = 0  \<Longrightarrow> A * B = (0::('a::lattice_ring) matrix)"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (auto simp add: Rep_matrix_mult foldseq_zero zero_imp_mult_zero)
done

lemma add_nrows: "nrows (A::('a::monoid_add) matrix) <= u \<Longrightarrow> nrows B <= u \<Longrightarrow> nrows (A + B) <= u"
apply (simp add: plus_matrix_def)
apply (rule combine_nrows)
apply (simp_all)
done

lemma move_matrix_row_mult: "move_matrix ((A::('a::semiring_0) matrix) * B) j 0 = (move_matrix A j 0) * B"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (auto simp add: Rep_matrix_mult foldseq_zero)
apply (rule_tac foldseq_zerotail[symmetric])
apply (auto simp add: nrows zero_imp_mult_zero max2)
apply (rule order_trans)
apply (rule ncols_move_matrix_le)
apply (simp add: max1)
done

lemma move_matrix_col_mult: "move_matrix ((A::('a::semiring_0) matrix) * B) 0 i = A * (move_matrix B 0 i)"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (auto simp add: Rep_matrix_mult foldseq_zero)
apply (rule_tac foldseq_zerotail[symmetric])
apply (auto simp add: ncols zero_imp_mult_zero max1)
apply (rule order_trans)
apply (rule nrows_move_matrix_le)
apply (simp add: max2)
done

lemma move_matrix_add: "((move_matrix (A + B) j i)::(('a::monoid_add) matrix)) = (move_matrix A j i) + (move_matrix B j i)" 
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (simp)
done

lemma move_matrix_mult: "move_matrix ((A::('a::semiring_0) matrix)*B) j i = (move_matrix A j 0) * (move_matrix B 0 i)"
by (simp add: move_matrix_ortho[of "A*B"] move_matrix_col_mult move_matrix_row_mult)

definition scalar_mult :: "('a::ring) \<Rightarrow> 'a matrix \<Rightarrow> 'a matrix" where
  "scalar_mult a m == apply_matrix (op * a) m"

lemma scalar_mult_zero[simp]: "scalar_mult y 0 = 0" 
by (simp add: scalar_mult_def)

lemma scalar_mult_add: "scalar_mult y (a+b) = (scalar_mult y a) + (scalar_mult y b)"
by (simp add: scalar_mult_def apply_matrix_add algebra_simps)

lemma Rep_scalar_mult[simp]: "Rep_matrix (scalar_mult y a) j i = y * (Rep_matrix a j i)" 
by (simp add: scalar_mult_def)

lemma scalar_mult_singleton[simp]: "scalar_mult y (singleton_matrix j i x) = singleton_matrix j i (y * x)"
apply (subst Rep_matrix_inject[symmetric])
apply (rule ext)+
apply (auto)
done

lemma Rep_minus[simp]: "Rep_matrix (-(A::_::group_add)) x y = - (Rep_matrix A x y)"
by (simp add: minus_matrix_def)

lemma Rep_abs[simp]: "Rep_matrix (abs (A::_::lattice_ab_group_add)) x y = abs (Rep_matrix A x y)"
by (simp add: abs_lattice sup_matrix_def)

end
