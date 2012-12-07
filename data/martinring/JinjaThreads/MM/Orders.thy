(*  Title:      JinjaThreads/MM/Orders.thy
    Author:     Andreas Lochbihler
*)

header {* \isaheader{Orders as predicates} *}

theory Orders
imports
  Main
  "~~/src/HOL/Library/Zorn"
begin

section {* Preliminaries *}

text {* transfer @{term "refl_on"} et al. from @{theory Relation} to predicates *}

abbreviation refl_onP :: "'a set \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "refl_onP A r \<equiv> refl_on A {(x, y). r x y}"

abbreviation reflP :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool" 
where "reflP == refl_onP UNIV"

abbreviation symP :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "symP r \<equiv> sym {(x, y). r x y}"

abbreviation total_onP :: "'a set \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "total_onP A r \<equiv> total_on A {(x, y). r x y}"

abbreviation irreflP :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "irreflP r == irrefl {(x, y). r x y}"

definition irreflclp :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool" ("_\<^sup>\<noteq>\<^sup>\<noteq>" [1000] 1000)
where "r\<^sup>\<noteq>\<^sup>\<noteq> a b = (r a b \<and> a \<noteq> b)"

definition porder_on :: "'a set \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "porder_on A r \<longleftrightarrow> refl_onP A r \<and> transP r \<and> antisymP r"

definition torder_on :: "'a set \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "torder_on A r \<longleftrightarrow> porder_on A r \<and> total_onP A r"

definition order_consistent :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool"
where "order_consistent r s \<longleftrightarrow> (\<forall>a a'. r a a' \<and> s a' a \<longrightarrow> a = a')"

definition restrictP :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a set \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> bool" (infixl "|`" 110)
where "(r |` A) a b \<longleftrightarrow> r a b \<and> a \<in> A \<and> b \<in> A"

definition inv_imageP :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> ('b \<Rightarrow> 'a) \<Rightarrow> 'b \<Rightarrow> 'b \<Rightarrow> bool"
where [iff]: "inv_imageP r f a b \<longleftrightarrow> r (f a) (f b)"

lemma refl_onPI: "(\<And>a a'. r a a' \<Longrightarrow> a \<in> A \<and> a' \<in> A) \<Longrightarrow> (\<And>a. a : A \<Longrightarrow> r a a) \<Longrightarrow> refl_onP A r"
by(rule refl_onI)(auto)

lemma refl_onPD: "refl_onP A r ==> a : A ==> r a a"
by(drule (1) refl_onD)(simp)

lemma refl_onPD1: "refl_onP A r ==> r a b ==> a : A"
by(erule refl_onD1)(simp)

lemma refl_onPD2: "refl_onP A r ==> r a b ==> b : A"
by(erule refl_onD2)(simp)

lemma refl_onP_Int: "refl_onP A r ==> refl_onP B s ==> refl_onP (A \<inter> B) (\<lambda>a a'. r a a' \<and> s a a')"
by(drule (1) refl_on_Int)(simp add: split_def inf_fun_def inf_set_def)

lemma refl_onP_Un: "refl_onP A r ==> refl_onP B s ==> refl_onP (A \<union> B) (\<lambda>a a'. r a a' \<or> s a a')"
by(drule (1) refl_on_Un)(simp add: split_def sup_fun_def sup_set_def)

lemma refl_onP_empty[simp]: "refl_onP {} (\<lambda>a a'. False)"
unfolding split_def by simp

lemma refl_onP_tranclp:
  assumes "refl_onP A r"
  shows "refl_onP A r^++"
proof(rule refl_onPI)
  fix a a'
  assume "r^++ a a'"
  thus "a \<in> A \<and> a' \<in> A"
    by(induct)(blast intro: refl_onPD1[OF assms] refl_onPD2[OF assms])+
next
  fix a
  assume "a \<in> A"
  from refl_onPD[OF assms this] show "r^++ a a" ..
qed

lemma irreflPI: "(\<And>a. \<not> r a a) \<Longrightarrow> irreflP r"
unfolding irrefl_def by blast

lemma irreflPE:
  assumes "irreflP r" 
  obtains "\<forall>a. \<not> r a a"
using assms unfolding irrefl_def by blast

lemma irreflPD: "\<lbrakk> irreflP r; r a a \<rbrakk> \<Longrightarrow> False"
unfolding irrefl_def by blast

lemma irreflclpD:
  "r\<^sup>\<noteq>\<^sup>\<noteq> a b \<Longrightarrow> r a b \<and> a \<noteq> b"
by(simp add: irreflclp_def)

