(*  Title:       Miscellaneous Definitions and Lemmas
    Author:      Peter Lammich <peter.lammich@uni-muenster.de>
    Maintainer:  Peter Lammich <peter.lammich@uni-muenster.de>
                 Thomas Tuerk <tuerk@in.tum.de>
*)

(*
  CHANGELOG:
    2010-05-09: Removed AC, AI locales, they are superseeded by concepts 
                  from OrderedGroups
    2010-09-22: Merges with ext/Aux

*)

header {* Miscellaneous Definitions and Lemmas *}

theory Misc
imports Main "~~/src/HOL/Library/Multiset" "~~/src/HOL/ex/Quicksort"
begin
text_raw {*\label{thy:Misc}*}

text {* Here we provide a collection of miscellaneous definitions and helper lemmas *}

subsection "Miscellaneous (1)"
text {* This stuff is used in this theory itself, and thus occurs in first place or is simply not sorted into any other section of this theory. *}
subsubsection "AC-operators"
  
text {* Locale to declare AC-laws as simplification rules *}
locale Assoc =
  fixes f
  assumes assoc[simp]: "f (f x y) z = f x (f y z)"

locale AC = Assoc +
  assumes commute[simp]: "f x y = f y x"

lemma (in AC) left_commute[simp]: "f x (f y z) = f y (f x z)"
  by (simp only: assoc[symmetric]) simp

lemmas (in AC) AC_simps = commute assoc left_commute

text {* Locale to define functions from surjective, unique relations *}
locale su_rel_fun =
  fixes F and f
  assumes unique: "\<lbrakk>(A,B)\<in>F; (A,B')\<in>F\<rbrakk> \<Longrightarrow> B=B'"
  assumes surjective: "\<lbrakk>!!B. (A,B)\<in>F \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  assumes f_def: "f A == THE B. (A,B)\<in>F"

lemma (in su_rel_fun) repr1: "(A,f A)\<in>F" proof (unfold f_def)
  obtain B where "(A,B)\<in>F" by (rule surjective)
  with theI[where P="\<lambda>B. (A,B)\<in>F", OF this] show "(A, THE x. (A, x) \<in> F) \<in> F" by (blast intro: unique)
qed
  
lemma (in su_rel_fun) repr2: "(A,B)\<in>F \<Longrightarrow> B=f A" using repr1
  by (blast intro: unique)

lemma (in su_rel_fun) repr: "(f A = B) = ((A,B)\<in>F)" using repr1 repr2
  by (blast) 


lemma set_pair_flt_false[simp]: "{ (a,b). False } = {}"
  by simp

    -- "Contract quantification over two variables to pair"
lemma Ex_prod_contract: "(\<exists>a b. P a b) \<longleftrightarrow> (\<exists>z. P (fst z) (snd z))"
  by auto

lemma All_prod_contract: "(\<forall>a b. P a b) \<longleftrightarrow> (\<forall>z. P (fst z) (snd z))"
  by auto


lemma nat_geq_1_eq_neqz: "x\<ge>1 \<longleftrightarrow> x\<noteq>(0::nat)"
  by auto

lemma if_not_swap[simp]: "(if \<not>c then a else b) = (if c then b else a)" by auto 