lemma irreflclpI [intro!]:
  "\<lbrakk> r a b; a \<noteq> b \<rbrakk> \<Longrightarrow> r\<^sup>\<noteq>\<^sup>\<noteq> a b"
by(simp add: irreflclp_def)

lemma irreflclpE [elim!]:
  assumes "r\<^sup>\<noteq>\<^sup>\<noteq> a b"
  obtains "r a b" "a \<noteq> b"
using assms by(simp add: irreflclp_def)

lemma transPI: "(\<And>x y z. \<lbrakk> r x y; r y z \<rbrakk> \<Longrightarrow> r x z) \<Longrightarrow> transP r"
using transI[where r="{(x, y). r x y}"] by blast

lemma transPD: "\<lbrakk>transP r; r x y; r y z \<rbrakk> \<Longrightarrow> r x z"
by(drule transD) auto

lemma transP_tranclp: "transP r^++"
using trans_trancl[of "{(x, y). r x y}"]
unfolding trancl_def by simp

lemma antisymPI: "(\<And>x y. \<lbrakk> r x y; r y x \<rbrakk> \<Longrightarrow> x = y) \<Longrightarrow> antisymP r"
using antisymI[of "{(x, y). r x y}"] by blast

lemma antisymPD: "\<lbrakk> antisymP r; r a b; r b a \<rbrakk> \<Longrightarrow> a = b"
using antisymD[where r="{(a, b). r a b}"] by blast

lemma antisym_subset:
  "\<lbrakk> antisymP r; \<And>a a'. s a a' \<Longrightarrow> r a a' \<rbrakk> \<Longrightarrow> antisymP s"
by(blast intro: antisymI antisymD)

lemma symPI: "(\<And>x y. r x y \<Longrightarrow> r y x) \<Longrightarrow> symP r"
by(rule symI)(blast)

lemma symPD: "\<lbrakk> symP r; r x y \<rbrakk> \<Longrightarrow> r y x"
by(blast dest: symD)

section {* Easy properties *}

lemma porder_onI:
  "\<lbrakk> refl_onP A r; antisymP r; transP r \<rbrakk> \<Longrightarrow> porder_on A r"
unfolding porder_on_def by blast

lemma porder_onE:
  assumes "porder_on A r"
  obtains "refl_onP A r" "antisymP r" "transP r"
using assms unfolding porder_on_def by blast

lemma torder_onI:
  "\<lbrakk> porder_on A r; total_onP A r \<rbrakk> \<Longrightarrow> torder_on A r"
unfolding torder_on_def by blast

lemma torder_onE:
  assumes "torder_on A r"
  obtains "porder_on A r" "total_onP A r"
using assms unfolding torder_on_def by blast

lemma total_onI:
  "(\<And>x y. \<lbrakk> x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> (x, y) \<in> r \<or> x = y \<or> (y, x) \<in> r) \<Longrightarrow> total_on A r"
unfolding total_on_def by blast

lemma total_onPI:
  "(\<And>x y. \<lbrakk> x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> r x y \<or> x = y \<or> r y x) \<Longrightarrow> total_onP A r"
by(rule total_onI) simp

lemma total_onD:
  "\<lbrakk> total_on A r; x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> (x, y) \<in> r \<or> x = y \<or> (y, x) \<in> r"
unfolding total_on_def by blast

lemma total_onPD:
  "\<lbrakk> total_onP A r; x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> r x y \<or> x = y \<or> r y x"
by(drule (2) total_onD) blast

section {* Order consistency *}

lemma order_consistentI:
  "(\<And>a a'. \<lbrakk> r a a'; s a' a \<rbrakk> \<Longrightarrow> a = a') \<Longrightarrow> order_consistent r s"
unfolding order_consistent_def by blast

lemma order_consistentD:
  "\<lbrakk> order_consistent r s; r a a'; s a' a \<rbrakk> \<Longrightarrow> a = a'"
unfolding order_consistent_def by blast

lemma order_consistent_subset:
  "\<lbrakk> order_consistent r s; \<And>a a'. r' a a' \<Longrightarrow> r a a'; \<And>a a'. s' a a' \<Longrightarrow> s a a' \<rbrakk> \<Longrightarrow> order_consistent r' s'"
by(blast intro: order_consistentI order_consistentD)

lemma order_consistent_sym:
  "order_consistent r s \<Longrightarrow> order_consistent s r"
by(blast intro: order_consistentI dest: order_consistentD)

lemma antisym_order_consistent_self:
  "antisymP r \<Longrightarrow> order_consistent r r"
by(rule order_consistentI)(erule antisymD, simp_all)

lemma total_on_refl_on_consistent_into:
  assumes r: "total_onP A r" "refl_onP A r"
  and consist: "order_consistent r s"
  and x: "x \<in> A" and y: "y \<in> A" and s: "s x y"
  shows "r x y"
proof(cases "x = y")
  case True
  with r x y show ?thesis by(blast intro: refl_onPD)
next
  case False
  with r x y have "r x y \<or> r y x" by(blast dest: total_onD)
  thus ?thesis
  proof
    assume "r y x"
    with s consist have "x = y" by(blast dest: order_consistentD)
    with False show ?thesis by(contradiction)
  qed
qed

lemma porder_torder_tranclpE [consumes 5, case_names base step]:
  assumes r: "porder_on A r"
  and s: "torder_on B s"
  and consist: "order_consistent r s"
  and B_subset_A: "B \<subseteq> A"
  and trancl: "(\<lambda>a b. r a b \<or> s a b)^++ x y"
  obtains "r x y"
        | u v where "r x u" "s u v" "r v y"
proof(atomize_elim)
  from r have "refl_onP A r" "transP r" by(blast elim: porder_onE)+
  from s have "refl_onP B s" "total_onP B s" "transP s"
    by(blast elim: torder_onE porder_onE)+

  from trancl show "r x y \<or> (\<exists>u v. r x u \<and> s u v \<and> r v y)"
  proof(induct)
    case (base y)
    thus ?case
    proof
      assume "s x y"
      with s have "x \<in> B" "y \<in> B"
        by(blast elim: torder_onE porder_onE dest: refl_onPD1 refl_onPD2)+
      with B_subset_A have "x \<in> A" "y \<in> A" by blast+
      with refl_onPD[OF `refl_onP A r`, of x] refl_onPD[OF `refl_onP A r`, of y] `s x y`
      show ?thesis by(iprover)
    next
      assume "r x y"
      thus ?thesis ..
    qed
  next
    case (step y z)
    note IH = `r x y \<or> (\<exists>u v. r x u \<and> s u v \<and> r v y)`
    from `r y z \<or> s y z` show ?case
    proof
      assume "s y z"
      with `refl_onP B s` have "y \<in> B" "z \<in> B"
        by(blast dest: refl_onPD2 refl_onPD1)+
      from IH show ?thesis
      proof
        assume "r x y"
        moreover from `z \<in> B` B_subset_A r have "r z z"
          by(blast elim: porder_onE dest: refl_onPD)
        ultimately show ?thesis using `s y z` by blast
      next
        assume "\<exists>u v. r x u \<and> s u v \<and> r v y"
        then obtain u v where "r x u" "s u v" "r v y" by blast
        from `refl_onP B s` `s u v` have "v \<in> B" by(rule refl_onPD2)
        with `total_onP B s` `refl_onP B s` order_consistent_sym[OF consist]
        have "s v y" using `y \<in> B` `r v y`
          by(rule total_on_refl_on_consistent_into)
        with `transP s` have "s v z" using `s y z` by(rule transPD)
        with `transP s` `s u v` have "s u z" by(rule transPD)
        moreover from `z \<in> B` B_subset_A have "z \<in> A" ..
        with `refl_onP A r` have "r z z" by(rule refl_onPD)
        ultimately show ?thesis using `r x u` by blast
      qed
    next
      assume "r y z"
      with IH show ?thesis
        by(blast intro: transPD[OF `transP r`])
    qed
  qed
qed

lemma torder_on_porder_on_consistent_tranclp_antisym:
  assumes r: "porder_on A r"
  and s: "torder_on B s"
  and consist: "order_consistent r s"
  and B_subset_A: "B \<subseteq> A"
  shows "antisymP (\<lambda>x y. r x y \<or> s x y)^++"