subsection {* Sets *}

  lemma subset_minus_empty: "A\<subseteq>B \<Longrightarrow> A-B = {}" by auto

  lemma set_notEmptyE: "\<lbrakk>S\<noteq>{}; !!x. x\<in>S \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (metis equals0I)

  lemma setsum_subset_split: assumes P: "finite A" "B\<subseteq>A" shows T: "setsum f A = setsum f (A-B) + setsum f B" proof -
    from P have 1: "A = (A-B) \<union> B" by auto
    have 2: "(A-B) \<inter> B = {}" by auto
    from P have 3: "finite B" by (blast intro: finite_subset)
    from P have 4: "finite (A-B)" by simp
    from 2 3 4 setsum_Un_disjoint have "setsum f ((A-B) \<union> B) = setsum f (A-B) + setsum f B" by blast
    with 1 show ?thesis by simp
  qed


  lemma disjoint_mono: "\<lbrakk> a\<subseteq>a'; b\<subseteq>b'; a'\<inter>b'={} \<rbrakk> \<Longrightarrow> a\<inter>b={}" by auto

  lemma disjoint_alt_simp1: "A-B = A \<longleftrightarrow> A\<inter>B = {}" by auto
  lemma disjoint_alt_simp2: "A-B \<noteq> A \<longleftrightarrow> A\<inter>B \<noteq> {}" by auto
  lemma disjoint_alt_simp3: "A-B \<subset> A \<longleftrightarrow> A\<inter>B \<noteq> {}" by auto

  lemmas set_simps = subset_minus_empty disjoint_alt_simp1 disjoint_alt_simp2 disjoint_alt_simp3 Un_absorb1 Un_absorb2

  lemma set_minus_singleton_eq: "x\<notin>X \<Longrightarrow> X-{x} = X" 
    by auto

  lemma set_diff_diff_left: "A-B-C = A-(B\<union>C)"
    by auto


  lemma image_update[simp]: "x\<notin>A \<Longrightarrow> f(x:=n)`A = f`A"
    by auto

  lemma set_union_code [code_unfold]:
    "set xs \<union> set ys = set (xs @ ys)"
    by auto

  subsubsection {* Finite Sets *}

  lemma card_1_singletonI: "\<lbrakk>finite S; card S = 1; x\<in>S\<rbrakk> \<Longrightarrow> S={x}"
  proof (safe, rule ccontr)
    case (goal1 x')
    hence "finite (S-{x})" "S-{x} \<noteq> {}" by auto
    hence "card (S-{x}) \<noteq> 0" by auto
    moreover from goal1(1-3) have "card (S-{x}) = 0" by auto
    ultimately have False by simp
    thus ?case ..
  qed

  lemma card_insert_disjoint': "\<lbrakk>finite A; x \<notin> A\<rbrakk> \<Longrightarrow> card (insert x A) - Suc 0 = card A"
    by (drule (1) card_insert_disjoint) auto

  lemma card_eq_UNIV[simp]: "card (S::'a::finite set) = card (UNIV::'a set) \<longleftrightarrow> S=UNIV"
  proof (auto)
    fix x
    assume A: "card S = card (UNIV::'a set)"
    show "x\<in>S" proof (rule ccontr)
      assume "x\<notin>S" hence "S\<subset>UNIV" by auto
      with psubset_card_mono[of UNIV S] have "card S < card (UNIV::'a set)" by auto
      with A show False by simp
    qed
  qed
      
  lemma card_eq_UNIV2[simp]: "card (UNIV::'a set) = card (S::'a::finite set) \<longleftrightarrow> S=UNIV"
    using card_eq_UNIV[of S] by metis

  lemma card_ge_UNIV[simp]: "card (UNIV::'a::finite set) \<le> card (S::'a set) \<longleftrightarrow> S=UNIV"
    using card_mono[of "UNIV::'a::finite set" S, simplified]
    by auto
  
  lemmas length_remdups_card = length_remdups_concat[of "[l]", simplified] for l



  lemma fs_contract: "fst ` { p | p. f (fst p) (snd p) \<in> S } = { a . \<exists>b. f a b \<in> S }"
    by (simp add: image_Collect)

    (* Nice lemma thanks to Andreas Lochbihler *)
  lemma finite_Collect:
    assumes fin: "finite S" and inj: "inj f"
    shows "finite {a. f a : S}"
  proof -
    def S' == "S \<inter> range f"
    hence "{a. f a : S} = {a. f a : S'}" by auto
    also have "... = (inv f) ` S'"
    proof
      show "{a. f a : S'} <= inv f ` S'"
        using inj by(force intro: image_eqI)
      show "inv f ` S' <= {a. f a : S'}"
      proof
        fix x
        assume "x : inv f ` S'"
        then obtain y where "y : S'" "x = inv f y" by blast
        moreover from `y : S'` obtain x' where "f x' = y"
          unfolding S'_def by blast
        hence "f (inv f y) = y" unfolding inv_def by(rule someI)
        ultimately show "x : {a. f a : S'}" by simp
      qed
    qed
    also have "finite S'" using fin unfolding S'_def by blast
    ultimately show ?thesis by simp
  qed 

  -- "Finite sets have an injective mapping to an initial segments of the 
      natural numbers"
  (* This lemma is also in the standard library (from Isabelle2009-1 on) 
      as @{thm [source] Finite_Set.finite_imp_inj_to_nat_seg}. However, it is formulated with HOL's 
      \<exists> there rather then with the meta-logic obtain *)
  lemma finite_imp_inj_to_nat_seg':
    fixes A :: "'a set"
    assumes A: "finite A"
    obtains f::"'a \<Rightarrow> nat" and n::"nat" where
      "f`A = {i. i<n}"
      "inj_on f A"
    by (metis A finite_imp_inj_to_nat_seg)

  lemma lists_of_len_fin1: "finite P \<Longrightarrow> finite (lists P \<inter> { l. length l = n })"
  proof (induct n)
    case 0 thus ?case by auto
  next
    case (Suc n)
    have "lists P \<inter> { l. length l = Suc n } 
          = (\<lambda>(a,l). a#l) ` (P \<times> (lists P \<inter> {l. length l = n}))"
      apply auto
      apply (case_tac x)
      apply auto
      done
    moreover from Suc have "finite \<dots>" by auto
    ultimately show ?case by simp
  qed

  lemma lists_of_len_fin2: "finite P \<Longrightarrow> finite (lists P \<inter> { l. n = length l })"
  proof -
    assume A: "finite P"
    have S: "{ l. n = length l } = { l. length l = n }" by auto
    have "finite (lists P \<inter> { l. n = length l }) 
      \<longleftrightarrow> finite (lists P \<inter> { l. length l = n })" 
      by (subst S) simp
    
    thus ?thesis using lists_of_len_fin1[OF A] by auto
  qed

  lemmas lists_of_len_fin = lists_of_len_fin1 lists_of_len_fin2


  (* Try (simp only: cset_fin_simps, fastforce intro: cset_fin_intros) when reasoning about finiteness of collected sets *)
  lemmas cset_fin_simps = Ex_prod_contract fs_contract[symmetric] image_Collect[symmetric]
  lemmas cset_fin_intros = finite_imageI finite_Collect inj_onI









subsection {* Functions *}

definition "inv_on f A x == SOME y. y\<in>A \<and> f y = x"

lemma inv_on_f_f[simp]: "\<lbrakk>inj_on f A; x\<in>A\<rbrakk> \<Longrightarrow> inv_on f A (f x) = x"
  by (auto simp add: inv_on_def inj_on_def)

lemma f_inv_on_f: "\<lbrakk> y\<in>f`A \<rbrakk> \<Longrightarrow> f (inv_on f A y) = y"
  by (auto simp add: inv_on_def intro: someI2)

lemma inv_on_f_range: "\<lbrakk> y \<in> f`A \<rbrakk> \<Longrightarrow> inv_on f A y \<in> A"
  by (auto simp add: inv_on_def intro: someI2)

lemma inj_on_map_inv_f [simp]: "\<lbrakk>set l \<subseteq> A; inj_on f A\<rbrakk> \<Longrightarrow> map (inv_on f A) (map f l) = l"
  apply (simp)
  apply (induct l)
  apply auto
  done


subsection {* Multisets *}

(*
  The following is a syntax extension for multisets. Unfortunately, it depends on a change in the Library/Multiset.thy, so it is commented out here, until it will be incorporated 
  into Library/Multiset.thy by its maintainers.

  The required change in Library/Multiset.thy is removing the syntax for single:
     - single :: "'a => 'a multiset"    ("{#_#}")
     + single :: "'a => 'a multiset"

  And adding the following translations instead:
  
     + syntax
     + "_multiset" :: "args \<Rightarrow> 'a multiset" ("{#(_)#}")

     + translations
     +   "{#x, xs#}" == "{#x#} + {#xs#}" 
     +   "{# x #}" == "single x"

  This translates "{# \<dots> #}" into a sum of singletons, that is parenthesized to the right. ?? Can we also achieve left-parenthesizing ??

*)


  (* Let's try what happens if declaring AC-rules for multiset union as simp-rules *)
(*declare union_ac[simp] -- don't do it !*)

subsubsection {* Case distinction *}
text {* Install a (new) default case-distinction lemma for multisets, that distinguishes between empty multiset and multiset that is the union of of some multiset and a singleton multiset. 
  This is the same case distinction as done by the @{thm [source] multiset_induct} rule that is installed as default induction rule for multisets by Multiset.thy. *}
lemma mset_cases[case_names empty add, cases type: multiset]: "\<lbrakk> M={#} \<Longrightarrow> P; !!x M'. M=M'+{#x#} \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  apply (induct M)
  apply auto
done

lemma multiset_induct'[case_names empty add]: "\<lbrakk>P {#}; \<And>M x. P M \<Longrightarrow> P ({#x#}+M)\<rbrakk> \<Longrightarrow> P M"
  by (induct rule: multiset_induct) (auto simp add: union_commute)

lemma mset_cases'[case_names empty add]: "\<lbrakk> M={#} \<Longrightarrow> P; !!x M'. M={#x#}+M' \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  apply (induct M rule: multiset_induct')
  apply auto
done
  
subsubsection {* Count *}
        lemma count_ne_remove: "\<lbrakk> x ~= t\<rbrakk> \<Longrightarrow> count S x = count (S-{#t#}) x"
          by (auto)
  lemma mset_empty_count[simp]: "(\<forall>p. count M p = 0) = (M={#})"
    by (auto simp add: multiset_eq_iff)

subsubsection {* Union, difference and intersection *}

  lemma size_diff_se: "\<lbrakk>t :# S\<rbrakk> \<Longrightarrow> size S = size (S - {#t#}) + 1" proof (unfold size_def)
                let ?SIZE = "setsum (count S) (set_of S)"
                assume A: "t :# S"
                from A have SPLITPRE: "finite (set_of S) & {t}\<subseteq>(set_of S)" by auto
                hence "?SIZE = setsum (count S) (set_of S - {t}) + setsum (count S) {t}" by (blast dest: setsum_subset_split)
                hence "?SIZE = setsum (count S) (set_of S - {t}) + count (S) t" by auto
                moreover with A have "count S t = count (S-{#t#}) t + 1" by auto
                ultimately have D: "?SIZE = setsum (count S) (set_of S - {t}) + count (S-{#t#}) t + 1" by (arith)
                moreover have "setsum (count S) (set_of S - {t}) = setsum (count (S-{#t#})) (set_of S - {t})" proof -
                        have "ALL x:(set_of S - {t}) . count S x = count (S-{#t#}) x" by (auto iff add: count_ne_remove)
                        thus ?thesis by simp
                qed
                ultimately have D: "?SIZE = setsum (count (S-{#t#})) (set_of S - {t}) + count (S-{#t#}) t + 1" by (simp)
                moreover
                { assume CASE: "count (S-{#t#}) t = 0"
                        from CASE have "set_of S - {t} = set_of (S-{#t#})" by (auto iff add: set_of_def)
                        with CASE D have "?SIZE = setsum (count (S-{#t#})) (set_of (S - {#t#})) + 1" by simp
                }
                moreover
                { assume CASE: "count (S-{#t#}) t ~= 0"
                        from CASE have 1: "set_of S = set_of (S-{#t#})" by (auto iff add: set_of_def)
                        moreover from D have "?SIZE = setsum (count (S-{#t#})) (set_of S - {t}) + setsum (count (S-{#t#})) {t} + 1" by simp
                        moreover from SPLITPRE setsum_subset_split have "setsum (count (S-{#t#})) (set_of S) = setsum (count (S-{#t#})) (set_of S - {t}) + setsum (count (S-{#t#})) {t}" by (blast)
                        ultimately have "?SIZE = setsum (count (S-{#t#})) (set_of (S-{#t#})) + 1" by simp
                }
                ultimately show "?SIZE = setsum (count (S-{#t#})) (set_of (S - {#t#})) + 1" by blast
        qed

  (* TODO: Check whether this proof can be done simpler *)
  lemma mset_union_diff_comm: "t :# S \<Longrightarrow> T + (S - {#t#}) = (T + S) - {#t#}" proof -
    assume "t :# S"
    hence "count S t = count (S-{#t#}) t + 1" by auto
    hence "count (S+T) t = count (S-{#t#}+T) t + 1" by auto
    hence "count (S+T-{#t#}) t = count (S-{#t#}+T) t" by (simp)
    moreover have "ALL x. x~=t \<longrightarrow> count (S+T-{#t#}) x = count (S-{#t#}+T) x" by auto
    ultimately show ?thesis by (auto simp add: union_ac iff add: multiset_eq_iff)
  qed

  lemma mset_diff_union_cancel[simp]: "t :# S \<Longrightarrow> (S - {#t#}) + {#t#} = S"
    by (auto simp add: mset_union_diff_comm union_ac)

(*  lemma mset_diff_diff_left: "A-B-C = A-((B::'a multiset)+C)" proof -
    have "ALL e . count (A-B-C) e = count (A-(B+C)) e" by auto
    thus ?thesis by (simp add: multiset_eq_conv_count_eq)
  qed

  lemma mset_diff_commute: "A-B-C = A-C-(B::'a multiset)" proof -
    have "A-B-C = A-(B+C)" by (simp add: mset_diff_diff_left)
    also have "\<dots> = A-(C+B)" by (simp add: union_commute)
    thus ?thesis by (simp add: mset_diff_diff_left)
  qed

  lemma mset_diff_same_empty[simp]: "(S::'a multiset) - S = {#}"
  proof -
    have "ALL e . count (S-S) e = 0" by auto
    hence "ALL e . ~ (e : set_of (S-S))" by auto
    hence "set_of (S-S) = {}" by blast
    thus ?thesis by (auto)
  qed
*)
  lemma mset_right_cancel_union: "\<lbrakk>a :# A+B; ~(a :# B)\<rbrakk> \<Longrightarrow> a:#A"
    by (simp)
  lemma mset_left_cancel_union: "\<lbrakk>a :# A+B; ~(a :# A)\<rbrakk> \<Longrightarrow> a:#B"
    by (simp)
  
  lemmas mset_cancel_union = mset_right_cancel_union mset_left_cancel_union

  lemma mset_right_cancel_elem: "\<lbrakk>a :# A+{#b#}; a~=b\<rbrakk> \<Longrightarrow> a:#A"
    apply(subgoal_tac "~(a :# {#b#})")
    apply(auto)
  done

  lemma mset_left_cancel_elem: "\<lbrakk>a :# {#b#}+A; a~=b\<rbrakk> \<Longrightarrow> a:#A"
    apply(subgoal_tac "~(a :# {#b#})")
    apply(auto)
  done

  lemmas mset_cancel_elem = mset_right_cancel_elem mset_left_cancel_elem

  lemma mset_diff_cancel1elem[simp]: "~(a :# B) \<Longrightarrow> {#a#}-B = {#a#}" proof -
    assume A: "~(a :# B)"
    hence "count ({#a#}-B) a = count ({#a#}) a" by auto
    moreover have "ALL e . e~=a \<longrightarrow> count ({#a#}-B) e = count ({#a#}) e" by auto
    ultimately show ?thesis by (auto simp add: multiset_eq_iff)
  qed

(*  lemma diff_union_inverse[simp]: "A + B - B = (A::'a multiset)"
    by (auto iff add: multiset_eq_conv_count_eq)

  lemma diff_union_inverse2[simp]: "B + A - B = (A::'a multiset)"
    by (auto iff add: multiset_eq_conv_count_eq)
*)
        lemma union_diff_assoc_se: "t :# B \<Longrightarrow> (A+B)-{#t#} = A + (B-{#t#})"
          by (auto iff add: multiset_eq_iff)
  (*lemma union_diff_assoc_se2: "t :# A \<Longrightarrow> (A+B)-{#t#} = (A-{#t#}) + B"
    by (auto iff add: multiset_eq_conv_count_eq)
  lemmas union_diff_assoc_se = union_diff_assoc_se1 union_diff_assoc_se2*)

        lemma union_diff_assoc: "C-B={#} \<Longrightarrow> (A+B)-C = A + (B-C)"
          by (simp add: multiset_eq_iff)

  lemma mset_union_1_elem1[simp]: "({#a#} = M+{#b#}) = (a=b & M={#})" proof
    assume A: "{#a#} = M+{#b#}"
    from A have "size {#a#} = size (M+{#b#})" by simp
    hence "1 = 1 + size M" by auto
    hence "M={#}" by auto
    moreover with A have "a=b" by auto
    ultimately show "a=b & M={#}" by auto
  next
    assume "a = b \<and> M = {#}"
    thus "{#a#} = M+{#b#}" by auto
  qed

  lemma mset_union_1_elem2[simp]: "({#a#} = {#b#}+M) = (a=b & M={#})" using mset_union_1_elem1
    by (simp add: union_ac)

  lemma mset_union_1_elem3[simp]: "(M+{#b#}={#a#}) = (b=a & M={#})" using mset_union_1_elem1
    by (auto dest: sym)

  lemma mset_union_1_elem4[simp]: "({#b#}+M={#a#}) = (b=a & M={#})" using mset_union_1_elem3
    by (simp add: union_ac)

  lemma mset_inter_1elem1[simp]: assumes A: "~(a :# B)" shows "{#a#} #\<inter> B = {#}" proof (unfold multiset_inter_def)
    from A have "{#a#} - B = {#a#}" by simp
    thus "{#a#} - ({#a#} - B) = {#}" by simp
  qed

  lemma mset_inter_1elem2[simp]: "~(a :# B) \<Longrightarrow> B #\<inter> {#a#} = {#}" proof -
    assume "~(a :# B)"
    hence "{#a#} #\<inter> B = {#}" by simp
    thus ?thesis by (simp add: multiset_inter_commute)
  qed

  lemmas mset_inter_1elem = mset_inter_1elem1 mset_inter_1elem2


  lemmas mset_neutral_cancel1 = union_left_cancel[where N="{#}", simplified] union_right_cancel[where N="{#}", simplified]
  declare mset_neutral_cancel1[simp]

  lemma mset_neutral_cancel2[simp]: "(c=n+c) = (n={#})" "(c=c+n) = (n={#})"
    apply (auto simp add: union_ac)
    apply (subgoal_tac "c+n=c", simp_all)+
    done



  (* TODO: The proof seems too complicated, there should be an easier one ! *)
  lemma mset_union_2_elem: "{#a#}+{#b#} = M + {#c#} \<Longrightarrow> {#a#}=M & b=c | a=c & {#b#}=M" 
  proof -
    assume A: "{#a#}+{#b#} = M + {#c#}"
    hence "{#a#}+{#b#}-{#b#} = M + {#c#} - {#b#}" by auto
    hence AEQ: "{#a#} = M + {#c#} - {#b#}" by (auto simp add: union_assoc)
    { assume "c=b"
      with AEQ have "{#a#} = M" by auto  
    } moreover {
      from A have "{#b#}+{#a#} = M + {#c#}" by (auto simp add: union_commute)
      moreover assume "a=c"
      ultimately have "{#b#} = M" by auto
    } moreover {
      assume NEQ: "c~=b & a~=c"
      from A have "{#a#}+{#b#}-{#c#} = M + {#c#}-{#c#}" by auto
      hence "{#a#}+{#b#}-{#c#} = M" by (auto simp add: union_assoc)
      with NEQ have "{#a#}-{#c#}+{#b#} = M" by (subgoal_tac "~ (c :# {#b#})", auto simp add: mset_inter_1elem multiset_union_diff_commute)
      with NEQ have "{#a#}+{#b#} = M" by (subgoal_tac "~(a :# {#c#})", auto simp add: mset_diff_cancel1elem)
      hence S1: "size M = 2" by auto
      moreover from A have "size ({#a#}+{#b#}) = size (M + {#c#})" by auto
      hence "size M = 1" by auto
      ultimately have "False" by simp
    }
    ultimately show ?thesis by blast
  qed

  lemma mset_diff_union_s_inverse[simp]: "s :# S \<Longrightarrow> {#s#} + (S - {# s #}) = S" proof -
    assume "s :# S"
    hence "S = S - {#s#} + {#s#}" by (auto simp add: mset_union_diff_comm)
    thus ?thesis by (auto simp add: union_ac)
  qed

  lemma mset_un_iff: "(a :# A + B) = (a :# A | a :# B)"
    by (simp)
  lemma mset_un_cases[cases set, case_names left right]: "\<lbrakk>a :# A + B; a:#A \<Longrightarrow> P; a:#B \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (auto)

  lemma mset_unplusm_dist_cases[cases set, case_names left right]:
    assumes A: "{#s#}+A = B+C"
    assumes L: "\<lbrakk>B={#s#}+(B-{#s#}); A=(B-{#s#})+C\<rbrakk> \<Longrightarrow> P"
    assumes R: "\<lbrakk>C={#s#}+(C-{#s#}); A=B+(C-{#s#})\<rbrakk> \<Longrightarrow> P" 
    shows P
  proof -
    from A[symmetric] have "s :# B+C" by simp
    thus ?thesis proof (cases rule: mset_un_cases)
      case left hence 1: "B={#s#}+(B-{#s#})" by simp
      with A have "{#s#}+A = {#s#}+((B-{#s#})+C)" by (simp add: union_ac)
      hence 2: "A = (B-{#s#})+C" by (simp)
      from L[OF 1 2] show ?thesis .
    next
      case right hence 1: "C={#s#}+(C-{#s#})" by simp
      with A have "{#s#}+A = {#s#}+(B+(C-{#s#}))" by (simp add: union_ac)
      hence 2: "A = B+(C-{#s#})" by (simp)
      from R[OF 1 2] show ?thesis .
    qed
  qed

  lemma mset_unplusm_dist_cases2[cases set, case_names left right]:
    assumes A: "B+C = {#s#}+A"
    assumes L: "\<lbrakk>B={#s#}+(B-{#s#}); A=(B-{#s#})+C\<rbrakk> \<Longrightarrow> P"
    assumes R: "\<lbrakk>C={#s#}+(C-{#s#}); A=B+(C-{#s#})\<rbrakk> \<Longrightarrow> P" 
    shows P
    using mset_unplusm_dist_cases[OF A[symmetric]] L R by blast

  lemma mset_single_cases[cases set, case_names loc env]: 
    assumes A: "{#s#}+c = {#r'#}+c'" 
    assumes CASES: "\<lbrakk>s=r'; c=c'\<rbrakk> \<Longrightarrow> P" "\<lbrakk>c'={#s#}+(c'-{#s#}); c={#r'#}+(c-{#r'#}); c-{#r'#} = c'-{#s#} \<rbrakk> \<Longrightarrow> P" 
    shows "P"
  proof -
    { assume CASE: "s=r'"
      with A have "c=c'" by simp
      with CASE CASES have ?thesis by auto
    } moreover {
      assume CASE: "s\<noteq>r'"
      have "s:#{#s#}+c" by simp
      with A have "s:#{#r'#}+c'" by simp
      with CASE have "s:#c'" by (auto elim!: mset_un_cases split: split_if_asm)
      from mset_diff_union_s_inverse[OF this, symmetric] have 1: "c' = {#s#} + (c' - {#s#})" .
      with A have "{#s#}+c = {#s#}+({#r'#}+(c' - {#s#}))" by (auto simp add: union_ac)
      hence 2: "c={#r'#}+(c' - {#s#})" by (auto)
      hence 3: "c-{#r'#} = (c' - {#s#})" by auto
      from 1 2 3 CASES have ?thesis by auto
    } ultimately show ?thesis by blast
  qed

  lemma mset_single_cases'[cases set, case_names loc env]: 
    assumes A: "{#s#}+c = {#r'#}+c'" 
    assumes CASES: "\<lbrakk>s=r'; c=c'\<rbrakk> \<Longrightarrow> P" "!!cc. \<lbrakk>c'={#s#}+cc; c={#r'#}+cc; c'-{#s#}=cc; c-{#r'#}=cc\<rbrakk> \<Longrightarrow> P" 
    shows "P"
    using A  CASES by (auto elim!: mset_single_cases)

  lemma mset_single_cases2[cases set, case_names loc env]: 
    assumes A: "c+{#s#} = c'+{#r'#}" 
    assumes CASES: "\<lbrakk>s=r'; c=c'\<rbrakk> \<Longrightarrow> P" "\<lbrakk>c'=(c'-{#s#})+{#s#}; c=(c-{#r'#})+{#r'#}; c-{#r'#} = c'-{#s#} \<rbrakk> \<Longrightarrow> P" 
    shows "P" 
  proof -
    from A have "{#s#}+c = {#r'#}+c'" by (simp add: union_ac)
    thus ?thesis proof (cases rule: mset_single_cases)
      case loc with CASES show ?thesis by simp
    next
      case env with CASES show ?thesis by (simp add: union_ac)
    qed
  qed

  lemma mset_single_cases2'[cases set, case_names loc env]: 
    assumes A: "c+{#s#} = c'+{#r'#}" 
    assumes CASES: "\<lbrakk>s=r'; c=c'\<rbrakk> \<Longrightarrow> P" "!!cc. \<lbrakk>c'=cc+{#s#}; c=cc+{#r'#}; c'-{#s#}=cc; c-{#r'#}=cc\<rbrakk> \<Longrightarrow> P" 
    shows "P"
    using A  CASES by (auto elim!: mset_single_cases2)

  lemma mset_un_single_un_cases[consumes 1, case_names left right]: assumes A: "A+{#a#} = B+C" and CASES: "\<lbrakk>a:#B; A=(B-{#a#})+C\<rbrakk> \<Longrightarrow> P" "\<lbrakk>a:#C; A=B+(C-{#a#})\<rbrakk> \<Longrightarrow> P" shows "P"
  proof -
    have "a:#A+{#a#}" by simp
    with A have "a:#B+C" by auto
    thus ?thesis proof (cases rule: mset_un_cases)
      case left hence "B=B-{#a#}+{#a#}" by auto
      with A have "A+{#a#} = (B-{#a#})+C+{#a#}" by (auto simp add: union_ac)
      hence "A=(B-{#a#})+C" by simp
      with CASES(1)[OF left] show ?thesis by blast
    next
      case right hence "C=C-{#a#}+{#a#}" by auto
      with A have "A+{#a#} = B+(C-{#a#})+{#a#}" by (auto simp add: union_ac)
      hence "A=B+(C-{#a#})" by simp
      with CASES(2)[OF right] show ?thesis by blast
    qed
  qed

      (* TODO: Can this proof be done more automatically ? *)
  lemma mset_distrib[consumes 1, case_names dist]: assumes A: "(A::'a multiset)+B = M+N" "!!Am An Bm Bn. \<lbrakk>A=Am+An; B=Bm+Bn; M=Am+Bm; N=An+Bn\<rbrakk> \<Longrightarrow> P" shows "P"
  proof -
    { 
      fix X
      have "!!A B M N P. \<lbrakk> (X::'a multiset)=A+B; A+B = M+N; !!Am An Bm Bn. \<lbrakk>A=Am+An; B=Bm+Bn; M=Am+Bm; N=An+Bn\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
      proof (induct X)
        case empty thus ?case by simp
      next
        case (add X x A B M N) 
        from add(2,3) have MN: "X+{#x#} = M+N" by simp
        from add(2) show ?case proof (cases rule: mset_un_single_un_cases)
          case left from MN show ?thesis proof (cases rule: mset_un_single_un_cases[case_names left' right'])
            case left' with left have "X=A-{#x#}+B" "A-{#x#}+B = M-{#x#}+N" by simp_all
            from "add.hyps"[OF this] obtain Am An Bm Bn where "A - {#x#} = Am + An" "B = Bm + Bn" "M - {#x#} = Am + Bm" "N = An + Bn" .
            hence "A - {#x#} + {#x#} = Am+{#x#} + An" "B = Bm + Bn" "M - {#x#}+{#x#} = Am+{#x#} + Bm" "N = An + Bn" by (simp_all add: union_ac)
            with left(1) left'(1) show ?thesis using "add.prems"(3) by auto
          next
            case right' with left have "X=A-{#x#}+B" "A-{#x#}+B = M+(N-{#x#})" by simp_all
            from "add.hyps"[OF this] obtain Am An Bm Bn where "A - {#x#} = Am + An" "B = Bm + Bn" "M = Am + Bm" "N-{#x#} = An + Bn" .
            hence "A - {#x#} + {#x#} = Am + (An+{#x#})" "B = Bm + Bn" "M = Am + Bm" "N - {#x#}+{#x#} = (An+{#x#}) + Bn" by (simp_all add: union_ac)
            with left(1) right'(1) show ?thesis using "add.prems"(3) by auto
          qed
        next
          case right from MN show ?thesis proof (cases rule: mset_un_single_un_cases[case_names left' right'])
            case left' with right have "X=A+(B-{#x#})" "A+(B-{#x#}) = M-{#x#}+N" by simp_all
            from "add.hyps"[OF this] obtain Am An Bm Bn where "A = Am + An" "B-{#x#} = Bm + Bn" "M - {#x#} = Am + Bm" "N = An + Bn" .
            hence "A = Am + An" "B-{#x#}+{#x#} = Bm+{#x#} + Bn" "M - {#x#}+{#x#} = Am + (Bm+{#x#})" "N = An + Bn" by (simp_all add: union_ac)
            with right(1) left'(1) show ?thesis using "add.prems"(3) by auto
          next
            case right' with right have "X=A+(B-{#x#})" "A+(B-{#x#}) = M+(N-{#x#})" by simp_all
            from "add.hyps"[OF this] obtain Am An Bm Bn where "A = Am + An" "B-{#x#} = Bm + Bn" "M = Am + Bm" "N-{#x#} = An + Bn" .
            hence "A = Am + An" "B-{#x#}+{#x#} = Bm + (Bn+{#x#})" "M = Am + Bm" "N - {#x#}+{#x#} = An + (Bn+{#x#})" by (simp_all add: union_ac)
            with right(1) right'(1) show ?thesis using "add.prems"(3) by auto
          qed
        qed
      qed
    } with A show ?thesis by blast
  qed


subsubsection {* Singleton multisets *}         
  lemma mset_singletonI[intro!]: "a :# {#a#}"
    by auto

  lemma mset_singletonD[dest!]: "b :# {#a#} \<Longrightarrow> b=a" 
    apply(cases "a=b")
    apply(auto)
  done

lemma mset_size_le1_cases[case_names empty singleton,consumes 1]: "\<lbrakk> size M \<le> Suc 0; M={#} \<Longrightarrow> P; !!m. M={#m#} \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (cases M) auto

lemma diff_union_single_conv2: "a :# J \<Longrightarrow> J + I - {#a#} = (J - {#a#}) + I" using diff_union_single_conv[of J a I]
  by (simp add: union_ac)

lemmas diff_union_single_convs = diff_union_single_conv diff_union_single_conv2

lemma mset_contains_eq: "(m:#M) = ({#m#}+(M-{#m#})=M)" proof (auto)
  assume "{#m#} + (M - {#m#}) = M"
  moreover have "m :# {#m#} + (M - {#m#})" by simp
  ultimately show "m:#M" by simp
qed


subsubsection {* Pointwise ordering *}
  

  (*declare mset_le_trans[trans] Seems to be in there now. Why is this not done in Multiset.thy or order-class ? *)

  lemma mset_empty_minimal[simp, intro!]: "{#} \<le> c"
    by (unfold mset_le_def, auto)
  lemma mset_empty_least[simp]: "c \<le> {#} = (c={#})"
    by (unfold mset_le_def, auto)
  lemma mset_empty_leastI[intro!]: "c={#} \<Longrightarrow> c \<le> {#}"
    by (simp only: mset_empty_least)

  lemma mset_le_incr_right1: "a\<le>(b::'a multiset) \<Longrightarrow> a\<le>b+c" using mset_le_mono_add[of a b "{#}" c, simplified] .
  lemma mset_le_incr_right2: "a\<le>(b::'a multiset) \<Longrightarrow> a\<le>c+b" using mset_le_incr_right1
    by (auto simp add: union_commute)
  lemmas mset_le_incr_right = mset_le_incr_right1 mset_le_incr_right2

  lemma mset_le_decr_left1: "a+c\<le>(b::'a multiset) \<Longrightarrow> a\<le>b" using mset_le_incr_right1 mset_le_mono_add_right_cancel
    by blast
  lemma mset_le_decr_left2: "c+a\<le>(b::'a multiset) \<Longrightarrow> a\<le>b" using mset_le_decr_left1
    by (auto simp add: union_ac)
  lemmas mset_le_decr_left = mset_le_decr_left1 mset_le_decr_left2
  
  lemma mset_le_single_conv[simp]: "({#e#}\<le>M) = (e:#M)"
    by (unfold mset_le_def) auto

  lemma mset_le_trans_elem: "\<lbrakk>e :# c; c \<le> c'\<rbrakk> \<Longrightarrow> e :# c'" using order_trans[of "{#e#}" c c', simplified]
    by assumption

  lemma mset_le_subtract: "A\<le>B \<Longrightarrow> A-C \<le> B-(C::'a multiset)"
    apply (unfold mset_le_def) 
    apply auto
    apply (subgoal_tac "count A a \<le> count B a")
    apply arith
    apply simp
    done

  lemma mset_le_union: "A+B \<le> C \<Longrightarrow> A\<le>C \<and> B\<le>(C::'a multiset)"
    by (auto dest: mset_le_decr_left)

  lemma mset_le_subtract_left: "A+B \<le> (X::'a multiset) \<Longrightarrow> B \<le> X-A \<and> A\<le>X"
    by (auto dest: mset_le_subtract[of "A+B" "X" "A"] mset_le_union)
  lemma mset_le_subtract_right: "A+B \<le> (X::'a multiset) \<Longrightarrow> A \<le> X-B \<and> B\<le>X"
    by (auto dest: mset_le_subtract[of "A+B" "X" "B"] mset_le_union)
  
  lemma mset_le_addE: "\<lbrakk> xs \<le> (ys::'a multiset); !!zs. ys=xs+zs \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P" using mset_le_exists_conv
    by blast

  lemma mset_le_sub_add_eq[simp,intro]: "A\<le>(B::'a multiset) \<Longrightarrow> B-A+A = B"
    by (auto elim: mset_le_addE simp add: union_ac)

  lemma mset_2dist2_cases:
    assumes A: "{#a#}+{#b#} \<le> A+B"
    assumes CASES: "{#a#}+{#b#} \<le> A \<Longrightarrow> P" "{#a#}+{#b#} \<le> B \<Longrightarrow> P" "\<lbrakk>a :# A; b :# B\<rbrakk> \<Longrightarrow> P" "\<lbrakk>a :# B; b :# A\<rbrakk> \<Longrightarrow> P"
    shows "P"
  proof -
    { assume C: "a :# A" "b :# A-{#a#}" 
      with mset_le_mono_add[of "{#a#}" "{#a#}" "{#b#}" "A-{#a#}"] have "{#a#}+{#b#} \<le> A" by auto
    } moreover {
      assume C: "a :# A" "\<not> (b :# A-{#a#})"
      with A have "b:#B" by (unfold mset_le_def) (auto split: split_if_asm)
    } moreover {
      assume C: "\<not> (a :# A)" "b :# B-{#a#}"
      with A have "a :# B" by (unfold mset_le_def) (auto split: split_if_asm)
      with C mset_le_mono_add[of "{#a#}" "{#a#}" "{#b#}" "B-{#a#}"] have "{#a#}+{#b#} \<le> B" by auto
    } moreover {
      assume C: "\<not> (a :# A)" "\<not> (b :# B-{#a#})"
      with A have "a:#B \<and> b:#A" by (unfold mset_le_def) (auto split: split_if_asm)
    } ultimately show P using CASES by blast
  qed

  lemma mset_union_subset: "A+B \<le> (C::'a multiset) \<Longrightarrow> A\<le>C \<and> B\<le>C" 
    apply (unfold mset_le_def)
    apply auto
    apply (subgoal_tac "count A a + count B a \<le> count C a", arith, simp)+
    done

  lemma mset_union_subset_s: "{#a#}+B \<le> C \<Longrightarrow> a :# C \<and> B \<le> C"
    by (auto dest: mset_union_subset)

  (* TODO: Check which of these lemmas are already introduced by order-classes ! *)
  lemma mset_le_eq_refl: "a=(b::'a multiset) \<Longrightarrow> a\<le>b"
    by simp

  lemma mset_singleton_eq[simplified,simp]: "a :# {#b#} = (a=b)"
    by auto -- {* The simplification is here due to the lemma @{thm [source] "Multiset.count_single"}, that will be applied first deleting any application potential for this rule*}
  lemma mset_le_single_single[simp]: "({#a#} \<le> {#b#}) = (a=b)"
    by auto

  lemma mset_le_single_conv1[simp]: "(M+{#a#} \<le> {#b#}) = (M={#} \<and> a=b)"
  proof (auto) 
    assume A: "M+{#a#} \<le> {#b#}" thus "a=b" by (auto dest: mset_le_decr_left2)
    with A mset_le_mono_add_right_cancel[of M "{#a#}" "{#}", simplified] show "M={#}" by blast
  qed
  
  lemma mset_le_single_conv2[simp]: "({#a#}+M \<le> {#b#}) = (M={#} \<and> a=b)"
    by (simp add: union_ac)
  
  lemma mset_le_single_cases[consumes 1, case_names empty singleton]: "\<lbrakk>M\<le>{#a#}; M={#} \<Longrightarrow> P; M={#a#} \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (induct M) auto
      
  lemma mset_le_distrib[consumes 1, case_names dist]: "\<lbrakk>(X::'a multiset)\<le>A+B; !!Xa Xb. \<lbrakk>X=Xa+Xb; Xa\<le>A; Xb\<le>B\<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (auto elim!: mset_le_addE mset_distrib)

  lemma mset_le_mono_add_single: "\<lbrakk>a :# ys; b :# ws\<rbrakk> \<Longrightarrow> {#a#} + {#b#} \<le> ys + ws" using mset_le_mono_add[of "{#a#}" _ "{#b#}", simplified] .

  lemma mset_size1elem: "\<lbrakk>size P \<le> 1; q :# P\<rbrakk> \<Longrightarrow> P={#q#}"
    by (auto elim: mset_size_le1_cases)
  lemma mset_size2elem: "\<lbrakk>size P \<le> 2; {#q#}+{#q'#} \<le> P\<rbrakk> \<Longrightarrow> P={#q#}+{#q'#}"
    by (auto elim: mset_le_addE)


subsubsection {* Image under function *}

inductive_set 
  mset_map_Set :: "('a \<Rightarrow> 'b) \<Rightarrow> ('a multiset \<times> 'b multiset) set"
  for f:: "'a \<Rightarrow> 'b"
  where
  mset_map_Set_empty: "({#},{#})\<in>mset_map_Set f"
  | mset_map_Set_add: "(A,B)\<in>mset_map_Set f \<Longrightarrow> (A+{#a#},B+{#f a#})\<in>mset_map_Set f"

lemma mset_map_Set_empty_simps[simp]: "(({#},B)\<in>mset_map_Set f) = (B={#})" "((A,{#})\<in>mset_map_Set f) = (A={#})"
  by (auto elim: mset_map_Set.cases intro: mset_map_Set_empty)

lemma mset_map_Set_single_left[simp]: "(({#a#},B)\<in>mset_map_Set f) = (B={#f a#})"
  by (auto elim: mset_map_Set.cases intro: mset_map_Set_add[of "{#}" "{#}", simplified])
lemma mset_map_Set_single_rightE[cases set, case_names orig]: "\<lbrakk>(A,{#b#})\<in>mset_map_Set f; !!a. \<lbrakk>A={#a#}; b=f a\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  by (auto elim: mset_map_Set.cases)

lemma mset_map_Set_sizes: "(A,B)\<in>mset_map_Set f \<Longrightarrow> size A = size B"
  by (induct rule: mset_map_Set.induct) auto

text {* Intuitively, this lemma allows one to choose a single image element corresponding to an original element *}
lemma mset_map_Set_choose[cases set, case_names choice]: assumes A: "(A+{#a#},B)\<in>mset_map_Set f" "!!B'. \<lbrakk>B=B'+{#f a#}; (A,B')\<in>mset_map_Set f\<rbrakk> \<Longrightarrow> P" shows "P" 
proof -
  { fix n
    have "\<lbrakk>size B=n; (A+{#a#},B)\<in>mset_map_Set f; !!B'. \<lbrakk>B=B'+{#f a#}; (A,B')\<in>mset_map_Set f\<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P" proof (induct n arbitrary: A a B P)

    (*have "!!A a B P. \<lbrakk>size B=n; (A+{#a#},B)\<in>mset_map_Set f; !!B'. \<lbrakk>B=B'+{#f a#}; (A,B')\<in>mset_map_Set f\<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P" proof (induct n)*)
      case 0 thus ?case by simp
    next
      case (Suc n') from Suc.prems(2) show ?case proof (cases rule: mset_map_Set.cases)
        case mset_map_Set_empty hence False by simp thus ?thesis ..
      next
        case (mset_map_Set_add A' B' a') 
        hence "A+{#a#}=A'+{#a'#}" by simp
        thus ?thesis proof (cases rule: mset_single_cases2')
          case loc with mset_map_Set_add Suc.prems(3) show ?thesis by auto
        next
          case (env A'') 
          from Suc.prems(1) mset_map_Set_add(2) have SIZE: "size B' = n'" by auto
          from mset_map_Set_add env have MM: "(A'' + {#a#}, B') \<in> mset_map_Set f" by simp
          from Suc.hyps[OF SIZE MM] obtain B'' where B'': "B'=B''+{#f a#}" "(A'',B'')\<in>mset_map_Set f" by blast
          from mset_map_Set.mset_map_Set_add[OF B''(2)] env(2) have "(A, B'' + {#f a'#}) \<in> mset_map_Set f" by simp
          moreover from B''(1) mset_map_Set_add have "B=B'' + {#f a'#} + {#f a#}" by (simp add: union_ac)
          ultimately show ?thesis using Suc.prems(3) by blast
        qed
      qed
    qed
  } with A show P by blast
qed

lemma mset_map_Set_unique: "!!B B'. \<lbrakk>(A,B)\<in>mset_map_Set f; (A,B')\<in>mset_map_Set f\<rbrakk> \<Longrightarrow> B=B'"
  by (induct A) (auto elim!: mset_map_Set_choose)
lemma mset_map_Set_surjective: "\<lbrakk> !!B. (A,B)\<in>mset_map_Set f \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (induct A) (auto intro: mset_map_Set_add)


definition
  mset_map :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a multiset \<Rightarrow> 'b multiset" (infixr "`#" 90)
  where
  "f `# A == (THE B. (A,B)\<in>mset_map_Set f)"


interpretation mset_map: su_rel_fun "mset_map_Set f" "op `# f"
  apply (rule su_rel_fun.intro)
  apply (erule mset_map_Set_unique, assumption)
  apply (erule mset_map_Set_surjective)
  apply (rule mset_map_def)
  done
  
text {* Transfer the defining equations *}
lemma mset_map_empty[simp]: "f `# {#} = {#}"
  apply (subst mset_map.repr)
  apply (rule mset_map_Set_empty)
  done

lemma mset_map_add[simp]: "f `# (A+{#a#}) = f `# A + {#f a#}" "f `# ({#a#}+A) = {#f a#} + f `# A"
  by (auto simp add: mset_map.repr union_commute intro: mset_map_Set_add mset_map.repr1)

text {* Transfer some other lemmas *}
lemma mset_map_single_rightE[consumes 1, case_names orig]: "\<lbrakk>f `# P = {#y#}; !!x. \<lbrakk> P={#x#}; f x = y \<rbrakk> \<Longrightarrow> Q \<rbrakk> \<Longrightarrow> Q"
  by (auto simp add: mset_map.repr elim: mset_map_Set_single_rightE)

text {* And show some further equations *}
lemma mset_map_single[simp]: "f `# {#a#} = {#f a#}" using mset_map_add(1)[where A="{#}", simplified] .

lemma mset_map_union: "!!B. f `# (A+B) = f `# A + f `# B"
  by (induct A) (auto simp add: union_ac)

lemma mset_map_size: "size A = size (f `# A)"
  by (induct A) auto

lemma mset_map_empty_eq[simp]: "(f `# P = {#}) = (P={#})" using mset_map_size[of P f]
  by auto

lemma mset_map_le: "!!B. A \<le> B \<Longrightarrow> f `# A \<le> f `# B" proof (induct A)
  case empty thus ?case by simp
next
  case (add A x B)
  hence "A\<le>B-{#x#}" and SM: "{#x#}\<le>B" using mset_le_subtract_right by (fastforce+)
  with "add.hyps" have "f `# A \<le> f `# (B-{#x#})" by blast
  hence "f `# (A+{#x#}) \<le> f `# (B-{#x#}) + {#f x#}" by auto
  also have "\<dots> = f `# (B-{#x#}+{#x#})" by simp
  also with SM have "\<dots> = f `# B" by simp
  finally show ?case .
qed

lemma mset_map_set_of: "set_of (f `# A) = f ` set_of A"
  by (induct A) auto

lemma mset_map_split_orig: "!!M1 M2. \<lbrakk>f `# P = M1+M2; !!P1 P2. \<lbrakk>P=P1+P2; f `# P1 = M1; f `# P2 = M2\<rbrakk> \<Longrightarrow> Q \<rbrakk> \<Longrightarrow> Q"
  apply (induct P)
  apply fastforce
  apply (fastforce elim!: mset_un_single_un_cases simp add: union_ac) (* TODO: This proof need's quite long. Try to write a faster one. *)
  done

lemma mset_map_id: "\<lbrakk>!!x. f (g x) = x\<rbrakk> \<Longrightarrow> f `# g `# X = X"
  by (induct X) auto

text {* The following is a very specialized lemma. Intuitively, it splits the original multiset
  by a splitting of some pointwise supermultiset of its image.

  Application:
  This lemma came in handy when proving the correctness of a constraint system that collects at most k sized submultisets of the sets of spawned threads.
*}
lemma mset_map_split_orig_le: assumes A: "f `# P \<le> M1+M2" and EX: "!!P1 P2. \<lbrakk>P=P1+P2; f `# P1 \<le> M1; f `# P2 \<le> M2\<rbrakk> \<Longrightarrow> Q" shows "Q" 
  using A EX by (auto elim: mset_le_distrib mset_map_split_orig)


subsection {* Lists *}

  -- "Obtains a list from the pointwise characterization of its elements"
  (* Put here, because other lemmas depends on it *)
lemma obtain_list_from_elements:
  assumes A: "\<forall>i<n. (\<exists>li. P li i)"
  obtains l where 
    "length l = n"
    "\<forall>i<n. P (l!i) i"
proof -
  from A have "\<exists>l. length l=n \<and> (\<forall>i<n. P (l!i) i)"
  proof (induct n)
    case 0 thus ?case by simp
  next
    case (Suc n)
    then obtain l where IH: "length l = n" "(\<forall>i<n. P(l!i) i)" by auto
    moreover from Suc.prems obtain ln where "P ln n" by auto
    ultimately have "length (l@[ln]) = Suc n" "(\<forall>i<Suc n. P((l@[ln])!i) i)"
      by (auto simp add: nth_append dest: less_antisym)
    thus ?case by blast
  qed
  thus ?thesis using that by (blast)
qed





subsubsection {* Reverse lists *}
  lemma list_rev_decomp[rule_format]: "l~=[] \<longrightarrow> (EX ll e . l = ll@[e])"
    apply(induct_tac l)
    apply(auto)
  done
    
  (* Was already there as rev_induct
  lemma list_rev_induct: "\<lbrakk>P []; !! l e . P l \<Longrightarrow> P (l@[e]) \<rbrakk> \<Longrightarrow> P l"
    by (blast intro: rev_induct)
  proof (induct l rule: measure_induct[of length])
    fix x :: "'a list"
    assume A: "\<forall>y. length y < length x \<longrightarrow> P [] \<longrightarrow> (\<forall>x xa. P (x::'a list) \<longrightarrow> P (x @ [xa])) \<longrightarrow> P y" "P []" and IS: "\<And>l e. P l \<Longrightarrow> P (l @ [e])"
    show "P x" proof (cases "x=[]")
      assume "x=[]" with A show ?thesis by simp
    next
      assume CASE: "x~=[]"
      then obtain xx e where DECOMP: "x=xx@[e]" by (blast dest: list_rev_decomp)
      hence LEN: "length xx < length x" by auto
      with A IS have "P xx" by auto
      with IS have "P (xx@[e])" by auto
      with DECOMP show ?thesis by auto
    qed
  qed
  *)

  text {* Caution: Same order of case variables in snoc-case as @{thm [source] rev_exhaust}, the other way round than @{thm [source] rev_induct} ! *}
  lemma length_compl_rev_induct[case_names Nil snoc]: "\<lbrakk>P []; !! l e . \<lbrakk>!! ll . length ll <= length l \<Longrightarrow> P ll\<rbrakk> \<Longrightarrow> P (l@[e])\<rbrakk> \<Longrightarrow> P l"
    apply(induct_tac l rule: length_induct)
    apply(case_tac "xs" rule: rev_cases)
    apply(auto)
  done

  lemma list_append_eq_Cons_cases[consumes 1]: "\<lbrakk>ys@zs = x#xs; \<lbrakk>ys=[]; zs=x#xs\<rbrakk> \<Longrightarrow> P; !!ys'. \<lbrakk> ys=x#ys'; ys'@zs=xs \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (auto iff add: append_eq_Cons_conv)
  lemma list_Cons_eq_append_cases[consumes 1]: "\<lbrakk>x#xs = ys@zs; \<lbrakk>ys=[]; zs=x#xs\<rbrakk> \<Longrightarrow> P; !!ys'. \<lbrakk> ys=x#ys'; ys'@zs=xs \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (auto iff add: Cons_eq_append_conv)

lemma map_of_rev_distinct[simp]: 
  "distinct (map fst m) \<Longrightarrow> map_of (rev m) = map_of m"
  apply (induct m)
    apply simp

    apply simp
    apply (subst map_add_comm)
      apply force
      apply simp
  done


-- {* Tail-recursive, generalized @{const rev}. May also be used for
      tail-recursively getting a list with all elements of the two 
      operands, if the order does not matter, e.g. when implementing 
      sets by lists. *}
fun revg where
  "revg [] b = b" |
  "revg (a#as) b = revg as (a#b)"

lemma revg_fun[simp]: "revg a b = rev a @ b"
  by (induct a arbitrary: b)
      auto



subsubsection "Folding"

text "Ugly lemma about foldl over associative operator with left and right neutral element"
lemma foldl_A1_eq: "!!i. \<lbrakk> !! e. f n e = e; !! e. f e n = e; !!a b c. f a (f b c) = f (f a b) c \<rbrakk> \<Longrightarrow> foldl f i ww = f i (foldl f n ww)"
proof (induct ww)
  case Nil thus ?case by simp
next
  case (Cons a ww i) note IHP[simplified]=this
  have "foldl f i (a # ww) = foldl f (f i a) ww" by simp
  also from IHP have "\<dots> = f (f i a) (foldl f n ww)" by blast
  also from IHP(4) have "\<dots> = f i (f a (foldl f n ww))" by simp
  also from IHP(1)[OF IHP(2,3,4), where i=a] have "\<dots> = f i (foldl f a ww)" by simp
  also from IHP(2)[of a] have "\<dots> = f i (foldl f (f n a) ww)" by simp
  also have "\<dots> = f i (foldl f n (a#ww))" by simp
  finally show ?case .
qed


lemmas foldl_conc_empty_eq = foldl_A1_eq[of "op @" "[]", simplified]
lemmas foldl_un_empty_eq = foldl_A1_eq[of "op \<union>" "{}", simplified, OF Un_assoc[symmetric]]

lemma foldl_set: "foldl (op \<union>) {} l = \<Union>{x. x\<in>set l}"
  apply (induct l)
  apply simp_all
  apply (subst foldl_un_empty_eq)
  apply auto
  done

lemma (in monoid_mult) foldl_absorb1: "x*foldl (op *) 1 zs = foldl (op *) x zs"
  apply (rule sym)
  apply (rule foldl_A1_eq)
  apply (auto simp add: mult_assoc)
done

text {* Towards an invariant rule for foldl *}
lemma foldl_rule_aux:
  fixes I :: "'\<sigma> \<Rightarrow> 'a list \<Rightarrow> bool"
  assumes initial: "I \<sigma>0 l0"
  assumes step: "!!l1 l2 x \<sigma>. \<lbrakk> l0=l1@x#l2; I \<sigma> (x#l2) \<rbrakk> \<Longrightarrow> I (f \<sigma> x) l2"
  shows "I (foldl f \<sigma>0 l0) []"
  using initial step
  apply (induct l0 arbitrary: \<sigma>0)
  apply auto
  done

lemma foldl_rule_aux_P:
  fixes I :: "'\<sigma> \<Rightarrow> 'a list \<Rightarrow> bool"
  assumes initial: "I \<sigma>0 l0"
  assumes step: "!!l1 l2 x \<sigma>. \<lbrakk> l0=l1@x#l2; I \<sigma> (x#l2) \<rbrakk> \<Longrightarrow> I (f \<sigma> x) l2"
  assumes final: "!!\<sigma>. I \<sigma> [] \<Longrightarrow> P \<sigma>"
  shows "P (foldl f \<sigma>0 l0)"
using foldl_rule_aux[of I \<sigma>0 l0, OF initial, OF step] final
by simp


lemma foldl_rule:
  fixes I :: "'\<sigma> \<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> bool"
  assumes initial: "I \<sigma>0 [] l0"
  assumes step: "!!l1 l2 x \<sigma>. \<lbrakk> l0=l1@x#l2; I \<sigma> l1 (x#l2) \<rbrakk> \<Longrightarrow> I (f \<sigma> x) (l1@[x]) l2"
  shows "I (foldl f \<sigma>0 l0) l0 []"
  using initial step
  apply (rule_tac I="\<lambda>\<sigma> lr. \<exists>ll. l0=ll@lr \<and> I \<sigma> ll lr" in foldl_rule_aux_P)
  apply auto
  done

text {*
  Invariant rule for foldl. The invariant is parameterized with
  the state, the list of items that have already been processed and 
  the list of items that still have to be processed.
*}
lemma foldl_rule_P:
  fixes I :: "'\<sigma> \<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> bool"
  -- "The invariant holds for the initial state, no items processed yet and all items to be processed:"
  assumes initial: "I \<sigma>0 [] l0" 
  -- "The invariant remains valid if one item from the list is processed"
  assumes step: "!!l1 l2 x \<sigma>. \<lbrakk> l0=l1@x#l2; I \<sigma> l1 (x#l2) \<rbrakk> \<Longrightarrow> I (f \<sigma> x) (l1@[x]) l2"
  -- "The proposition follows from the invariant in the final state, i.e. all items processed and nothing to be processed"
  assumes final: "!!\<sigma>. I \<sigma> l0 [] \<Longrightarrow> P \<sigma>"
  shows "P (foldl f \<sigma>0 l0)"
  using foldl_rule[of I, OF initial step] by (simp add: final)


text {* Invariant reasoning over @{const foldl} for distinct lists. Invariant rule makes no 
  assumptions about ordering. *}
lemma distinct_foldl_invar: 
  "\<lbrakk> distinct S; I (set S) \<sigma>0; 
     \<And>x it \<sigma>. \<lbrakk>x \<in> it; it \<subseteq> set S; I it \<sigma>\<rbrakk> \<Longrightarrow> I (it - {x}) (f \<sigma> x)
   \<rbrakk> \<Longrightarrow> I {} (foldl f \<sigma>0 S)"
proof (induct S arbitrary: \<sigma>0)
  case Nil thus ?case by auto
next
  case (Cons x S)

  note [simp] = Cons.prems(1)[simplified]

  show ?case
    apply simp
    apply (rule Cons.hyps)
  proof -
    from Cons.prems(1) show "distinct S" by simp
    from Cons.prems(3)[of x "set (x#S)", simplified, 
                       OF Cons.prems(2)[simplified]] 
    show "I (set S) (f \<sigma>0 x)" .
    fix xx it \<sigma>
    assume A: "xx\<in>it" "it \<subseteq> set S" "I it \<sigma>"
    show "I (it - {xx}) (f \<sigma> xx)" using A(2)
      apply (rule_tac Cons.prems(3))
      apply (simp_all add: A(1,3))
      apply blast
      done
  qed
qed

lemma foldl_length_aux: "foldl (\<lambda>i x. Suc i) a l = a + length l"
  by (induct l arbitrary: a) auto

lemmas foldl_length[simp] = foldl_length_aux[where a=0, simplified]

lemma foldr_length_aux: "foldr (\<lambda>x i. Suc i) l a = a + length l"
  by (induct l arbitrary: a rule: rev_induct) auto

lemmas foldr_length[simp] = foldr_length_aux[where a=0, simplified]

context comp_fun_commute begin

lemma foldl_f_commute: "f a (foldl (\<lambda>a b. f b a) b xs) = foldl (\<lambda>a b. f b a) (f a b) xs"
by(induct xs arbitrary: b)(simp_all add: fun_left_comm)

lemma foldr_conv_foldl: "foldr f xs a = foldl (\<lambda>a b. f b a) a xs"
by(induct xs arbitrary: a)(simp_all add: foldl_f_commute)

end

lemma filter_conv_foldr:
  "filter P xs = foldr (\<lambda>x xs. if P x then x # xs else xs) xs []"
by(induct xs) simp_all

lemma foldr_Cons: "foldr Cons xs [] = xs"
by(induct xs) simp_all

lemma foldr_snd_zip:
  "length xs \<ge> length ys \<Longrightarrow> foldr (\<lambda>(x, y). f y) (zip xs ys) b = foldr f ys b"
proof(induct ys arbitrary: xs)
  case (Cons y ys) thus ?case by(cases xs) simp_all
qed simp

lemma foldl_snd_zip:
  "length xs \<ge> length ys \<Longrightarrow> foldl (\<lambda>b (x, y). f b y) b (zip xs ys) = foldl f b ys"
proof(induct ys arbitrary: xs b)
  case (Cons y ys) thus ?case by(cases xs) simp_all
qed simp

lemma fst_foldl: "fst (foldl (\<lambda>(a, b) x. (f a x, g a b x)) (a, b) xs) = foldl f a xs"
by(induct xs arbitrary: a b) simp_all

lemma foldl_foldl_conv_concat: "foldl (foldl f) a xs = foldl f a (concat xs)"
by(induct xs arbitrary: a) simp_all

lemma foldl_list_update:
  "n < length xs \<Longrightarrow> foldl f a (xs[n := x]) = foldl f (f (foldl f a (take n xs)) x) (drop (Suc n) xs)"
by(simp add: upd_conv_take_nth_drop)


subsubsection {* Map *}
lemma map_eq_consE: "\<lbrakk>map f ls = fa#fl; !!a l. \<lbrakk> ls=a#l; f a=fa; map f l = fl \<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  by auto

lemma map_eq_concE: "\<lbrakk>map f ls = fl@fl'; !!l l'. \<lbrakk> ls=l@l'; map f l=fl; map f l' = fl' \<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  by (induct fl arbitrary: ls P) (simp, force)

lemma map_fst_mk_snd[simp]: "map fst (map (\<lambda>x. (x,k)) l) = l" by (induct l) auto
lemma map_snd_mk_fst[simp]: "map snd (map (\<lambda>x. (k,x)) l) = l" by (induct l) auto
lemma map_fst_mk_fst[simp]: "map fst (map (\<lambda>x. (k,x)) l) = replicate (length l) k" by (induct l) auto
lemma map_snd_mk_snd[simp]: "map snd (map (\<lambda>x. (x,k)) l) = replicate (length l) k" by (induct l) auto

lemma map_zip1: "map (\<lambda>x. (x,k)) l = zip l (replicate (length l) k)" by (induct l) auto
lemma map_zip2: "map (\<lambda>x. (k,x)) l = zip (replicate (length l) k) l" by (induct l) auto
lemmas map_zip=map_zip1 map_zip2

lemma map_append_res: "\<lbrakk> map f l = m1@m2; !!l1 l2. \<lbrakk> l=l1@l2; map f l1 = m1; map f l2 = m2 \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (induct m1 arbitrary: l m2 P) (simp, force)

lemma map_id[simp]: 
  "map id l = l" by (induct l, auto)

lemma map_id'[simp]:
  "map id = id"
  by (rule ext) simp

lemma inj_map_inv_f [simp]: "inj f \<Longrightarrow> map (inv f) (map f l) = l"
  by (simp)

lemma inj_on_map_the: "\<lbrakk>D \<subseteq> dom m; inj_on m D\<rbrakk> \<Longrightarrow> inj_on (the\<circ>m) D"
  apply (rule inj_onI)
  apply simp
  apply (case_tac "m x")
  apply (case_tac "m y")
  apply (auto intro: inj_onD) [1]
  apply (auto intro: inj_onD) [1]
  apply (case_tac "m y")
  apply (auto intro: inj_onD) [1]
  apply simp
  apply (rule inj_onD)
  apply assumption
  apply auto
  done

lemma distinct_mapI: "distinct (List.map f l) \<Longrightarrow> distinct l"
  by (induct l) auto

lemma map_consI: 
  "w=map f ww \<Longrightarrow> f a#w = map f (a#ww)"
  "w@l=map f ww@l \<Longrightarrow> f a#w@l = map f (a#ww)@l"
  by auto


lemma restrict_map_subset_eq: 
  fixes R
  shows "\<lbrakk>m |` R = m'; R'\<subseteq>R\<rbrakk> \<Longrightarrow> m|` R' = m' |` R'"
  by (auto simp add: Int_absorb1)

lemma restrict_map_self[simp]: "m |` dom m = m" 
  apply (rule ext)
  apply (case_tac "m x") 
  apply (auto simp add: restrict_map_def) 
  done

lemma restrict_map_UNIV[simp]: "f |` UNIV = f"
  by (auto simp add: restrict_map_def)

lemma restrict_map_inv[simp]: "f |` (- dom f) = Map.empty"
  by (auto simp add: restrict_map_def intro: ext)

lemma restrict_map_upd: "(f |` S)(k \<mapsto> v) = f(k\<mapsto>v) |` (insert k S)"
  by (auto simp add: restrict_map_def intro: ext)

    (* TODO: Should we, instead, add the symmetric version to the simpset *)
lemma map_upd_eq_restrict[simp]: "m (x:=None) = m |` (-{x})"
  by (auto intro: ext)

declare Map.finite_dom_map_of [simp, intro!]

lemma dom_const'[simp]: "dom (\<lambda>x. Some (f x)) = UNIV"
  by auto

lemma restrict_map_eq :
  "((m |` A) k = None) \<longleftrightarrow> (k \<notin> dom m \<inter> A)"  
  "((m |` A) k = Some v) \<longleftrightarrow> (m k = Some v \<and> k \<in> A)"  
unfolding restrict_map_def
by (simp_all add: dom_def)


definition "rel_of m P == {(k,v). m k = Some v \<and> P (k, v)}"
lemma rel_of_empty[simp]: "rel_of Map.empty P = {}" 
    by (auto simp add: rel_of_def)

subsubsection "zip"
text {* Removing unnecessary premise from @{thm [display] zip_append}*}
lemma zip_append': "\<lbrakk>length xs = length us\<rbrakk> \<Longrightarrow> zip (xs @ ys) (us @ vs) = zip xs us @ zip ys vs"
  by (simp add: zip_append1)

lemma zip_map_parts[simp]: "zip (map fst l) (map snd l) = l" by (induct l) auto

lemma pair_list_split: "\<lbrakk> !!l1 l2. \<lbrakk> l = zip l1 l2; length l1=length l2; length l=length l2 \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
proof (induct l arbitrary: P)
  case Nil thus ?case by auto
next
  case (Cons a l) from Cons.hyps obtain l1 l2 where IHAPP: "l=zip l1 l2" "length l1 = length l2" "length l=length l2" .
  obtain a1 a2 where [simp]: "a=(a1,a2)" by (cases a) auto
  from IHAPP have "a#l = zip (a1#l1) (a2#l2)" "length (a1#l1) = length (a2#l2)" "length (a#l) = length (a2#l2)"
    by (simp_all only:) (simp_all (no_asm_use))
  with Cons.prems show ?case by blast
qed

lemma set_zip_cart: "x\<in>set (zip l l') \<Longrightarrow> x\<in>set l \<times> set l'"
  by (auto simp add: set_zip)

lemma zip_inj: "\<lbrakk>length a = length b; length a' = length b'; zip a b = zip a' b'\<rbrakk> \<Longrightarrow> a=a' \<and> b=b'"
  (* TODO: Clean up proof *)
  apply (induct a b arbitrary: a' b' rule: list_induct2)
  apply (case_tac a')
  apply (case_tac b')
  apply simp
  apply simp
  apply (case_tac b')
  apply simp
  apply simp
  apply (case_tac a')
  apply (case_tac b')
  apply simp
  apply simp
  apply (case_tac b')
  apply simp
proof -
  case goal1
  note [simp] = goal1(5,6)
  from goal1(4) have C: "x=a" "y=aa" "zip xs ys = zip list lista" by simp_all
  from goal1(2)[OF _ C(3)] goal1(3) have "xs=list \<and> ys = lista" by simp_all
  thus ?case using C(1,2) by simp
qed

lemma zip_eq_zip_same_len[simp]: 
  "\<lbrakk> length a = length b; length a' = length b' \<rbrakk> \<Longrightarrow> 
  zip a b = zip a' b' \<longleftrightarrow> a=a' \<and> b=b'"
  by (auto dest: zip_inj)

lemma map_prod_fun_zip: "map (\<lambda>(x, y). (f x, g y)) (zip xs ys) = zip (map f xs) (map g ys)"
proof(induct xs arbitrary: ys)
  case Nil thus ?case by simp
next
  case (Cons x xs) thus ?case by(cases ys) simp_all
qed


subsubsection {* Generalized Zip*}
text {* Zip two lists element-wise, where the combination of two elements is specified by a function. Note that this function is underdefined for lists of different length. *}
fun zipf :: "('a\<Rightarrow>'b\<Rightarrow>'c) \<Rightarrow> 'a list \<Rightarrow> 'b list \<Rightarrow> 'c list" where
  "zipf f [] [] = []" |
  "zipf f (a#as) (b#bs) = f a b # zipf f as bs"


lemma zipf_zip: "\<lbrakk>length l1 = length l2\<rbrakk> \<Longrightarrow> zipf Pair l1 l2 = zip l1 l2"
  apply (induct l1 arbitrary: l2)
  apply auto
  apply (case_tac l2)
  apply auto
  done

  -- "All quantification over zipped lists"
fun list_all_zip where
  "list_all_zip P [] [] \<longleftrightarrow> True" |
  "list_all_zip P (a#as) (b#bs) \<longleftrightarrow> P a b \<and> list_all_zip P as bs" |
  "list_all_zip P _ _ \<longleftrightarrow> False"

lemma list_all_zip_alt: "list_all_zip P as bs \<longleftrightarrow> length as = length bs \<and> (\<forall>i<length as. P (as!i) (bs!i))"
  apply (induct P\<equiv>P as bs rule: list_all_zip.induct)
  apply auto
  apply (case_tac i)
  apply auto
  done
    
lemma list_all_zip_map1: "list_all_zip P (List.map f as) bs \<longleftrightarrow> list_all_zip (\<lambda>a b. P (f a) b) as bs"
  apply (induct as arbitrary: bs)
  apply (case_tac bs)
  apply auto [2]
  apply (case_tac bs)
  apply auto [2]
  done

lemma list_all_zip_map2: "list_all_zip P as (List.map f bs) \<longleftrightarrow> list_all_zip (\<lambda>a b. P a (f b)) as bs"
  apply (induct as arbitrary: bs)
  apply (case_tac bs)
  apply auto [2]
  apply (case_tac bs)
  apply auto [2]
  done

declare list_all_zip_alt[mono]

lemma lazI[intro?]: "\<lbrakk> length a = length b; !!i. i<length b \<Longrightarrow> P (a!i) (b!i) \<rbrakk> 
  \<Longrightarrow> list_all_zip P a b"
  by (auto simp add: list_all_zip_alt)

lemma laz_conj[simp]: "list_all_zip (\<lambda>x y. P x y \<and> Q x y) a b 
                       \<longleftrightarrow> list_all_zip P a b \<and> list_all_zip Q a b"
  by (auto simp add: list_all_zip_alt)

lemma laz_len: "list_all_zip P a b \<Longrightarrow> length a = length b" 
  by (simp add: list_all_zip_alt)

lemma laz_eq: "list_all_zip (op =) a b \<longleftrightarrow> a=b"
  apply (induct a arbitrary: b)
  apply (case_tac b)
  apply simp
  apply simp
  apply (case_tac b)
  apply simp
  apply simp
  done


lemma laz_swap_ex:
  assumes A: "list_all_zip (\<lambda>a b. \<exists>c. P a b c) A B"
  obtains C where 
    "list_all_zip (\<lambda>a c. \<exists>b. P a b c) A C"
    "list_all_zip (\<lambda>b c. \<exists>a. P a b c) B C"
proof -
  from A have 
    [simp]: "length A = length B" and
    IC: "\<forall>i<length B. \<exists>ci. P (A!i) (B!i) ci"
    by (auto simp add: list_all_zip_alt)
  from obtain_list_from_elements[OF IC] obtain C where 
    "length C = length B"
    "\<forall>i<length B. P (A!i) (B!i) (C!i)" .
  thus ?thesis
    by (rule_tac that) (auto simp add: list_all_zip_alt)
qed

lemma laz_weak_Pa[simp]:
  "list_all_zip (\<lambda>a b. P a) A B \<longleftrightarrow> (length A = length B) \<and> (\<forall>a\<in>set A. P a)"
  by (auto simp add: list_all_zip_alt set_conv_nth)

lemma laz_weak_Pb[simp]:
  "list_all_zip (\<lambda>a b. P b) A B \<longleftrightarrow> (length A = length B) \<and> (\<forall>b\<in>set B. P b)"
  by (force simp add: list_all_zip_alt set_conv_nth)



subsubsection "Collecting Sets over Lists"

definition "list_collect_set f l == \<Union>{ f a | a. a\<in>set l }"
lemma list_collect_set_simps[simp]:
  "list_collect_set f [] = {}"
  "list_collect_set f [a] = f a"
  "list_collect_set f (a#l) = f a \<union> list_collect_set f l"
  "list_collect_set f (l@l') = list_collect_set f l \<union> list_collect_set f l'"
by (unfold list_collect_set_def) auto

lemma list_collect_set_map_simps[simp]:
  "list_collect_set f (map x []) = {}"
  "list_collect_set f (map x [a]) = f (x a)"
  "list_collect_set f (map x (a#l)) = f (x a) \<union> list_collect_set f (map x l)"
  "list_collect_set f (map x (l@l')) = list_collect_set f (map x l) \<union> list_collect_set f (map x l')"
by simp_all

lemma list_collect_set_alt: "list_collect_set f l = \<Union>{ f (l!i) | i. i<length l }"
  apply (induct l)
  apply simp
  apply safe
  apply auto
  apply (rule_tac x="f (l!i)" in exI)
  apply simp
  apply (rule_tac x="Suc i" in exI)
  apply simp
  apply (case_tac i)
  apply auto
  done

lemma list_collect_set_as_map: "list_collect_set f l = \<Union>set (map f l)"
  by (unfold list_collect_set_def) auto

subsubsection {* Sorted List with aribitrary Relations *}

inductive sorted_by_rel :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> bool" where
  Nil [iff]: "sorted_by_rel R []"
| Cons: "\<forall>y\<in>set xs. R x y \<Longrightarrow> sorted_by_rel R xs \<Longrightarrow> sorted_by_rel R (x # xs)"

inductive_simps sorted_by_rel_Cons[iff] : "sorted_by_rel R (x # xs)"

lemma sorted_by_rel_single [iff]:
  "sorted_by_rel R [x]" by simp

lemma sorted_by_rel_weaken :
assumes R_weaken: "\<And>x y. \<lbrakk>x \<in> set l0; y \<in> set l0; R x y\<rbrakk> \<Longrightarrow> R' x y"
    and sort: "sorted_by_rel R l0"
shows "sorted_by_rel R' l0" 
using assms
by (induct l0) (simp_all)


lemma sorted_by_rel_map :
  "sorted_by_rel R (map f xs) = sorted_by_rel (\<lambda>x y. R (f x) (f y)) xs"
by (induct xs) auto

lemma sorted_by_rel_append :
  "sorted_by_rel R (xs @ ys) =
   (sorted_by_rel R xs \<and> sorted_by_rel R ys \<and>
    (\<forall>x \<in> set xs. \<forall>y\<in> set ys. R x y))"
by (induct xs) auto

lemma sorted_by_rel_true [simp] :
  "sorted_by_rel (\<lambda>_ _. True) l0"
by (induct l0) (simp_all)

lemma sorted_by_rel_linord [simp] :
  "sorted_by_rel (\<lambda>(x::('a::{linorder})) y. x \<le> y) l0 \<longleftrightarrow> sorted l0"
by (induct l0) (auto simp add: sorted_Cons)

lemma sorted_by_rel_rev_linord [simp] :
  "sorted_by_rel (\<lambda>(x::('a::{linorder})) y. x \<ge> y) l0 \<longleftrightarrow> sorted (rev l0)"
by (induct l0) (auto simp add: sorted_Cons sorted_append)

lemma sorted_by_rel_map_linord [simp] :
  "sorted_by_rel (\<lambda>(x::('a::{linorder} \<times> 'b)) y. fst x \<le> fst y) l0 \<longleftrightarrow> sorted (map fst l0)"
by (induct l0) (auto simp add: sorted_Cons sorted_append)

lemma sorted_by_rel_map_rev_linord [simp] :
  "sorted_by_rel (\<lambda>(x::('a::{linorder} \<times> 'b)) y. fst x \<ge> fst y) l0 \<longleftrightarrow> sorted (rev (map fst l0))"
by (induct l0) (auto simp add: sorted_Cons sorted_append)

subsection {* Quicksort by Relation *}

text {* A functional implementation of quicksort on lists. It it similar to the 
one in Isabelle/HOL's example directory. However, it uses tail-recursion for append and arbitrary
relations. *}

fun partition_rev :: "('a \<Rightarrow> bool) \<Rightarrow> ('a list \<times> 'a list) \<Rightarrow> 'a list \<Rightarrow> ('a list \<times> 'a list)" where
   "partition_rev P (yes, no) [] = (yes, no)"
 | "partition_rev P (yes, no) (x # xs) = 
      partition_rev P (if P x then (x # yes, no) else (yes, x # no)) xs"

lemma partition_rev_filter_conv :
  "partition_rev P (yes, no) xs = (rev (filter P xs) @ yes,  rev (filter (Not \<circ> P) xs) @ no)"
by (induct xs arbitrary: yes no) (simp_all)

function quicksort_by_rel :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "quicksort_by_rel R sl [] = sl"
| "quicksort_by_rel R sl (x#xs) = 
   (let (xs_s, xs_b) = partition_rev (\<lambda>y. R y x) ([],[]) xs in
    quicksort_by_rel R (x # (quicksort_by_rel R sl xs_b)) xs_s)"
by pat_completeness simp_all
termination
by (relation "measure (\<lambda>(_, _, xs). length xs)") 
   (simp_all add: partition_rev_filter_conv less_Suc_eq_le)

lemma quicksort_by_rel_remove_acc :
  "quicksort_by_rel R sl xs = (quicksort_by_rel R [] xs @ sl)"
proof (induct xs arbitrary: sl rule: measure_induct_rule[of "length"]) 
  case (less xs)
  note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis by simp
  next
    case (Cons x xs') note xs_eq[simp] = this

    obtain xs1 xs2 where part_rev_eq[simp]: "partition_rev (\<lambda>y. R y x) ([], []) xs' = (xs1, xs2)"
      by (rule PairE)

    from part_rev_eq[symmetric]
    have length_le: "length xs1 < length xs" "length xs2 < length xs"
      unfolding partition_rev_filter_conv by (simp_all add: less_Suc_eq_le)
    
    note ind_hyp1a = ind_hyp[OF length_le(1), of "x # quicksort_by_rel R [] xs2"] 
    note ind_hyp1b = ind_hyp[OF length_le(1), of "x # quicksort_by_rel R [] xs2 @ sl"] 
    note ind_hyp2 = ind_hyp[OF length_le(2), of sl]

    show ?thesis by (simp add: ind_hyp1a ind_hyp1b ind_hyp2)
  qed
qed

lemma quicksort_by_rel_remove_acc_guared :
  "sl \<noteq> [] \<Longrightarrow> quicksort_by_rel R sl xs = (quicksort_by_rel R [] xs @ sl)"
by (metis quicksort_by_rel_remove_acc)

lemma quicksort_by_rel_permutes [simp]:
  "multiset_of (quicksort_by_rel R sl xs) = multiset_of (xs @ sl)"
proof (induct xs arbitrary: sl rule: measure_induct_rule[of "length"]) 
  case (less xs)
  note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis by simp
  next
    case (Cons x xs') note xs_eq[simp] = this

    obtain xs1 xs2 where part_rev_eq[simp]: "partition_rev (\<lambda>y. R y x) ([], []) xs' = (xs1, xs2)"
      by (rule PairE)

    from part_rev_eq[symmetric] have xs'_multi_eq : "multiset_of xs' = multiset_of xs1 + multiset_of xs2"
      unfolding partition_rev_filter_conv
      by (simp add: multiset_of_filter multiset_partition)

    from part_rev_eq[symmetric]
    have length_le: "length xs1 < length xs" "length xs2 < length xs"
      unfolding partition_rev_filter_conv by (simp_all add: less_Suc_eq_le)
    
    note ind_hyp[OF length_le(1)] ind_hyp[OF length_le(2)]
    thus ?thesis by (simp add: xs'_multi_eq union_assoc)
  qed
qed

lemma set_quicksort_by_rel [simp]: "set (quicksort_by_rel R sl xs) = set (xs @ sl)"
  by (simp add: set_count_greater_0)

lemma sorted_by_rel_quicksort_by_rel:
  fixes R:: "'x \<Rightarrow> 'x \<Rightarrow> bool"
  assumes lin : "\<And>x y. (R x y) \<or> (R y x)"
      and trans_R: "\<And>x y z. R x y \<Longrightarrow> R y z \<Longrightarrow> R x z"
  shows "sorted_by_rel R (quicksort_by_rel R [] xs)"
proof (induct xs rule: measure_induct_rule[of "length"]) 
  case (less xs)
  note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis by simp
  next
    case (Cons x xs') note xs_eq[simp] = this

    obtain xs1 xs2 where part_rev_eq[simp]: "partition_rev (\<lambda>y. R y x) ([], []) xs' = (xs1, xs2)"
      by (rule PairE)

    from part_rev_eq[symmetric] have xs1_props: "\<And>y. y \<in> set xs1 \<Longrightarrow> (R y x)" and 
                                     xs2_props: "\<And>y. y \<in> set xs2 \<Longrightarrow> \<not>(R y x)"
      unfolding partition_rev_filter_conv
      by simp_all

    from xs2_props lin have xs2_props': "\<And>y. y \<in> set xs2 \<Longrightarrow> (R x y)" by blast
    from xs2_props' xs1_props trans_R have xs1_props': 
      "\<And>y1 y2. y1 \<in> set xs1 \<Longrightarrow> y2 \<in> set xs2 \<Longrightarrow> (R y1 y2)"
      by metis

    from part_rev_eq[symmetric]
    have length_le: "length xs1 < length xs" "length xs2 < length xs"
      unfolding partition_rev_filter_conv by (simp_all add: less_Suc_eq_le)
    
    note ind_hyps = ind_hyp[OF length_le(1)] ind_hyp[OF length_le(2)]
    thus ?thesis 
      by (simp add: quicksort_by_rel_remove_acc_guared sorted_by_rel_append Ball_def
                    xs1_props xs2_props' xs1_props')
  qed
qed

lemma sorted_quicksort_by_rel:
  "sorted (quicksort_by_rel op\<le> [] xs)"
unfolding sorted_by_rel_linord[symmetric]
by (rule sorted_by_rel_quicksort_by_rel) auto

lemma sort_quicksort_by_rel:
  "sort = quicksort_by_rel op\<le> []"
  apply (rule ext, rule properties_for_sort) 
  apply(simp_all add: sorted_quicksort_by_rel)
done


subsection {* Mergesort by Relation *}

text {* A functional implementation of mergesort on lists. It it similar to the 
one in Isabelle/HOL's example directory. However, it uses tail-recursion for append and arbitrary
relations. *}

subsection {* Quicksort by Relation *}

text {* A functional implementation of quicksort on lists. It it similar to the 
one in Isabelle/HOL's example directory. However, it uses tail-recursion for append and arbitrary
relations. *}

fun mergesort_by_rel_split :: "('a list \<times> 'a list) \<Rightarrow> 'a list \<Rightarrow> ('a list \<times> 'a list)" where
   "mergesort_by_rel_split (xs1, xs2) [] = (xs1, xs2)"
 | "mergesort_by_rel_split (xs1, xs2) [x] = (x # xs1, xs2)"
 | "mergesort_by_rel_split (xs1, xs2) (x1 # x2 # xs) = 
    mergesort_by_rel_split (x1 # xs1, x2 # xs2) xs" 

lemma list_induct_first2 [consumes 0, case_names Nil Sing Cons2]:
assumes "P []" "\<And>x. P [x]" "\<And>x1 x2 xs. P xs \<Longrightarrow> P (x1 # x2 #xs)"
shows "P xs"
proof (induct xs rule: length_induct)
  case (1 xs) note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis using assms(1) by simp
  next
    case (Cons x1 xs') note xs_eq[simp] = this
    thus ?thesis
    proof (cases xs')
      case Nil thus ?thesis using assms(2) by simp
    next
      case (Cons x2 xs'') note xs'_eq[simp] = this
      show ?thesis 
        by (simp add: ind_hyp assms(3))
    qed
  qed
qed

lemma mergesort_by_rel_split_length :
  "length (fst (mergesort_by_rel_split (xs1, xs2) xs)) = length xs1 + (length xs div 2) + (length xs mod 2) \<and>
   length (snd (mergesort_by_rel_split (xs1, xs2) xs)) = length xs2 + (length xs div 2)"
by (induct xs arbitrary: xs1 xs2 rule: list_induct_first2)
   (simp_all)

lemma multiset_of_mergesort_by_rel_split [simp]:
  "multiset_of (fst (mergesort_by_rel_split (xs1, xs2) xs)) +
   multiset_of (snd (mergesort_by_rel_split (xs1, xs2) xs)) = 
   multiset_of xs + multiset_of xs1 + multiset_of xs2"
  apply (induct xs arbitrary: xs1 xs2 rule: list_induct_first2)
  apply (simp_all add: ac_simps)
done

fun mergesort_by_rel_merge :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> 'a list"
where
  "mergesort_by_rel_merge R (x#xs) (y#ys) =
     (if R x y then x # mergesort_by_rel_merge R xs (y#ys) else y # mergesort_by_rel_merge R (x#xs) ys)"
| "mergesort_by_rel_merge R xs [] = xs"
| "mergesort_by_rel_merge R [] ys = ys"

declare mergesort_by_rel_merge.simps [simp del]

lemma mergesort_by_rel_merge_simps[simp] :
  "mergesort_by_rel_merge R (x#xs) (y#ys) =
     (if R x y then x # mergesort_by_rel_merge R xs (y#ys) else y # mergesort_by_rel_merge R (x#xs) ys)"
  "mergesort_by_rel_merge R xs [] = xs"
  "mergesort_by_rel_merge R [] ys = ys"
  apply (simp_all add: mergesort_by_rel_merge.simps)
  apply (cases ys) 
  apply (simp_all add: mergesort_by_rel_merge.simps)
done

lemma mergesort_by_rel_merge_induct [consumes 0, case_names Nil1 Nil2 Cons1 Cons2]:
assumes "\<And>xs::'a list. P xs []" "\<And>ys::'b list. P [] ys"
        "\<And>x xs y ys. R x y \<Longrightarrow> P xs (y # ys) \<Longrightarrow> P (x # xs) (y # ys)"
        "\<And>x xs y ys. \<not>(R x y) \<Longrightarrow> P (x # xs) ys \<Longrightarrow> P (x # xs) (y # ys)"
shows "P xs ys"
proof (induct xs arbitrary: ys)
  case Nil thus ?case using assms(2) by simp
next
  case (Cons x xs) note P_xs = this
  show ?case
  proof (induct ys)
    case Nil thus ?case using assms(1) by simp
  next
    case (Cons y ys) note P_x_xs_ys = this
    show ?case using assms(3,4)[of x y xs ys] P_x_xs_ys P_xs by metis
  qed
qed

lemma multiset_of_mergesort_by_rel_merge [simp]:
  "multiset_of (mergesort_by_rel_merge R xs ys) = multiset_of xs + multiset_of ys"
by (induct R xs ys rule: mergesort_by_rel_merge.induct) (simp_all add: ac_simps)

lemma set_mergesort_by_rel_merge [simp]:
  "set (mergesort_by_rel_merge R xs ys) = set xs \<union> set ys"
  by (induct R xs ys rule: mergesort_by_rel_merge.induct) auto

lemma sorted_by_rel_mergesort_by_rel_merge [simp]:
  assumes lin : "\<And>x y. (R x y) \<or> (R y x)"
      and trans_R: "\<And>x y z. R x y \<Longrightarrow> R y z \<Longrightarrow> R x z"
  shows  "sorted_by_rel R (mergesort_by_rel_merge R xs ys) \<longleftrightarrow> 
          sorted_by_rel R xs \<and> sorted_by_rel R ys"
proof (induct xs ys rule: mergesort_by_rel_merge_induct[where R = R]) 
  case Nil1 thus ?case by simp
next
  case Nil2 thus ?case by simp
next
  case (Cons1 x xs y ys) thus ?case 
    by (simp add: Ball_def) (metis trans_R)
next
  case (Cons2 x xs y ys) thus ?case 
    apply (auto simp add: Ball_def)
    apply (metis lin)
    apply (metis lin trans_R)
  done
qed

function mergesort_by_rel :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> 'a list"
where
  "mergesort_by_rel R xs = 
    (if length xs < 2 then xs else
     (mergesort_by_rel_merge R 
       (mergesort_by_rel R (fst (mergesort_by_rel_split ([], []) xs)))
       (mergesort_by_rel R (snd (mergesort_by_rel_split ([], []) xs)))))"
by auto
termination
  apply (relation "measure (\<lambda>(_, xs). length xs)")
  apply (simp_all add: mergesort_by_rel_split_length)
proof -
  fix xs :: "'a list"
  assume "\<not>(length xs < 2)"
  then obtain x1 x2 xs' where xs_eq: "xs = x1 # x2 # xs'"
    apply (cases xs, simp, rename_tac x1 xs0) 
    apply (case_tac xs0, simp, rename_tac x2 xs')
    apply auto
  done 
  show "length xs div 2 + length xs mod 2 < length xs" by (simp add: xs_eq)
qed

declare mergesort_by_rel.simps [simp del]

lemma mergesort_by_rel_simps [simp, code] :
  "mergesort_by_rel R [] = []"
  "mergesort_by_rel R [x] = [x]"
  "mergesort_by_rel R (x1 # x2 # xs) = 
   (let (xs1, xs2) = (mergesort_by_rel_split ([x1], [x2]) xs) in
   mergesort_by_rel_merge R (mergesort_by_rel R xs1) (mergesort_by_rel R xs2))"
apply (simp add: mergesort_by_rel.simps)
apply (simp add: mergesort_by_rel.simps)
apply (simp add: mergesort_by_rel.simps[of _ "x1 # x2 # xs"] split: prod.splits)
done

lemma mergesort_by_rel_permutes [simp]:
  "multiset_of (mergesort_by_rel R xs) = multiset_of xs"
proof (induct xs rule: length_induct)
  case (1 xs) note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis by simp
  next
    case (Cons x1 xs') note xs_eq[simp] = this
    show ?thesis
    proof (cases xs')
      case Nil thus ?thesis by simp
    next
      case (Cons x2 xs'') note xs'_eq[simp] = this

      have "length (fst (mergesort_by_rel_split ([], []) xs)) < length xs" 
           "length (snd (mergesort_by_rel_split ([], []) xs)) < length xs" 
        by (simp_all add: mergesort_by_rel_split_length)
      with ind_hyp show ?thesis 
        unfolding mergesort_by_rel.simps[of _ xs]
        by (simp add: ac_simps)
    qed
  qed
qed

lemma set_mergesort_by_rel [simp]: "set (mergesort_by_rel R xs) = set xs"
  by (simp add: set_count_greater_0)

lemma sorted_by_rel_mergesort_by_rel:
  fixes R:: "'x \<Rightarrow> 'x \<Rightarrow> bool"
  assumes lin : "\<And>x y. (R x y) \<or> (R y x)"
      and trans_R: "\<And>x y z. R x y \<Longrightarrow> R y z \<Longrightarrow> R x z"
  shows "sorted_by_rel R (mergesort_by_rel R xs)"
proof (induct xs rule: measure_induct_rule[of "length"]) 
  case (less xs)
  note ind_hyp = this

  show ?case
  proof (cases xs)
    case Nil thus ?thesis by simp
  next
    case (Cons x xs') note xs_eq[simp] = this
    thus ?thesis
    proof (cases xs')
      case Nil thus ?thesis by simp
    next
      case (Cons x2 xs'') note xs'_eq[simp] = this

      have "length (fst (mergesort_by_rel_split ([], []) xs)) < length xs" 
           "length (snd (mergesort_by_rel_split ([], []) xs)) < length xs" 
        by (simp_all add: mergesort_by_rel_split_length)
      with ind_hyp show ?thesis 
        unfolding mergesort_by_rel.simps[of _ xs]
        by (simp add: sorted_by_rel_mergesort_by_rel_merge[OF lin trans_R])
    qed
  qed
qed

lemma sorted_mergesort_by_rel:
  "sorted (mergesort_by_rel op\<le> xs)"
unfolding sorted_by_rel_linord[symmetric]
by (rule sorted_by_rel_mergesort_by_rel) auto

lemma sort_mergesort_by_rel:
  "sort = mergesort_by_rel op\<le>"
  apply (rule ext, rule properties_for_sort) 
  apply(simp_all add: sorted_mergesort_by_rel)
done


subsubsection {* Miscellaneous *}
  lemma length_compl_induct[case_names Nil Cons]: "\<lbrakk>P []; !! e l . \<lbrakk>!! ll . length ll <= length l \<Longrightarrow> P ll\<rbrakk> \<Longrightarrow> P (e#l)\<rbrakk> \<Longrightarrow> P l"
    apply(induct_tac l rule: length_induct)
    apply(case_tac "xs")
    apply(auto)
  done

  lemma list_size_conc[simp]: "list_size f (a@b) = list_size f a + list_size f b"
    by (induct a) auto


  lemma in_set_list_format: "\<lbrakk> e\<in>set l; !!l1 l2. l=l1@e#l2 \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  proof (induct l arbitrary: P)
    case Nil thus ?case by auto
  next
    case (Cons a l) show ?case proof (cases "a=e")
      case True with Cons show ?thesis by force
    next
      case False with Cons.prems(1) have "e\<in>set l" by auto
      with Cons.hyps obtain l1 l2 where "l=l1@e#l2" by blast
      hence "a#l = (a#l1)@e#l2" by simp
      with Cons.prems(2) show P by blast
    qed
  qed


  text {* Simultaneous induction over two lists, prepending an element to one of the lists in each step *}
  lemma list_2pre_induct[case_names base left right]: assumes BASE: "P [] []" and LEFT: "!!e w1' w2. P w1' w2 \<Longrightarrow> P (e#w1') w2" and RIGHT: "!!e w1 w2'. P w1 w2' \<Longrightarrow> P w1 (e#w2')" shows "P w1 w2" 
  proof -
    { -- "The proof is done by induction over the sum of the lengths of the lists"
      fix n
      have "!!w1 w2. \<lbrakk>length w1 + length w2 = n; P [] []; !!e w1' w2. P w1' w2 \<Longrightarrow> P (e#w1') w2; !!e w1 w2'. P w1 w2' \<Longrightarrow> P w1 (e#w2') \<rbrakk> \<Longrightarrow> P w1 w2 " 
        apply (induct n)
        apply simp
        apply (case_tac w1)
        apply auto
        apply (case_tac w2)
        apply auto
        done
    } from this[OF _ BASE LEFT RIGHT] show ?thesis by blast
  qed


  lemma list_decomp_1: "length l=1 \<Longrightarrow> EX a . l=[a]"
    by (case_tac l, auto)

  lemma list_decomp_2: "length l=2 \<Longrightarrow> EX a b . l=[a,b]"
    by (case_tac l, auto simp add: list_decomp_1)


  lemma drop_all_conc: "drop (length a) (a@b) = b"
    by (simp)

  lemma take_update[simp]: "take n (l[i:=x]) = (take n l)[i:=x]"
    apply (induct l arbitrary: n i)
    apply (auto split: nat.split)
    apply (case_tac n)
    apply simp_all
    apply (case_tac n)
    apply simp_all
    done

  lemma take_update_last: "length list>n \<Longrightarrow> take (Suc n) list [n:=x] = take n list @ [x]"
    by (induct list arbitrary: n)
       (auto split: nat.split)

  lemma list_rest_coinc: "\<lbrakk>length s2 <= length s1; s1@r1 = s2@r2\<rbrakk> \<Longrightarrow> EX r1p . r2=r1p@r1"
  proof -
    assume A: "length s2 <= length s1" "s1@r1 = s2@r2"
    hence "r1 = drop (length s1) (s2@r2)" by (auto simp only:drop_all_conc dest: sym)
    moreover from A have "length s1 = length s1 - length s2 + length s2" by arith
    ultimately have "r1 = drop ((length s1 - length s2)) r2" by (auto)
    hence "r2 = take ((length s1 - length s2)) r2 @ r1" by auto
    thus ?thesis by auto
  qed

  lemma list_tail_coinc: "n1#r1 = n2#r2 \<Longrightarrow> n1=n2 & r1=r2"
    by (auto)


  lemma last_in_set[intro]: "\<lbrakk>l\<noteq>[]\<rbrakk> \<Longrightarrow> last l \<in> set l"
    by (induct l) auto

  lemma map_ident_id[simp]: "map id = id" "map id x = x"
    by (unfold id_def) auto

  lemma op_conc_empty_img_id[simp]: "(op @ [] ` L) = L" by auto


  lemma distinct_match: "\<lbrakk> distinct (al@e#bl) \<rbrakk> \<Longrightarrow> (al@e#bl = al'@e#bl') \<longleftrightarrow> (al=al' \<and> bl=bl')"
  proof (rule iffI, induct al arbitrary: al')
    case Nil thus ?case by (cases al') auto
  next
    case (Cons a al) note Cprems=Cons.prems note Chyps=Cons.hyps
    show ?case proof (cases al')
      case Nil with Cprems have False by auto
      thus ?thesis ..
    next
      case (Cons a' all')[simp]
      with Cprems have [simp]: "a=a'" and P: "al@e#bl = all'@e#bl'" by auto
      from Cprems(1) have D: "distinct (al@e#bl)" by auto
      from Chyps[OF D P] have [simp]: "al=all'" "bl=bl'" by auto
      show ?thesis by simp
    qed
  qed simp


  lemma prop_match: "\<lbrakk> list_all P al; \<not>P e; \<not>P e'; list_all P bl \<rbrakk> \<Longrightarrow> (al@e#bl = al'@e'#bl') \<longleftrightarrow> (al=al' \<and> e=e' \<and> bl=bl')"
    apply (rule iffI, induct al arbitrary: al')
    apply (case_tac al', fastforce, fastforce)+
    done

  lemmas prop_matchD = rev_iffD1[OF _ prop_match[where P=P]] for P

  lemma list_match_lel_lel: "\<lbrakk>
    c1 @ qs # c2 = c1' @ qs' # c2'; 
    \<And>c21'. \<lbrakk>c1 = c1' @ qs' # c21'; c2' = c21' @ qs # c2\<rbrakk> \<Longrightarrow> P; 
    \<lbrakk>c1' = c1; qs' = qs; c2' = c2\<rbrakk> \<Longrightarrow> P;
    \<And>c21. \<lbrakk>c1' = c1 @ qs # c21; c2 = c21 @ qs' # c2'\<rbrakk> \<Longrightarrow> P
    \<rbrakk> \<Longrightarrow> P"
    apply (auto simp add: append_eq_append_conv2)
    apply (case_tac us)
    apply auto
    apply (case_tac us)
    apply auto
    done

  lemma distinct_tl[simp]: "l\<noteq>[] \<Longrightarrow> distinct l \<Longrightarrow> distinct (tl l)"
    by (cases l) auto

lemma xy_in_set_cases[consumes 2, case_names EQ XY YX]:
  assumes A: "x\<in>set l" "y\<in>set l"
  and C:
  "!!l1 l2. \<lbrakk> x=y; l=l1@y#l2 \<rbrakk> \<Longrightarrow> P"
  "!!l1 l2 l3. \<lbrakk> x\<noteq>y; l=l1@x#l2@y#l3 \<rbrakk> \<Longrightarrow> P"
  "!!l1 l2 l3. \<lbrakk> x\<noteq>y; l=l1@y#l2@x#l3 \<rbrakk> \<Longrightarrow> P"
  shows P
proof (cases "x=y")
  case True with A(1) obtain l1 l2 where "l=l1@y#l2" by (blast dest: split_list)
  with C(1) True show ?thesis by blast
next
  case False
  from A(1) obtain l1 l2 where S1: "l=l1@x#l2" by (blast dest: split_list)
  from A(2) obtain l1' l2' where S2: "l=l1'@y#l2'" by (blast dest: split_list)
  from S1 S2 have M: "l1@x#l2 = l1'@y#l2'" by simp
  thus P proof (cases rule: list_match_lel_lel[consumes 1, case_names 1 2 3])
    case (1 c) with S1 have "l=l1'@y#c@x#l2" by simp
    with C(3) False show ?thesis by blast
  next
    case 2 with False have False by blast
    thus ?thesis ..
  next
    case (3 c) with S1 have "l=l1@x#c@y#l2'" by simp
    with C(2) False show ?thesis by blast
  qed
qed


    (* Placed here because it depends on xy_in_set_cases *)
lemma distinct_map_eq: "\<lbrakk> distinct (List.map f l); f x = f y; x\<in>set l; y\<in>set l \<rbrakk> \<Longrightarrow> x=y"
  by (erule (2) xy_in_set_cases) auto


-- {* Congruence rules for @{const list_all} and @{const list_ex} *}
lemma list_all_cong[fundef_cong]: "\<lbrakk> xs=ys; !!x. x\<in>set ys \<Longrightarrow> f x \<longleftrightarrow> g x \<rbrakk> \<Longrightarrow> list_all f xs = list_all g ys"
  apply (induct xs arbitrary: ys)
  apply auto
  done

lemma list_ex_cong[fundef_cong]: "\<lbrakk> xs=ys; !!x. x\<in>set ys \<Longrightarrow> f x \<longleftrightarrow> g x \<rbrakk> \<Longrightarrow> list_ex f xs = list_ex g ys"
  apply (induct xs arbitrary: ys)
  apply auto
  done


lemma lists_image_witness:
  assumes A: "x\<in>lists (f`Q)"
  obtains xo where "xo\<in>lists Q" "x=map f xo"
proof - 
  have "\<lbrakk> x\<in>lists (f`Q) \<rbrakk> \<Longrightarrow> \<exists>xo\<in>lists Q. x=map f xo"
  proof (induct x)
    case Nil thus ?case by auto
  next
    case (Cons x xs)
    then obtain xos where "xos\<in>lists Q" "xs=map f xos" by force
    moreover from Cons.prems have "x\<in>f`Q" by auto
    then obtain xo where "xo\<in>Q" "x=f xo" by auto
    ultimately show ?case
      by (rule_tac x="xo#xos" in bexI) auto
  qed
  thus ?thesis
    apply (simp_all add: A)
    apply (erule_tac bexE)
    apply (rule_tac that)
    apply assumption+
    done
qed

lemma map_of_None_filterD:
  "map_of xs x = None \<Longrightarrow> map_of (filter P xs) x = None"
by(induct xs) auto

lemma map_of_concat: "map_of (concat xss) = foldr (\<lambda>xs f. f ++ map_of xs) xss empty"
by(induct xss) simp_all

lemma map_of_Some_split:
  "map_of xs k = Some v \<Longrightarrow> \<exists>ys zs. xs = ys @ (k, v) # zs \<and> map_of ys k = None"
proof(induct xs)
  case (Cons x xs)
  obtain k' v' where x: "x = (k', v')" by(cases x)
  show ?case
  proof(cases "k' = k")
    case True
    with `map_of (x # xs) k = Some v` x have "x # xs = [] @ (k, v) # xs" "map_of [] k = None" by simp_all
    thus ?thesis by blast
  next
    case False
    with `map_of (x # xs) k = Some v` x
    have "map_of xs k = Some v" by simp
    from `map_of xs k = Some v \<Longrightarrow> \<exists>ys zs. xs = ys @ (k, v) # zs \<and> map_of ys k = None`[OF this]
    obtain ys zs where "xs = ys @ (k, v) # zs" "map_of ys k = None" by blast
    with False x have "x # xs = (x # ys) @ (k, v) # zs" "map_of (x # ys) k = None" by simp_all
    thus ?thesis by blast
  qed
qed simp

lemma map_add_find_left:
  "g k = None \<Longrightarrow> (f ++ g) k = f k"
by(simp add: map_add_def)

lemma map_add_left_None:
  "f k = None \<Longrightarrow> (f ++ g) k = g k"
by(simp add: map_add_def split: option.split)

lemma map_of_Some_filter_not_in:
  "\<lbrakk> map_of xs k = Some v; \<not> P (k, v); distinct (map fst xs) \<rbrakk> \<Longrightarrow> map_of (filter P xs) k = None"
apply(induct xs)
apply(auto)
apply(auto simp add: map_of_eq_None_iff)
done

lemma distinct_map_fst_filterI: "distinct (map fst xs) \<Longrightarrow> distinct (map fst (filter P xs))"
by(induct xs) auto

lemma distinct_map_fstD: "\<lbrakk> distinct (map fst xs); (x, y) \<in> set xs; (x, z) \<in> set xs \<rbrakk> \<Longrightarrow> y = z"
by(induct xs)(fastforce elim: notE rev_image_eqI)+


lemma drop_eq_ConsD: "drop n xs = x # xs' \<Longrightarrow> drop (Suc n) xs = xs'"
by(induct xs arbitrary: n)(simp_all add: drop_Cons split: nat.split_asm)

lemma concat_filter_neq_Nil:
  "concat [ys\<leftarrow>xs. ys \<noteq> Nil] = concat xs"
by(induct xs) simp_all

lemma distinct_concat': 
  "\<lbrakk>distinct [ys\<leftarrow>xs. ys \<noteq> Nil]; \<And>ys. ys \<in> set xs \<Longrightarrow> distinct ys;
   \<And>ys zs. \<lbrakk>ys \<in> set xs; zs \<in> set xs; ys \<noteq> zs\<rbrakk> \<Longrightarrow> set ys \<inter> set zs = {}\<rbrakk>
  \<Longrightarrow> distinct (concat xs)"
by(erule distinct_concat[of "[ys\<leftarrow>xs. ys \<noteq> Nil]", unfolded concat_filter_neq_Nil]) auto

lemma replicate_Suc_conv_snoc:
  "replicate (Suc n) x = replicate n x @ [x]"
by (metis replicate_Suc replicate_append_same)


lemma filter_nth_ex_nth:
  assumes "n < length (filter P xs)"
  shows "\<exists>m. n \<le> m \<and> m < length xs \<and> filter P xs ! n = xs ! m \<and> filter P (take m xs) = take n (filter P xs)"
using assms
proof(induct xs rule: rev_induct)
  case Nil thus ?case by simp
next
  case (snoc x xs)
  show ?case
  proof(cases "P x")
    case False[simp]
    from `n < length (filter P (xs @ [x]))` have "n < length (filter P xs)" by simp
    hence "\<exists>m\<ge>n. m < length xs \<and> filter P xs ! n = xs ! m \<and> filter P (take m xs) = take n (filter P xs)" by(rule snoc)
    thus ?thesis by(auto simp add: nth_append)
  next
    case True[simp]
    show ?thesis
    proof(cases "n = length (filter P xs)")
      case False
      with `n < length (filter P (xs @ [x]))` have "n < length (filter P xs)" by simp
      moreover hence "\<exists>m\<ge>n. m < length xs \<and> filter P xs ! n = xs ! m \<and> filter P (take m xs) = take n (filter P xs)"
        by(rule snoc)
      ultimately show ?thesis by(auto simp add: nth_append)
    next
      case True[simp]
      hence "filter P (xs @ [x]) ! n = (xs @ [x]) ! length xs" by simp
      moreover have "length xs < length (xs @ [x])" by simp
      moreover have "length xs \<ge> n" by simp
      moreover have "filter P (take (length xs) (xs @ [x])) = take n (filter P (xs @ [x]))" by simp
      ultimately show ?thesis by blast
    qed
  qed
qed

lemma set_map_filter: 
  "set (List.map_filter g xs) = {y. \<exists>x. x \<in> set xs \<and> g x = Some y}"
  by (induct xs) (auto simp add: List.map_filter_def set_eq_iff)

subsection {* Induction on nat *}
  lemma nat_compl_induct[case_names 0 Suc]: "\<lbrakk>P 0; !! n . ALL nn . nn <= n \<longrightarrow> P nn \<Longrightarrow> P (Suc n)\<rbrakk> \<Longrightarrow> P n"
    apply(induct_tac n rule: nat_less_induct)
    apply(case_tac n)
    apply(auto)
  done

  lemma nat_compl_induct'[case_names 0 Suc]: "\<lbrakk>P 0; !! n . \<lbrakk>!! nn . nn \<le> n \<Longrightarrow> P nn\<rbrakk> \<Longrightarrow> P (Suc n)\<rbrakk> \<Longrightarrow> P n"
    apply(induct_tac n rule: nat_less_induct)
    apply(case_tac n)
    apply(auto)
  done


subsection {* Functions of type @{typ "bool\<Rightarrow>bool"}*}
  lemma boolfun_cases_helper: "g=(\<lambda>x. False) | g=(\<lambda>x. x) | g=(\<lambda>x. True) | g= (\<lambda>x. \<not>x)" 
  proof -
    { assume "g False" "g True"
      hence "g = (\<lambda>x. True)" by (rule_tac ext, case_tac x, auto)
    } moreover {
      assume "g False" "\<not>g True"
      hence "g = (\<lambda>x. \<not>x)" by (rule_tac ext, case_tac x, auto)
    } moreover {
      assume "\<not>g False" "g True"
      hence "g = (\<lambda>x. x)" by (rule_tac ext, case_tac x, auto)
    } moreover {
      assume "\<not>g False" "\<not>g True"
      hence "g = (\<lambda>x. False)" by (rule_tac ext, case_tac x, auto)
    } ultimately show ?thesis by fast
  qed

  lemma boolfun_cases[case_names False Id True Neg]: "\<lbrakk>g=(\<lambda>x. False) \<Longrightarrow> P g; g=(\<lambda>x. x) \<Longrightarrow> P g; g=(\<lambda>x. True) \<Longrightarrow> P g; g=(\<lambda>x. \<not>x) \<Longrightarrow> P g\<rbrakk> \<Longrightarrow> P g"
  proof -
    note boolfun_cases_helper[of g]
    moreover assume "g=(\<lambda>x. False) \<Longrightarrow> P g" "g=(\<lambda>x. x) \<Longrightarrow> P g" "g=(\<lambda>x. True) \<Longrightarrow> P g" "g=(\<lambda>x. \<not>x) \<Longrightarrow> P g"
    ultimately show ?thesis by fast
  qed


subsection {* Definite and indefinite description *}
        text "Combined definite and indefinite description for binary predicate"
  lemma some_theI: assumes EX: "\<exists>a b . P a b" and BUN: "!! b1 b2 . \<lbrakk>\<exists>a . P a b1; \<exists>a . P a b2\<rbrakk> \<Longrightarrow> b1=b2" 
    shows "P (SOME a . \<exists>b . P a b) (THE b . \<exists>a . P a b)"
  proof -
                from EX have "EX b . P (SOME a . EX b . P a b) b" by (rule someI_ex)
                moreover from EX have "EX b . EX a . P a b" by blast
    with BUN theI'[of "\<lambda>b . EX a . P a b"] have "EX a . P a (THE b . EX a . P a b)" by (unfold Ex1_def, blast)
                moreover note BUN
                ultimately show ?thesis by (fast)
        qed

  lemma some_insert_self[simp]: "S\<noteq>{} \<Longrightarrow> insert (SOME x. x\<in>S) S = S"
    by (auto intro: someI)

  lemma some_elem[simp]: "S\<noteq>{} \<Longrightarrow> (SOME x. x\<in>S) \<in> S"
    by (auto intro: someI)
  
subsubsection{* Hilbert Choice with option *}

definition Eps_Opt where
  "Eps_Opt P = (if (\<exists>x. P x) then Some (SOME x. P x) else None)"

lemma some_opt_eq_trivial[simp] :
  "Eps_Opt (\<lambda>y. y = x) = Some x"
unfolding Eps_Opt_def by simp

lemma some_opt_sym_eq_trivial[simp] :
  "Eps_Opt (op = x) = Some x"
unfolding Eps_Opt_def by simp

lemma some_opt_false_trivial[simp] :
  "Eps_Opt (\<lambda>_. False) = None"
unfolding Eps_Opt_def by simp

lemma Eps_Opt_eq_None[simp] :
  "Eps_Opt P = None \<longleftrightarrow> \<not>(Ex P)"
unfolding Eps_Opt_def by simp

lemma Eps_Opt_eq_Some_implies :
  "Eps_Opt P = Some x \<Longrightarrow> P x"
unfolding Eps_Opt_def 
by (metis option.inject option.simps(2) someI_ex)

lemma Eps_Opt_eq_Some :
assumes P_prop: "\<And>x'. P x \<Longrightarrow> P x' \<Longrightarrow> x' = x"
shows "Eps_Opt P = Some x \<longleftrightarrow> P x"
using P_prop
unfolding Eps_Opt_def 
by (metis option.inject option.simps(2) someI_ex)




subsection {* Directed Graphs and Relations *}
  subsubsection "Reflexive-Transitive Closure"
  lemma r_le_rtrancl[simp]: "S\<subseteq>S\<^sup>*" by auto
  lemma rtrancl_mono_rightI: "S\<subseteq>S' \<Longrightarrow> S\<subseteq>S'\<^sup>*" by auto

  text {* A path in a graph either does not use nodes from S at all, or it has a prefix leading to a node in S and a suffix that does not use nodes in S *}
  lemma rtrancl_last_visit[cases set, case_names no_visit last_visit_point]: 
    shows
    "\<lbrakk> (q,q')\<in>R\<^sup>*; 
       (q,q')\<in>(R-UNIV\<times>S)\<^sup>* \<Longrightarrow> P; 
       !!qt. \<lbrakk> qt\<in>S; (q,qt)\<in>R\<^sup>+; (qt,q')\<in>(R-UNIV\<times>S)\<^sup>* \<rbrakk> \<Longrightarrow> P 
     \<rbrakk> \<Longrightarrow> P"
  proof (induct rule: converse_rtrancl_induct[case_names refl step])
    case refl thus ?case by auto
  next
    case (step q qh)
    show P proof (rule step.hyps(3))
      assume A: "(qh,q')\<in>(R-UNIV\<times>S)\<^sup>*"
      show P proof (cases "qh\<in>S")
        case False 
        with step.hyps(1) A have "(q,q')\<in>(R-UNIV\<times>S)\<^sup>*" 
          by (auto intro: converse_rtrancl_into_rtrancl)
        with step.prems(1) show P .
      next
        case True
        from step.hyps(1) have "(q,qh)\<in>R\<^sup>+" by auto
        with step.prems(2) True A show P by blast
      qed
    next
      fix qt
      assume A: "qt\<in>S" "(qh,qt)\<in>R\<^sup>+" "(qt,q')\<in>(R-UNIV\<times>S)\<^sup>*"
      with step.hyps(1) have "(q,qt)\<in>R\<^sup>+" by auto
      with step.prems(2) A(1,3) show P by blast
    qed
  qed

  text {* Less general version of @{text rtrancl_last_visit}, but there's a short automatic proof *}
  lemma rtrancl_last_visit': "\<lbrakk> (q,q')\<in>R\<^sup>*; (q,q')\<in>(R-UNIV\<times>S)\<^sup>* \<Longrightarrow> P; !!qt. \<lbrakk> qt\<in>S; (q,qt)\<in>R\<^sup>*; (qt,q')\<in>(R-UNIV\<times>S)\<^sup>* \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (induct rule: converse_rtrancl_induct) (auto intro: converse_rtrancl_into_rtrancl)

  text {* Find last point where a path touches a set *}
  lemma rtrancl_last_touch: "\<lbrakk> (q,q')\<in>R\<^sup>*; q\<in>S; !!qt. \<lbrakk> qt\<in>S; (q,qt)\<in>R\<^sup>*; (qt,q')\<in>(R-UNIV\<times>S)\<^sup>* \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (erule rtrancl_last_visit') auto

  lemma rtrancl_image_advance: "\<lbrakk>q\<in>R\<^sup>* `` Q0; (q,x)\<in>R\<rbrakk> \<Longrightarrow> x\<in>R\<^sup>* `` Q0"
    by (auto intro: rtrancl_into_rtrancl)

  subsubsection "Converse Relation"
  lemma converse_subset[simp]: "G\<inverse> \<subseteq> H\<inverse> \<longleftrightarrow> G\<subseteq>H"
    by auto

  (* [simp] - candidate *)
  lemma Sigma_converse: "(A\<times>B)\<inverse> = B\<times>A" by auto

  lemmas converse_add_simps = Sigma_converse trancl_converse[symmetric] converse_Un converse_Int


  subsubsection "Cyclicity"
  lemma acyclic_union: 
    "acyclic (A\<union>B) \<Longrightarrow> acyclic A" 
    "acyclic (A\<union>B) \<Longrightarrow> acyclic B" 
    by (metis Un_upper1 Un_upper2 acyclic_subset)+

  lemma cyclicE: "\<lbrakk>\<not>acyclic g; !!x. (x,x)\<in>g\<^sup>+ \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (unfold acyclic_def) blast
  
  lemma acyclic_empty[simp, intro!]: "acyclic {}" by (unfold acyclic_def) auto

  lemma acyclic_insert_cyclic: "\<lbrakk>acyclic g; \<not>acyclic (insert (x,y) g)\<rbrakk> \<Longrightarrow> (y,x)\<in>g\<^sup>*"
    by (unfold acyclic_def) (auto simp add: trancl_insert)
  

  text {*
    This lemma makes a case distinction about a path in a graph where a couple of edges with the same 
    endpoint have been inserted: If there is a path from a to b, then there's such a path in the original graph, or 
    there's a path that uses an inserted edge only once.

    Originally, this lemma was used to reason about the graph of an updated acquisition history. Any path in 
    this graph is either already contained in the original graph, or passes via an 
    inserted edge. Because all the inserted edges point to the same target node, in the
    second case, the path can be short-circuited to use exactly one inserted edge.
    *}
  lemma trancl_multi_insert[cases set, case_names orig via]: 
    "\<lbrakk> (a,b)\<in>(r\<union>X\<times>{m})\<^sup>+; 
      (a,b)\<in>r\<^sup>+ \<Longrightarrow> P; 
       !!x. \<lbrakk> x\<in>X; (a,x)\<in>r\<^sup>*; (m,b)\<in>r\<^sup>* \<rbrakk> \<Longrightarrow> P 
    \<rbrakk> \<Longrightarrow> P"
  proof (induct arbitrary: P rule: trancl_induct)
    case (base b) thus ?case by auto
  next
    case (step b c) show ?case proof (rule step.hyps(3))
      assume A: "(a,b)\<in>r\<^sup>+" 
      note step.hyps(2) 
      moreover {
        assume "(b,c)\<in>r" 
        with A have "(a,c)\<in>r\<^sup>+" by auto 
        with step.prems have P by blast
      } moreover {
        assume "b\<in>X" "c=m"
        with A have P by (rule_tac step.prems(2)) simp+
      } ultimately show P by auto
    next
      fix x
      assume A: "x \<in> X" "(a, x) \<in> r\<^sup>*" "(m, b) \<in> r\<^sup>*"
      note step.hyps(2) 
      moreover {
        assume "(b,c)\<in>r" 
        with A(3) have "(m,c)\<in>r\<^sup>*" by auto 
        with step.prems(2)[OF A(1,2)] have P by blast
      } moreover {
        assume "b\<in>X" "c=m"
        with A have P by (rule_tac step.prems(2)) simp+
      } ultimately show P by auto
    qed
  qed

  text {*
    Version of @{thm [source] trancl_multi_insert} for inserted edges with the same startpoint.
    *}
  lemma trancl_multi_insert2[cases set, case_names orig via]: 
    "\<lbrakk>(a,b)\<in>(r\<union>{m}\<times>X)\<^sup>+; (a,b)\<in>r\<^sup>+ \<Longrightarrow> P; !!x. \<lbrakk> x\<in>X; (a,m)\<in>r\<^sup>*; (x,b)\<in>r\<^sup>* \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  proof -
    case goal1 from goal1(1) have "(b,a)\<in>((r\<union>{m}\<times>X)\<^sup>+)\<inverse>" by simp
    also have "((r\<union>{m}\<times>X)\<^sup>+)\<inverse> = (r\<inverse>\<union>X\<times>{m})\<^sup>+" by (simp add: converse_add_simps)
    finally have "(b, a) \<in> (r\<inverse> \<union> X \<times> {m})\<^sup>+" .
    thus ?case 
      by (auto elim!: trancl_multi_insert 
               intro: goal1(2,3) 
            simp add: trancl_converse rtrancl_converse
    )
  qed

  
  subsubsection {* Wellfoundedness *}
  lemma wf_min: assumes A: "wf R" "R\<noteq>{}" "!!m. m\<in>Domain R - Range R \<Longrightarrow> P" shows P proof -
    have H: "!!x. wf R \<Longrightarrow> \<forall>y. (x,y)\<in>R \<longrightarrow> x\<in>Domain R - Range R \<or> (\<exists>m. m\<in>Domain R - Range R)"
      by (erule_tac wf_induct_rule[where P="\<lambda>x. \<forall>y. (x,y)\<in>R \<longrightarrow> x\<in>Domain R - Range R \<or> (\<exists>m. m\<in>Domain R - Range R)"]) auto
    from A(2) obtain x y where "(x,y)\<in>R" by auto
    with A(1,3) H show ?thesis by blast
  qed

  lemma finite_wf_eq_wf_converse: "finite R \<Longrightarrow> wf (R\<inverse>) \<longleftrightarrow> wf R" 
    by (metis acyclic_converse finite_acyclic_wf finite_acyclic_wf_converse wf_acyclic)
  
  lemma wf_max: assumes A: "wf (R\<inverse>)" "R\<noteq>{}" and C: "!!m. m\<in>Range R - Domain R \<Longrightarrow> P" shows "P"
  proof -
    from A(2) have NE: "R\<inverse>\<noteq>{}" by auto
    from wf_min[OF A(1) NE] obtain m where "m\<in>Range R - Domain R" by auto
    thus P by (blast intro: C)
  qed

    -- "Useful lemma to show well-foundedness of some process approaching a finite upper bound"
  lemma wf_bounded_supset: "finite S \<Longrightarrow> wf {(Q',Q). Q'\<supset>Q \<and> Q'\<subseteq> S}"
  proof -
    assume [simp]: "finite S"
    hence [simp]: "!!x. finite (S-x)" by auto
    have "{(Q',Q). Q\<subset>Q' \<and> Q'\<subseteq> S} \<subseteq> inv_image ({(s'::nat,s). s'<s}) (\<lambda>Q. card (S-Q))"
    proof (intro subsetI, case_tac x, simp)
      fix a b
      assume A: "b\<subset>a \<and> a\<subseteq>S"
      hence "S-a \<subset> S-b" by blast
      thus "card (S-a) < card (S-b)" by (auto simp add: psubset_card_mono)
    qed
    moreover have "wf ({(s'::nat,s). s'<s})" by (rule wf_less)
    ultimately show ?thesis by (blast intro: wf_inv_image wf_subset)
  qed

  lemma lex_prod_fstI: "\<lbrakk> (fst a, fst b)\<in>r \<rbrakk> \<Longrightarrow> (a,b)\<in>r<*lex*>s"
    apply (cases a, cases b)
    apply auto
    done

  lemma lex_prod_sndI: "\<lbrakk> fst a = fst b; (snd a, snd b)\<in>s \<rbrakk> \<Longrightarrow> (a,b)\<in>r<*lex*>s"
    apply (cases a, cases b)
    apply auto
    done



  subsubsection {* Miscellaneous *}

  lemma Image_empty[simp]: "{} `` X = {}"
    by auto

  lemma Image_subseteq_Range: fixes R shows "R``A \<subseteq> Range R"
    by auto

  lemma finite_Range: fixes R shows "finite R \<Longrightarrow> finite (Range R)"
  proof -
    assume "finite R"
    hence "finite (snd ` R)" by auto
    also have "snd ` R = Range R" by force
    finally show ?thesis .
  qed

  lemma finite_Image: fixes R shows "\<lbrakk> finite R \<rbrakk> \<Longrightarrow> finite (R `` A)"
    by (rule finite_subset[OF Image_subseteq_Range finite_Range])

  lemma finite_rtrancl_Image: 
    fixes R
    shows "\<lbrakk> finite R; finite A \<rbrakk> \<Longrightarrow> finite ((R\<^sup>*) `` A)"
  proof -
    assume A: "finite R" "finite A"
    have "(R\<^sup>* `` A) \<subseteq> Range R \<union> A"
    proof safe
      case goal1 thus ?case by (induct rule: rtrancl_induct) auto
    qed
    thus ?thesis
      apply (erule_tac finite_subset)
      apply (simp add: A finite_Range)
      done
  qed


subsection {* Ordering on @{text "option"}-Datatype *}
  text {*
    We lift any ordering relation on the option datatype, with @{text None} as the smallest element.
    *}

  instantiation option :: (ord) ord
  begin
  definition
    le_option_def: "a \<le> b \<longleftrightarrow> (case a of None \<Rightarrow> True | Some aa \<Rightarrow> (case b of None \<Rightarrow> False | Some bb \<Rightarrow> aa\<le>bb))"

  definition
    less_option_def: "(a\<Colon>'a option) < b \<longleftrightarrow> a \<le> b \<and> a \<noteq> b"

  lemma None_least[simp]: 
    "None \<le> b"
    "None < b \<longleftrightarrow> b\<noteq>None"
    "None < Some bb"
    "a\<le>None \<longleftrightarrow> a=None"
    "\<not> (a<None)"
    apply (unfold le_option_def less_option_def) 
    apply (auto split: option.split_asm)
    apply (cases b)
    apply auto
    done

  lemma Some_simps[simp]:
    "Some a \<le> Some b \<longleftrightarrow> a \<le> b"
    by (auto simp add: le_option_def less_option_def split: option.split_asm)

  lemma le_some_optE: "\<lbrakk>Some m\<le>x; !!m'. \<lbrakk>x=Some m'; m\<le>m'\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (cases x) auto

  lemma le_some_optI: "m\<le>m' \<Longrightarrow> Some m \<le> Some m'" by simp


  lemma le_optI: 
    "\<lbrakk> a=None \<rbrakk> \<Longrightarrow> a\<le>b"
    "\<lbrakk> a=Some x; b=Some y; x\<le>y \<rbrakk> \<Longrightarrow> a\<le>b"
    by auto
    
  lemma le_optE: "\<lbrakk> a\<le>b; a=None \<Longrightarrow> P; !!x y. \<lbrakk>a=Some x; b=Some y; x\<le>y\<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    apply (cases a, cases b)
    apply auto
    apply (cases b)
    apply auto
    done

  instance ..
  end

  instantiation option :: (order) order
  begin
    instance by default (auto simp add: le_option_def less_option_def split: option.split_asm option.split)

  lemma Some_simps2[simp]:
    "Some a < Some b \<longleftrightarrow> a < (b::'a::order)"
    by (auto simp add: le_option_def less_option_def split: option.split_asm)

  lemma less_optE: "\<lbrakk>Some (m::'a::order)<x; !!m'. \<lbrakk>x=Some m'; m<m'\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
    by (cases x) auto

  lemma less_optI: "(m::'a::order)\<le>m' \<Longrightarrow> Some m \<le> Some m'" by simp
  end

subsection "Ordering on Pair"

instantiation prod :: (ord, ord) ord
begin
  fun less_eq_prod_aux where "less_eq_prod_aux (a1,a2) (b1,b2) = (a1<b1 \<or> (a1=b1 \<and> a2 \<le> b2))"

  definition less_eq_prod_def: "a\<le>b == less_eq_prod_aux a b"
  definition less_prod_def: "a<b == a\<noteq>b \<and> less_eq_prod_aux a b"

  instance ..
end

instance prod :: (order, order) order
  apply intro_classes
  apply (unfold less_eq_prod_def less_prod_def)
  apply (auto dest: less_trans)
  done

instance prod :: (linorder, linorder) linorder
  apply intro_classes
  apply (unfold less_eq_prod_def less_prod_def)
  apply auto
  done

subsection "Maps"

  lemma map_add_dom_app_simps[simp]:
    "\<lbrakk> m\<in>dom l2 \<rbrakk> \<Longrightarrow> (l1++l2) m = l2 m"
    "\<lbrakk> m\<notin>dom l1 \<rbrakk> \<Longrightarrow> (l1++l2) m = l2 m" 
    "\<lbrakk> m\<notin>dom l2 \<rbrakk> \<Longrightarrow> (l1++l2) m = l1 m" 
    by (auto simp add: map_add_def split: option.split_asm)

  lemma map_add_upd2[simp]: "m\<notin>dom e2 \<Longrightarrow> e1(m \<mapsto> u1) ++ e2 = (e1 ++ e2)(m \<mapsto> u1)"
    apply (unfold map_add_def)
    apply (rule ext)
    apply (auto split: option.split)
    done

  lemma ran_add[simp]: "dom f \<inter> dom g = {} \<Longrightarrow> ran (f++g) = ran f \<union> ran g" by (fastforce simp add: ran_def map_add_def split: option.split_asm option.split)

  lemma dom_empty_simp[simp]: "dom l = {} \<longleftrightarrow> l=empty"
    by (auto simp add: dom_def intro: ext)
  
  lemma nempty_dom: "\<lbrakk>e\<noteq>empty; !!m. m\<in>dom e \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
    by (subgoal_tac "dom e \<noteq> {}") (blast, auto)

  lemma map_add_empty[simp]:
    "(empty = f++g) \<longleftrightarrow> f=empty \<and> g=empty"
    "(f++g = empty) \<longleftrightarrow> f=empty \<and> g=empty"
    apply (safe)
    apply (rule ext, drule_tac x=x in fun_cong, simp add: map_add_def split: option.split_asm)
    apply (rule ext, drule_tac x=x in fun_cong, simp add: map_add_def split: option.split_asm)
    apply simp
    apply (rule ext, drule_tac x=x in fun_cong, simp add: map_add_def split: option.split_asm)
    apply (rule ext, drule_tac x=x in fun_cong, simp add: map_add_def split: option.split_asm)
    apply simp
    done


  lemma le_map_dom_mono: "m\<le>m' \<Longrightarrow> dom m \<subseteq> dom m'"
    apply (safe)
    apply (drule_tac x=x in le_funD)
    apply simp
    apply (erule le_some_optE)
    apply simp
    done

  lemma map_add_first_le: fixes m::"'a\<rightharpoonup>('b::order)" shows "\<lbrakk> m\<le>m' \<rbrakk> \<Longrightarrow> m++n \<le> m'++n"
    apply (rule le_funI)
    apply (auto simp add: map_add_def split: option.split elim: le_funE)
    done

  lemma map_add_distinct_le: shows "\<lbrakk> m\<le>m'; n\<le>n'; dom m' \<inter> dom n' = {} \<rbrakk> \<Longrightarrow> m++n \<le> m'++n'"
    apply (rule le_funI)
    apply (auto simp add: map_add_def split: option.split)
    apply (fastforce elim: le_funE)
    apply (drule le_map_dom_mono)
    apply (drule le_map_dom_mono)
    apply (case_tac "m x")
    apply simp
    apply (force)
    apply (fastforce dest!: le_map_dom_mono)
    apply (erule le_funE)
    apply (erule_tac x=x in le_funE)
    apply simp
    done

  lemma map_add_left_comm: assumes A: "dom A \<inter> dom B = {}" shows "A ++ (B ++ C) = B ++ (A ++ C)"
  proof -
    have "A ++ (B ++ C) = (A++B)++C" by simp
    also have "\<dots> = (B++A)++C" by (simp add: map_add_comm[OF A])
    also have "\<dots> = B++(A++C)" by simp
    finally show ?thesis .
  qed
  lemmas map_add_ac = map_add_assoc map_add_comm map_add_left_comm

  lemma le_map_restrict[simp]: fixes m :: "'a \<rightharpoonup> ('b::order)" shows "m |` X \<le> m"
    by (rule le_funI) (simp add: restrict_map_def)



subsection{* Connection between Maps and Sets of Key-Value Pairs *}

definition map_to_set where
  "map_to_set m = {(k, v) . m k = Some v}"

definition set_to_map where
  "set_to_map S k = Eps_Opt (\<lambda>v. (k, v) \<in> S)"

lemma set_to_map_simp :
assumes inj_on_fst: "inj_on fst S"
shows "(set_to_map S k = Some v) \<longleftrightarrow> (k, v) \<in> S"
proof (cases "\<exists>v. (k, v) \<in> S")
  case True 
  note kv_ex = this
  then obtain v' where kv'_in: "(k, v') \<in> S" by blast

  with inj_on_fst have kv''_in: "\<And>v''. (k, v'') \<in> S \<longleftrightarrow> v' = v''"
    unfolding inj_on_def Ball_def
    by auto

  show ?thesis
    unfolding set_to_map_def 
    by (simp add: kv_ex kv''_in)
next
  case False
  hence kv''_nin: "\<And>v''. (k, v'') \<notin> S" by simp
  thus ?thesis
    by (simp add: set_to_map_def)
qed

lemma inj_on_fst_map_to_set :
  "inj_on fst (map_to_set m)"
unfolding map_to_set_def inj_on_def by simp

lemma map_to_set_inverse :
   "set_to_map (map_to_set m) = m"
proof
  fix k
  show "set_to_map (map_to_set m) k = m k"
  proof (cases "m k")
    case None note mk_eq = this
    hence "\<And>v. (k, v) \<notin> map_to_set m" 
      unfolding map_to_set_def by simp
    with set_to_map_simp [OF inj_on_fst_map_to_set, of m k]
    show ?thesis unfolding mk_eq by auto
  next
    case (Some v) note mk_eq = this
    hence "(k, v) \<in> map_to_set m" 
      unfolding map_to_set_def by simp
    with set_to_map_simp [OF inj_on_fst_map_to_set, of m k v]
    show ?thesis unfolding mk_eq by auto
  qed
qed

lemma set_to_map_inverse :
assumes inj_on_fst_S: "inj_on fst S"
shows "map_to_set (set_to_map S) = S"
proof (rule set_eqI)
  fix kv
  from set_to_map_simp [OF inj_on_fst_S, of "fst kv" "snd kv"]
  show "(kv \<in> map_to_set (set_to_map S)) = (kv \<in> S)"
    unfolding map_to_set_def
    by auto
qed

lemma map_to_set_empty[simp]: "map_to_set empty = {}"
  unfolding map_to_set_def by simp

lemma set_to_map_empty[simp]: "set_to_map {} = empty"
  unfolding set_to_map_def[abs_def] by simp

lemma map_to_set_empty_iff: "map_to_set m = {} \<longleftrightarrow> m = Map.empty"
                            "{} = map_to_set m \<longleftrightarrow> m = Map.empty"
  unfolding map_to_set_def by auto

lemma set_to_map_empty_iff: "set_to_map S = Map.empty \<longleftrightarrow> S = {}" (is ?T1)
                            "Map.empty = set_to_map S \<longleftrightarrow> S = {}" (is ?T2)
proof -
  show T1: ?T1
    apply (simp only: set_eq_iff) 
    apply (simp only: fun_eq_iff) 
    apply (simp add: set_to_map_def)
    apply auto
  done
  from T1 show ?T2 by auto
qed

lemma map_to_set_upd[simp]: "map_to_set (m (k \<mapsto> v)) = insert (k, v) (map_to_set m - {(k, v') |v'. True})"
  unfolding map_to_set_def 
  apply (simp add: set_eq_iff)
  apply metis
done

lemma set_to_map_insert: 
assumes k_nin: "fst kv \<notin> fst ` S"
shows "set_to_map (insert kv S) = (set_to_map S) (fst kv \<mapsto> snd kv)"
proof 
  fix k'
  obtain k v where kv_eq[simp]: "kv = (k, v)" by (rule PairE)

  from k_nin have k_nin': "\<And>v'. (k, v') \<notin> S" 
    by (auto simp add: image_iff Ball_def)

  show "set_to_map (insert kv S) k' = (set_to_map S(fst kv \<mapsto> snd kv)) k'"
    by (simp add: set_to_map_def k_nin')
qed

lemma map_to_set_dom :
  "dom m = fst ` (map_to_set m)"
unfolding dom_def map_to_set_def
by (auto simp add: image_iff)

lemma map_to_set_ran :
  "ran m = snd ` (map_to_set m)"
unfolding ran_def map_to_set_def
by (auto simp add: image_iff)

lemma set_to_map_dom :
  "dom (set_to_map S) = fst ` S"
unfolding set_to_map_def[abs_def] dom_def
by (auto simp add: image_iff Bex_def)

lemma set_to_map_ran :
  "ran (set_to_map S) \<subseteq> snd ` S"
unfolding set_to_map_def[abs_def] ran_def subset_iff
by (auto simp add: image_iff Bex_def)
   (metis Eps_Opt_eq_Some)

lemma finite_map_to_set:
"finite (map_to_set m) = finite (dom m)"
unfolding map_to_set_def map_to_set_dom
  apply (intro iffI finite_imageI)
  apply assumption
  apply (rule finite_imageD[of fst])
  apply assumption
  apply (simp add: inj_on_def)
done

lemma card_map_to_set :
  "card (map_to_set m) = card (dom m)"
unfolding map_to_set_def map_to_set_dom
  apply (rule card_image[symmetric])
  apply (simp add: inj_on_def)
done

lemma map_of_map_to_set :
"distinct (map fst l) \<Longrightarrow>
 map_of l = m \<longleftrightarrow> set l = map_to_set m"
proof (induct l arbitrary: m)
  case Nil thus ?case by (simp add: map_to_set_empty_iff) blast
next
  case (Cons kv l m)
  obtain k v where kv_eq[simp]: "kv = (k, v)" by (rule PairE)

  from Cons(2) have dist_l: "distinct (map fst l)" and kv'_nin: "\<And>v'. (k, v') \<notin> set l"
    by (auto simp add: image_iff)
  note ind_hyp = Cons(1)[OF dist_l]
                
  from kv'_nin have l_eq: "set (kv # l) = map_to_set m \<longleftrightarrow> (set l = map_to_set (m (k := None))) \<and> m k = Some v"
    apply (simp add: map_to_set_def restrict_map_def set_eq_iff)
    apply (auto)
    apply (metis)
    apply (metis option.inject)
  done

  from kv'_nin have m_eq: "map_of (kv # l) = m \<longleftrightarrow> map_of l = (m (k := None)) \<and> m k = Some v"
    apply (simp add: fun_eq_iff restrict_map_def map_of_eq_None_iff image_iff Ball_def)
    apply metis
  done

  show ?case
    unfolding m_eq l_eq 
    using ind_hyp[of "m (k := None)"] 
    by metis
qed

lemma map_to_set_map_of :
"distinct (map fst l) \<Longrightarrow> map_to_set (map_of l) = set l"
by (metis map_of_map_to_set)


subsection {* Orderings *}

lemma (in order) min_arg_le[simp]:
  "n \<le> min m n \<longleftrightarrow> min m n = n" 
  "m \<le> min m n \<longleftrightarrow> min m n = m" 
  by (auto simp: min_def)

lemma (in linorder) min_arg_not_ge[simp]: 
  "\<not> min m n < m \<longleftrightarrow> min m n = m"
  "\<not> min m n < n \<longleftrightarrow> min m n = n"
  by (auto simp: min_def)

lemma (in linorder) min_eq_arg[simp]: 
  "min m n = m \<longleftrightarrow> m\<le>n"
  "min m n = n \<longleftrightarrow> n\<le>m"
  by (auto simp: min_def)

lemma min_simps[simp]:
  "a<(b::'a::order) \<Longrightarrow> min a b = a"
  "b<(a::'a::order) \<Longrightarrow> min a b = b"
  by (auto simp add: min_def dest: less_imp_le)

end