proof(rule antisymPI)
  fix x y
  let ?rs = "\<lambda>x y. r x y \<or> s x y"
  assume "?rs^++ x y" "?rs^++ y x"
  from r have "antisymP r" "transP r" by(blast elim: porder_onE)+
  from s have "total_onP B s" "refl_onP B s" "transP s" "antisymP s"
    by(blast elim: torder_onE porder_onE)+

  from r s consist B_subset_A `?rs^++ x y`
  show "x = y"
  proof(cases rule: porder_torder_tranclpE)
    case base
    from r s consist B_subset_A `?rs^++ y x`
    show ?thesis
    proof(cases rule: porder_torder_tranclpE)
      case base
      with `antisymP r` `r x y` show ?thesis by(rule antisymPD)
    next
      case (step u v)
      from `r v x` `r x y` `r y u` have "r v u" by(blast intro: transPD[OF `transP r`])
      with consist have "v = u" using `s u v` by(rule order_consistentD)
      with `r y u` `r v x` have "r y x" by(blast intro: transPD[OF `transP r`])
      with `r x y` show ?thesis by(rule antisymPD[OF `antisymP r`])
    qed
  next
    case (step u v)
    from r s consist B_subset_A `?rs^++ y x`
    show ?thesis
    proof(cases rule: porder_torder_tranclpE)
      case base
      from `r v y` `r y x` `r x u` have "r v u" by(blast intro: transPD[OF `transP r`])
      with order_consistent_sym[OF consist] `s u v`
      have "u = v" by(rule order_consistentD)
      with `r v y` `r x u` have "r x y" by(blast intro: transPD[OF `transP r`])
      thus ?thesis using `r y x` by(rule antisymPD[OF `antisymP r`])
    next
      case (step u' v')
      note r_into_s = total_on_refl_on_consistent_into[OF `total_onP B s` `refl_onP B s` order_consistent_sym[OF consist]]
      from `refl_onP B s` `s u v` `s u' v'`
      have "u \<in> B" "v \<in> B" "u' \<in> B" "v' \<in> B" by(blast dest: refl_onPD1 refl_onPD2)+
      from `r v' x` `r x u` have "r v' u" by(rule transPD[OF `transP r`])
      with `v' \<in> B` `u \<in> B` have "s v' u" by(rule r_into_s)
      also note `s u v`
      also (transPD[OF `transP s`])
      from `r v y` `r y u'` have "r v u'" by(rule transPD[OF `transP r`])
      with `v \<in> B` `u' \<in> B` have "s v u'" by(rule r_into_s)
      finally (transPD[OF `transP s`])
      have "v' = u'" using `s u' v'` by(rule antisymPD[OF `antisymP s`])
      moreover with `s v u'` `s v' u` have "s v u" by(blast intro: transPD[OF `transP s`])
      with `s u v` have "u = v" by(rule antisymPD[OF `antisymP s`])
      ultimately have "r x y" "r y x" using `r x u` `r v y` `r y u'` `r v' x`
        by(blast intro: transPD[OF `transP r`])+
      thus ?thesis by(rule antisymPD[OF `antisymP r`])
    qed
  qed
qed

lemma porder_on_torder_on_tranclp_porder_onI:
  assumes r: "porder_on A r"
  and s: "torder_on B s" 
  and consist: "order_consistent r s"
  and subset: "B \<subseteq> A"
  shows "porder_on A (\<lambda>a b. r a b \<or> s a b)^++"
proof(rule porder_onI)
  let ?rs = "\<lambda>a b. r a b \<or> s a b"
  from r have "refl_onP A r" by(rule porder_onE)
  moreover from s have "refl_onP B s" by(blast elim: torder_onE porder_onE)
  ultimately have "refl_onP (A \<union> B) ?rs" by(rule refl_onP_Un)
  also from subset have "A \<union> B = A" by blast
  finally show "refl_onP A ?rs^++" by(rule refl_onP_tranclp)

  show "transP ?rs^++" by(rule transP_tranclp)

  from r s consist subset show "antisymP ?rs^++"
    by (rule torder_on_porder_on_consistent_tranclp_antisym)
qed

lemma porder_on_sub_torder_on_tranclp_porder_onI:
  assumes r: "porder_on A r"
  and s: "torder_on B s"
  and consist: "order_consistent r s"
  and t: "\<And>x y. t x y \<Longrightarrow> s x y"
  and subset: "B \<subseteq> A"
  shows "porder_on A (\<lambda>x y. r x y \<or> t x y)^++"
proof(rule porder_onI)
  let ?rt = "\<lambda>x y. r x y \<or> t x y"
  let ?rs = "\<lambda>x y. r x y \<or> s x y"
  from r s consist subset have "antisymP ?rs^++"
    by(rule torder_on_porder_on_consistent_tranclp_antisym)
  thus "antisymP ?rt^++"
  proof(rule antisym_subset)
    fix x y
    assume "?rt^++ x y" thus "?rs^++ x y"
      by(induct)(blast intro: tranclp.r_into_trancl t tranclp.trancl_into_trancl t)+
  qed

  from s have "refl_onP B s" by(blast elim: porder_onE torder_onE)
  { fix x y
    assume "t x y"
    hence "s x y" by(rule t)
    hence "x \<in> B" "y \<in> B"
      by(blast dest: refl_onPD1[OF `refl_onP B s`] refl_onPD2[OF `refl_onP B s`])+
    with subset have "x \<in> A" "y \<in> A" by blast+ }
  note t_reflD = this

  from r have "refl_onP A r" by(rule porder_onE)
  show "refl_onP A ?rt^++"
  proof(rule refl_onPI)
    fix a a'
    assume "?rt^++ a a'"
    thus "a \<in> A \<and> a' \<in> A"
      by(induct)(auto dest: refl_onPD1[OF `refl_onP A r`] refl_onPD2[OF `refl_onP A r`] t_reflD)
  next
    fix a
    assume "a \<in> A"
    with `refl_onP A r` have "r a a" by(rule refl_onPD)
    thus "?rt^++ a a" by(blast intro: tranclp.r_into_trancl)
  qed

  show "transP ?rt^++" by(rule transP_tranclp)
qed

section {* Order restrictions *}

lemma restrictPI [intro!, simp]:
  "\<lbrakk> r a b; a \<in> A; b \<in> A \<rbrakk> \<Longrightarrow> (r |` A) a b"
unfolding restrictP_def by simp

lemma restrictPE [elim!]:
  assumes "(r |` A) a b"
  obtains "r a b" "a \<in> A" "b \<in> A"
using assms unfolding restrictP_def by simp

lemma refl_on_restrictPI:
  "refl_onP A r \<Longrightarrow> refl_onP (A \<inter> B) (r |` B)"
by(rule refl_onPI)(blast dest: refl_onPD1 refl_onPD2 refl_onPD)+

lemma refl_on_restrictPI':
  "\<lbrakk> refl_onP A r; B = A \<inter> C \<rbrakk> \<Longrightarrow> refl_onP B (r |` C)"
by(simp add: refl_on_restrictPI)

lemma antisym_restrictPI:
  "antisymP r \<Longrightarrow> antisymP (r |` A)"
by(rule antisymPI)(blast dest: antisymPD)

lemma trans_restrictPI:
  "transP r \<Longrightarrow> transP (r |` A)"
by(rule transPI)(blast dest: transPD)

lemma porder_on_restrictPI:
  "porder_on A r \<Longrightarrow> porder_on (A \<inter> B) (r |` B)"
by(blast elim: porder_onE intro: refl_on_restrictPI antisym_restrictPI trans_restrictPI porder_onI)

lemma porder_on_restrictPI':
  "\<lbrakk> porder_on A r; B = A \<inter> C \<rbrakk> \<Longrightarrow> porder_on B (r |` C)"
by(simp add: porder_on_restrictPI)

lemma total_on_restrictPI:
  "total_onP A r \<Longrightarrow> total_onP (A \<inter> B) (r |` B)"
by(blast intro: total_onPI dest: total_onPD)

lemma total_on_restrictPI':
  "\<lbrakk> total_onP A r; B = A \<inter> C \<rbrakk> \<Longrightarrow> total_onP B (r |` C)"
by(simp add: total_on_restrictPI)

lemma torder_on_restrictPI:
  "torder_on A r \<Longrightarrow> torder_on (A \<inter> B) (r |` B)"
by(blast elim: torder_onE intro: torder_onI porder_on_restrictPI total_on_restrictPI)

lemma torder_on_restrictPI':
  "\<lbrakk> torder_on A r; B = A \<inter> C \<rbrakk> \<Longrightarrow> torder_on B (r |` C)"
by(simp add: torder_on_restrictPI)

lemma restrictP_commute:
  fixes r :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  shows "r |` A |` B = r |` B |` A"
by(blast intro!: ext)

lemma restrictP_subsume1:
  fixes r :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  assumes "A \<subseteq> B"
  shows "r |` A |` B = r |` A"
using assms by(blast intro!: ext)

lemma restrictP_subsume2:
  fixes r :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  assumes "B \<subseteq> A"
  shows "r |` A |` B = r |` B"
using assms by(blast intro!: ext)

lemma restrictP_idem [simp]:
  fixes r :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  shows "r |` A |` A = r |` A"
by(simp add: restrictP_subsume1)

section {* Order extensions *}

text {* Every partial order can be extended to a total order *}

lemma porder_extend_to_torder:
  assumes r: "porder_on A r"
  obtains s where "torder_on A s" "order_consistent r s"
proof(atomize_elim)
  def S \<equiv> "{s. porder_on A (\<lambda>x y. (x, y) \<in> s) \<and> (\<forall>x y. r x y \<longrightarrow> (x, y) \<in> s)}"
  from r have r_in_S: "{(x, y). r x y} \<in> S" unfolding S_def by auto

  have "\<exists>y\<in>S. \<forall>x\<in>S. y \<subseteq> x \<longrightarrow> y = x"
  proof(rule Zorn_Lemma2[rule_format])
    fix c
    assume "c \<in> chain S"
    hence "c \<subseteq> S" by(rule chainD2)

    show "\<exists>y\<in>S. \<forall>x\<in>c. x \<subseteq> y"
    proof(cases "c = {}")
      case True
      with r_in_S show ?thesis by blast
    next
      case False
      then obtain s where "s \<in> c" by blast
      hence s: "porder_on A (\<lambda>x y. (x, y) \<in> s)"
        and r_in_s: "\<And>x y. r x y \<Longrightarrow> (x, y) \<in> s"
        using `c \<subseteq> S` unfolding S_def by blast+

      have "porder_on A (\<lambda>x y. (x, y) \<in> \<Union>c)"
      proof(rule porder_onI)
        show "refl_onP A (\<lambda>x y. (x, y) \<in> \<Union>c)"
        proof(rule refl_onPI)
          fix a a'
          assume "(a, a') \<in> \<Union>c"
          then obtain X where "X \<in> c" and "(a, a') \<in> X" by blast
          from `X \<in> c` `c \<subseteq> S` have "X \<in> S" ..
          hence "porder_on A (\<lambda>x y. (x, y) \<in> X)" unfolding S_def by simp
          with `(a, a') \<in> X` show "a \<in> A \<and> a' \<in> A"
            by(blast elim: porder_onE dest: refl_onPD1 refl_onPD2)
        next
          fix a
          assume "a \<in> A"
          with s have "(a, a) \<in> s"
            by(blast elim: porder_onE dest: refl_onPD)
          with `s \<in> c` show "(a, a) \<in> \<Union>c" by(rule UnionI)
        qed

        show "antisymP (\<lambda>x y. (x, y) \<in> \<Union>c)"
        proof(rule antisymPI)
          fix x y
          assume "(x, y) \<in> \<Union>c" "(y, x) \<in> \<Union>c"
          then obtain X Y where "X \<in> c" "Y \<in> c" "(x, y) \<in> X" "(y, x) \<in> Y" by blast
          from `X \<in> c` `Y \<in> c` `c \<subseteq> S` have "antisym X" "antisym Y"
            unfolding S_def by(auto elim!: porder_onE)
          moreover from `c \<in> chain S` `X \<in> c` `Y \<in> c` 
          have "X \<subseteq> Y \<or> Y \<subseteq> X" by(rule chainD)
          ultimately show "x = y" using `(x, y) \<in> X` `(y, x) \<in> Y` 
            by(auto dest: antisymD)
        qed

        show "transP (\<lambda>x y. (x, y) \<in> \<Union>c)"
        proof(rule transPI)
          fix x y z
          assume "(x, y) \<in> \<Union>c" "(y, z) \<in> \<Union>c"
          then obtain X Y where "X \<in> c" "Y \<in> c" "(x, y) \<in> X" "(y, z) \<in> Y" by blast
          from `X \<in> c` `Y \<in> c` `c \<subseteq> S` have "trans X" "trans Y"
            unfolding S_def by(auto elim!: porder_onE)
          from `c \<in> chain S` `X \<in> c` `Y \<in> c` 
          have "X \<subseteq> Y \<or> Y \<subseteq> X" by(rule chainD)
          thus "(x, z) \<in> \<Union>c"
          proof
            assume "X \<subseteq> Y"
            with `trans Y` `(x, y) \<in> X` `(y, z) \<in> Y`
            have "(x, z) \<in> Y" by(blast dest: transD)
            with `Y \<in> c` show ?thesis by(rule UnionI)
          next
            assume "Y \<subseteq> X"
            with `trans X` `(x, y) \<in> X` `(y, z) \<in> Y`
            have "(x, z) \<in> X" by(blast dest: transD)
            with `X \<in> c` show ?thesis by(rule UnionI)
          qed
        qed
      qed
      moreover {
        fix x y
        assume "r x y"
        hence "(x, y) \<in> s" by(rule r_in_s)
        with `s \<in> c` have "(x, y) \<in> \<Union>c" by(rule UnionI) }
      ultimately have "\<Union>c \<in> S" unfolding S_def by simp
      thus ?thesis by blast
    qed
  qed
  then obtain s where "s \<in> S" and y_max: "\<And>t. \<lbrakk> t \<in> S; s \<subseteq> t \<rbrakk> \<Longrightarrow> s = t" by blast

  have "porder_on A (\<lambda>x y. (x, y) \<in> s)" using `s \<in> S`
    unfolding S_def by simp
  moreover
  { fix x y
    assume "r x y"
    hence "(x, y) \<in> s" using `s \<in> S` unfolding S_def by blast }
  note r_in_s = this

  have "total_onP A (\<lambda>x y. (x, y) \<in> s)"
  proof(rule total_onPI)
    fix x y
    assume "x \<in> A" "y \<in> A" 
    show "(x, y) \<in> s \<or> x = y \<or> (y, x) \<in> s"
    proof(rule ccontr)
      assume "\<not> ?thesis"
      hence xy: "(x, y) \<notin> s" "(y, x) \<notin> s" "x \<noteq> y" by simp_all

      def s' \<equiv> "\<lambda>a b. a = x \<and> (b = y \<or> b = x) \<or> a = y \<and> b = y"
      let ?s' = "(\<lambda>a b. (a, b) \<in> s \<or> s' a b)^++"
      note `porder_on A (\<lambda>x y. (x, y) \<in> s)`
      moreover have "torder_on {x, y} s'" unfolding s'_def
        by(blast intro: torder_onI porder_onI refl_onPI antisymPI transPI total_onPI)
      moreover have "order_consistent (\<lambda>x y. (x, y) \<in> s) s'"
        unfolding s'_def using xy by(blast intro: order_consistentI)
      moreover have "{x, y} \<subseteq> A" using `x \<in> A` `y \<in> A` by blast
      ultimately have "porder_on A ?s'"
        by(rule porder_on_torder_on_tranclp_porder_onI)
      moreover {
        fix x y
        assume "r x y"
        hence "(x, y) \<in> s" by(rule r_in_s)
        hence "?s' x y"
          by(blast intro: tranclp.r_into_trancl) }
      ultimately have "{(a, b). ?s' a b} \<in> S"
        unfolding S_def by simp
      moreover have "s \<subseteq> {(a, b). ?s' a b}" by auto
      ultimately have "s = {(a, b). ?s' a b}" by(rule y_max)
      moreover have "(x, y) \<in> {(a, b). ?s' a b}"
        by(auto simp add: s'_def)
      ultimately show False using `(x, y) \<notin> s` by simp
    qed
  qed
  ultimately have "torder_on A (\<lambda>x y. (x, y) \<in> s)" by(rule torder_onI)
  moreover have "order_consistent r (\<lambda>x y. (x, y) \<in> s)"
  proof(rule order_consistentI)
    fix a a'
    assume "r a a'" "(a', a) \<in> s"
    from `r a a'` have "(a, a') \<in> s" by(rule r_in_s)
    with `porder_on A (\<lambda>x y. (x, y) \<in> s)` `(a', a) \<in> s`
    show "a = a'" by(blast elim: porder_onE dest: antisymPD)
  qed
  ultimately show "\<exists>s. torder_on A s \<and> order_consistent r s" by blast
qed

subsection {* Maximal elements w.r.t. a total order *}

definition max_torder :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a"
where "max_torder r a b = (if DomainP r a \<and> DomainP r b then if r a b then b else a else SOME a. \<not> DomainP r a)"

definition Max_torder :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a set \<Rightarrow> 'a"
where "Max_torder r = fold1 (max_torder r)"

lemma refl_on_DomainD: "refl_on A r \<Longrightarrow> A = Domain r"
by(auto simp add: Domain_unfold dest: refl_onD refl_onD1)

lemma refl_onP_DomainPD: "refl_onP A r \<Longrightarrow> A = {a. DomainP r a}"
by(drule refl_on_DomainD) auto

lemma ab_semigroup_mult_max_torder:
  assumes tot: "torder_on A r"
  shows "class.ab_semigroup_mult (max_torder r)"
proof -
  from tot have as: "antisymP r" 
    and to: "total_onP A r" 
    and trans: "transP r"
    and refl: "refl_onP A r" 
    by(auto elim: torder_onE porder_onE)
  from refl have "{a. DomainP r a} = A" by (rule refl_onP_DomainPD[symmetric])
  from this [symmetric] have "domain": "\<And>a. DomainP r a \<longleftrightarrow> a \<in> A" by simp
  show ?thesis
  proof(unfold_locales)
    fix x y z
    show "max_torder r (max_torder r x y) z = max_torder r x (max_torder r y z)"
      unfolding max_torder_def "domain" apply auto
      apply (blast dest: total_onPD[OF to] transPD[OF trans] antisymPD[OF as] refl_onPD1[OF refl] refl_onPD2[OF refl] someI[where P="\<lambda>a. a \<notin> A"])+
      done
  next
    fix x y
    show "max_torder r x y = max_torder r y x"
      by(auto simp add: max_torder_def "domain" dest: total_onPD[OF to] antisymPD[OF as])
  qed
qed

lemma comp_fun_commute_max_torder:
  assumes tot: "torder_on A r"
  shows "comp_fun_commute (max_torder r)"
by(rule ab_semigroup_mult.comp_fun_commute)(rule ab_semigroup_mult_max_torder[OF tot])

lemma max_torder_ge_conv_disj:
  assumes tot: "torder_on A r" and x: "x \<in> A" and y: "y \<in> A"
  shows "r z (max_torder r x y) \<longleftrightarrow> r z x \<or> r z y"
proof -
  from tot have as: "antisymP r" 
    and to: "total_onP A r" 
    and trans: "transP r"
    and refl: "refl_onP A r" 
    by(auto elim: torder_onE porder_onE)
  from refl have "{a. DomainP r a} = A" by (rule refl_onP_DomainPD[symmetric])
  from this [symmetric] have "domain": "\<And>a. DomainP r a \<longleftrightarrow> a \<in> A" by simp
  show ?thesis using x y
    by(simp add: max_torder_def "domain")(blast dest: total_onPD[OF to] transPD[OF trans])
qed

lemma Max_torder_in_Domain:
  assumes tot: "torder_on A r"
  and B: "finite B" "B \<noteq> {}" "B \<subseteq> A"
  shows "Max_torder r B \<in> A"
proof -
  interpret ab_semigroup_mult "max_torder r"
    using tot by (rule ab_semigroup_mult_max_torder)
  from tot have "{a. DomainP r a} = A" by(auto elim: torder_onE porder_onE dest: refl_onP_DomainPD[symmetric])
  from this [symmetric] have "domain": "\<And>a. DomainP r a \<longleftrightarrow> a \<in> A" by simp
  show ?thesis unfolding Max_torder_def using B
    by(induct rule: finite_ne_induct)(simp_all add: fold1_insert max_torder_def "domain")
qed

lemma Max_torder_in_set:
  assumes tot: "torder_on A r"
  and B: "finite B" "B \<noteq> {}" "B \<subseteq> A"
  shows "Max_torder r B \<in> B"
proof -
  interpret ab_semigroup_mult "max_torder r"
    using tot by (rule ab_semigroup_mult_max_torder)
  from tot have "{a. DomainP r a} = A" by(auto elim: torder_onE porder_onE dest: refl_onP_DomainPD[symmetric])
  from this [symmetric] have "domain": "\<And>a. DomainP r a \<longleftrightarrow> a \<in> A" by simp
  show ?thesis unfolding Max_torder_def using B
    by(induct rule: finite_ne_induct)(simp_all add: fold1_insert max_torder_def "domain" Max_torder_in_Domain[OF tot, unfolded Max_torder_def])
qed

lemma Max_torder_above_iff:
  assumes tot: "torder_on A r"
  and B: "finite B" "B \<noteq> {}" "B \<subseteq> A"
  shows "r x (Max_torder r B) \<longleftrightarrow> (\<exists>a\<in>B. r x a)"
proof -
  interpret ab_semigroup_mult "max_torder r"
    using tot by (rule ab_semigroup_mult_max_torder)
  from B show ?thesis unfolding Max_torder_def
    by(induct rule: finite_ne_induct)(simp_all add: fold1_insert max_torder_ge_conv_disj[OF tot] Max_torder_in_Domain[unfolded Max_torder_def, OF tot])
qed

lemma Max_torder_above:
  assumes tot: "torder_on A r"
  and "finite B" "a \<in> B" "B \<subseteq> A"
  shows "r a (Max_torder r B)"
proof -
  from tot have refl: "refl_onP A r" by(auto elim: torder_onE porder_onE)
  with `a \<in> B` `B \<subseteq> A` have "r a a" by(blast dest: refl_onPD[OF refl])
  from `a \<in> B` have "B \<noteq> {}" by auto
  from Max_torder_above_iff[OF tot `finite B` this `B \<subseteq> A`, of a] `r a a` `a \<in> B`
  show ?thesis by blast
qed

lemma inv_imageP_id [simp]: "inv_imageP R id = R"
by(simp add: fun_eq_iff)

lemma inv_into_id [simp]: "a \<in> A \<Longrightarrow> inv_into A id a = a"
by (metis f_inv_into_f id_apply image_id)

end
