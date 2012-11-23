(*  Title:      ZF/Constructible/Datatype_absolute.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
*)

header {*Absoluteness Properties for Recursive Datatypes*}

theory Datatype_absolute imports Formula WF_absolute begin


subsection{*The lfp of a continuous function can be expressed as a union*}

definition
  directed :: "i=>o" where
   "directed(A) == A\<noteq>0 & (\<forall>x\<in>A. \<forall>y\<in>A. x \<union> y \<in> A)"

definition
  contin :: "(i=>i) => o" where
   "contin(h) == (\<forall>A. directed(A) \<longrightarrow> h(\<Union>A) = (\<Union>X\<in>A. h(X)))"

lemma bnd_mono_iterates_subset: "[|bnd_mono(D, h); n \<in> nat|] ==> h^n (0) \<subseteq> D"
apply (induct_tac n) 
 apply (simp_all add: bnd_mono_def, blast) 
done

lemma bnd_mono_increasing [rule_format]:
     "[|i \<in> nat; j \<in> nat; bnd_mono(D,h)|] ==> i \<le> j \<longrightarrow> h^i(0) \<subseteq> h^j(0)"
apply (rule_tac m=i and n=j in diff_induct, simp_all)
apply (blast del: subsetI
             intro: bnd_mono_iterates_subset bnd_monoD2 [of concl: h]) 
done

lemma directed_iterates: "bnd_mono(D,h) ==> directed({h^n (0). n\<in>nat})"
apply (simp add: directed_def, clarify) 
apply (rename_tac i j)
apply (rule_tac x="i \<union> j" in bexI) 
apply (rule_tac i = i and j = j in Ord_linear_le)
apply (simp_all add: subset_Un_iff [THEN iffD1] le_imp_subset
                     subset_Un_iff2 [THEN iffD1])
apply (simp_all add: subset_Un_iff [THEN iff_sym] bnd_mono_increasing
                     subset_Un_iff2 [THEN iff_sym])
done


lemma contin_iterates_eq: 
    "[|bnd_mono(D, h); contin(h)|] 
     ==> h(\<Union>n\<in>nat. h^n (0)) = (\<Union>n\<in>nat. h^n (0))"
apply (simp add: contin_def directed_iterates) 
apply (rule trans) 
apply (rule equalityI) 
 apply (simp_all add: UN_subset_iff)
 apply safe
 apply (erule_tac [2] natE) 
  apply (rule_tac a="succ(x)" in UN_I) 
   apply simp_all 
apply blast 
done

lemma lfp_subset_Union:
     "[|bnd_mono(D, h); contin(h)|] ==> lfp(D,h) \<subseteq> (\<Union>n\<in>nat. h^n(0))"
apply (rule lfp_lowerbound) 
 apply (simp add: contin_iterates_eq) 
apply (simp add: contin_def bnd_mono_iterates_subset UN_subset_iff) 
done

lemma Union_subset_lfp:
     "bnd_mono(D,h) ==> (\<Union>n\<in>nat. h^n(0)) \<subseteq> lfp(D,h)"
apply (simp add: UN_subset_iff)
apply (rule ballI)  
apply (induct_tac n, simp_all) 
apply (rule subset_trans [of _ "h(lfp(D,h))"])
 apply (blast dest: bnd_monoD2 [OF _ _ lfp_subset])  
apply (erule lfp_lemma2) 
done

lemma lfp_eq_Union:
     "[|bnd_mono(D, h); contin(h)|] ==> lfp(D,h) = (\<Union>n\<in>nat. h^n(0))"
by (blast del: subsetI 
          intro: lfp_subset_Union Union_subset_lfp)


subsubsection{*Some Standard Datatype Constructions Preserve Continuity*}

lemma contin_imp_mono: "[|X\<subseteq>Y; contin(F)|] ==> F(X) \<subseteq> F(Y)"
apply (simp add: contin_def) 
apply (drule_tac x="{X,Y}" in spec) 
apply (simp add: directed_def subset_Un_iff2 Un_commute) 
done

lemma sum_contin: "[|contin(F); contin(G)|] ==> contin(\<lambda>X. F(X) + G(X))"
by (simp add: contin_def, blast)

lemma prod_contin: "[|contin(F); contin(G)|] ==> contin(\<lambda>X. F(X) * G(X))" 
apply (subgoal_tac "\<forall>B C. F(B) \<subseteq> F(B \<union> C)")
 prefer 2 apply (simp add: Un_upper1 contin_imp_mono) 
apply (subgoal_tac "\<forall>B C. G(C) \<subseteq> G(B \<union> C)")
 prefer 2 apply (simp add: Un_upper2 contin_imp_mono) 
apply (simp add: contin_def, clarify) 
apply (rule equalityI) 
 prefer 2 apply blast 
apply clarify 
apply (rename_tac B C) 
apply (rule_tac a="B \<union> C" in UN_I) 
 apply (simp add: directed_def, blast)  
done

lemma const_contin: "contin(\<lambda>X. A)"
by (simp add: contin_def directed_def)

lemma id_contin: "contin(\<lambda>X. X)"
by (simp add: contin_def)



subsection {*Absoluteness for "Iterates"*}

definition
  iterates_MH :: "[i=>o, [i,i]=>o, i, i, i, i] => o" where
   "iterates_MH(M,isF,v,n,g,z) ==
        is_nat_case(M, v, \<lambda>m u. \<exists>gm[M]. fun_apply(M,g,m,gm) & isF(gm,u),
                    n, z)"

definition
  is_iterates :: "[i=>o, [i,i]=>o, i, i, i] => o" where
    "is_iterates(M,isF,v,n,Z) == 
      \<exists>sn[M]. \<exists>msn[M]. successor(M,n,sn) & membership(M,sn,msn) &
                       is_wfrec(M, iterates_MH(M,isF,v), msn, n, Z)"

definition
  iterates_replacement :: "[i=>o, [i,i]=>o, i] => o" where
   "iterates_replacement(M,isF,v) ==
      \<forall>n[M]. n\<in>nat \<longrightarrow> 
         wfrec_replacement(M, iterates_MH(M,isF,v), Memrel(succ(n)))"

lemma (in M_basic) iterates_MH_abs:
  "[| relation1(M,isF,F); M(n); M(g); M(z) |] 
   ==> iterates_MH(M,isF,v,n,g,z) \<longleftrightarrow> z = nat_case(v, \<lambda>m. F(g`m), n)"
by (simp add: nat_case_abs [of _ "\<lambda>m. F(g ` m)"]
              relation1_def iterates_MH_def)  

lemma (in M_basic) iterates_imp_wfrec_replacement:
  "[|relation1(M,isF,F); n \<in> nat; iterates_replacement(M,isF,v)|] 
   ==> wfrec_replacement(M, \<lambda>n f z. z = nat_case(v, \<lambda>m. F(f`m), n), 
                       Memrel(succ(n)))" 
by (simp add: iterates_replacement_def iterates_MH_abs)

theorem (in M_trancl) iterates_abs:
  "[| iterates_replacement(M,isF,v); relation1(M,isF,F);
      n \<in> nat; M(v); M(z); \<forall>x[M]. M(F(x)) |] 
   ==> is_iterates(M,isF,v,n,z) \<longleftrightarrow> z = iterates(F,n,v)" 
apply (frule iterates_imp_wfrec_replacement, assumption+)
apply (simp add: wf_Memrel trans_Memrel relation_Memrel nat_into_M
                 is_iterates_def relation2_def iterates_MH_abs 
                 iterates_nat_def recursor_def transrec_def 
                 eclose_sing_Ord_eq nat_into_M
         trans_wfrec_abs [of _ _ _ _ "\<lambda>n g. nat_case(v, \<lambda>m. F(g`m), n)"])
done


lemma (in M_trancl) iterates_closed [intro,simp]:
  "[| iterates_replacement(M,isF,v); relation1(M,isF,F);
      n \<in> nat; M(v); \<forall>x[M]. M(F(x)) |] 
   ==> M(iterates(F,n,v))"
apply (frule iterates_imp_wfrec_replacement, assumption+)
apply (simp add: wf_Memrel trans_Memrel relation_Memrel nat_into_M
                 relation2_def iterates_MH_abs 
                 iterates_nat_def recursor_def transrec_def 
                 eclose_sing_Ord_eq nat_into_M
         trans_wfrec_closed [of _ _ _ "\<lambda>n g. nat_case(v, \<lambda>m. F(g`m), n)"])
done


subsection {*lists without univ*}

lemmas datatype_univs = Inl_in_univ Inr_in_univ 
                        Pair_in_univ nat_into_univ A_into_univ 

lemma list_fun_bnd_mono: "bnd_mono(univ(A), \<lambda>X. {0} + A*X)"
apply (rule bnd_monoI)
 apply (intro subset_refl zero_subset_univ A_subset_univ 
              sum_subset_univ Sigma_subset_univ) 
apply (rule subset_refl sum_mono Sigma_mono | assumption)+
done

lemma list_fun_contin: "contin(\<lambda>X. {0} + A*X)"
by (intro sum_contin prod_contin id_contin const_contin) 

text{*Re-expresses lists using sum and product*}
lemma list_eq_lfp2: "list(A) = lfp(univ(A), \<lambda>X. {0} + A*X)"
apply (simp add: list_def) 
apply (rule equalityI) 
 apply (rule lfp_lowerbound) 
  prefer 2 apply (rule lfp_subset)
 apply (clarify, subst lfp_unfold [OF list_fun_bnd_mono])
 apply (simp add: Nil_def Cons_def)
 apply blast 
txt{*Opposite inclusion*}
apply (rule lfp_lowerbound) 
 prefer 2 apply (rule lfp_subset) 
apply (clarify, subst lfp_unfold [OF list.bnd_mono]) 
apply (simp add: Nil_def Cons_def)
apply (blast intro: datatype_univs
             dest: lfp_subset [THEN subsetD])
done

text{*Re-expresses lists using "iterates", no univ.*}
lemma list_eq_Union:
     "list(A) = (\<Union>n\<in>nat. (\<lambda>X. {0} + A*X) ^ n (0))"
by (simp add: list_eq_lfp2 lfp_eq_Union list_fun_bnd_mono list_fun_contin)


definition
  is_list_functor :: "[i=>o,i,i,i] => o" where
    "is_list_functor(M,A,X,Z) == 
        \<exists>n1[M]. \<exists>AX[M]. 
         number1(M,n1) & cartprod(M,A,X,AX) & is_sum(M,n1,AX,Z)"

lemma (in M_basic) list_functor_abs [simp]: 
     "[| M(A); M(X); M(Z) |] ==> is_list_functor(M,A,X,Z) \<longleftrightarrow> (Z = {0} + A*X)"
by (simp add: is_list_functor_def singleton_0 nat_into_M)


subsection {*formulas without univ*}

lemma formula_fun_bnd_mono:
     "bnd_mono(univ(0), \<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X))"
apply (rule bnd_monoI)
 apply (intro subset_refl zero_subset_univ A_subset_univ 
              sum_subset_univ Sigma_subset_univ nat_subset_univ) 
apply (rule subset_refl sum_mono Sigma_mono | assumption)+
done

lemma formula_fun_contin:
     "contin(\<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X))"
by (intro sum_contin prod_contin id_contin const_contin) 


text{*Re-expresses formulas using sum and product*}
lemma formula_eq_lfp2:
    "formula = lfp(univ(0), \<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X))"
apply (simp add: formula_def) 
apply (rule equalityI) 
 apply (rule lfp_lowerbound) 
  prefer 2 apply (rule lfp_subset)
 apply (clarify, subst lfp_unfold [OF formula_fun_bnd_mono])
 apply (simp add: Member_def Equal_def Nand_def Forall_def)
 apply blast 
txt{*Opposite inclusion*}
apply (rule lfp_lowerbound) 
 prefer 2 apply (rule lfp_subset, clarify) 
apply (subst lfp_unfold [OF formula.bnd_mono, simplified]) 
apply (simp add: Member_def Equal_def Nand_def Forall_def)  
apply (elim sumE SigmaE, simp_all) 
apply (blast intro: datatype_univs dest: lfp_subset [THEN subsetD])+  
done

text{*Re-expresses formulas using "iterates", no univ.*}
lemma formula_eq_Union:
     "formula = 
      (\<Union>n\<in>nat. (\<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X)) ^ n (0))"
by (simp add: formula_eq_lfp2 lfp_eq_Union formula_fun_bnd_mono 
              formula_fun_contin)


definition
  is_formula_functor :: "[i=>o,i,i] => o" where
    "is_formula_functor(M,X,Z) == 
        \<exists>nat'[M]. \<exists>natnat[M]. \<exists>natnatsum[M]. \<exists>XX[M]. \<exists>X3[M]. 
          omega(M,nat') & cartprod(M,nat',nat',natnat) & 
          is_sum(M,natnat,natnat,natnatsum) &
          cartprod(M,X,X,XX) & is_sum(M,XX,X,X3) & 
          is_sum(M,natnatsum,X3,Z)"

lemma (in M_basic) formula_functor_abs [simp]: 
     "[| M(X); M(Z) |] 
      ==> is_formula_functor(M,X,Z) \<longleftrightarrow> 
          Z = ((nat*nat) + (nat*nat)) + (X*X + X)"
by (simp add: is_formula_functor_def) 


subsection{*@{term M} Contains the List and Formula Datatypes*}

definition
  list_N :: "[i,i] => i" where
    "list_N(A,n) == (\<lambda>X. {0} + A * X)^n (0)"

lemma Nil_in_list_N [simp]: "[] \<in> list_N(A,succ(n))"
by (simp add: list_N_def Nil_def)

lemma Cons_in_list_N [simp]:
     "Cons(a,l) \<in> list_N(A,succ(n)) \<longleftrightarrow> a\<in>A & l \<in> list_N(A,n)"
by (simp add: list_N_def Cons_def) 

text{*These two aren't simprules because they reveal the underlying
list representation.*}
lemma list_N_0: "list_N(A,0) = 0"
by (simp add: list_N_def)

lemma list_N_succ: "list_N(A,succ(n)) = {0} + A * (list_N(A,n))"
by (simp add: list_N_def)

lemma list_N_imp_list:
  "[| l \<in> list_N(A,n); n \<in> nat |] ==> l \<in> list(A)"
by (force simp add: list_eq_Union list_N_def)

lemma list_N_imp_length_lt [rule_format]:
     "n \<in> nat ==> \<forall>l \<in> list_N(A,n). length(l) < n"
apply (induct_tac n)  
apply (auto simp add: list_N_0 list_N_succ 
                      Nil_def [symmetric] Cons_def [symmetric]) 
done

lemma list_imp_list_N [rule_format]:
     "l \<in> list(A) ==> \<forall>n\<in>nat. length(l) < n \<longrightarrow> l \<in> list_N(A, n)"
apply (induct_tac l)
apply (force elim: natE)+
done

lemma list_N_imp_eq_length:
      "[|n \<in> nat; l \<notin> list_N(A, n); l \<in> list_N(A, succ(n))|] 
       ==> n = length(l)"
apply (rule le_anti_sym) 
 prefer 2 apply (simp add: list_N_imp_length_lt) 
apply (frule list_N_imp_list, simp)
apply (simp add: not_lt_iff_le [symmetric]) 
apply (blast intro: list_imp_list_N) 
done
  
text{*Express @{term list_rec} without using @{term rank} or @{term Vset},
neither of which is absolute.*}
lemma (in M_trivial) list_rec_eq:
  "l \<in> list(A) ==>
   list_rec(a,g,l) = 
   transrec (succ(length(l)),
      \<lambda>x h. Lambda (list(A),
                    list_case' (a, 
                           \<lambda>a l. g(a, l, h ` succ(length(l)) ` l)))) ` l"
apply (induct_tac l) 
apply (subst transrec, simp) 
apply (subst transrec) 
apply (simp add: list_imp_list_N) 
done

definition
  is_list_N :: "[i=>o,i,i,i] => o" where
    "is_list_N(M,A,n,Z) == 
      \<exists>zero[M]. empty(M,zero) & 
                is_iterates(M, is_list_functor(M,A), zero, n, Z)"

definition  
  mem_list :: "[i=>o,i,i] => o" where
    "mem_list(M,A,l) == 
      \<exists>n[M]. \<exists>listn[M]. 
       finite_ordinal(M,n) & is_list_N(M,A,n,listn) & l \<in> listn"

definition
  is_list :: "[i=>o,i,i] => o" where
    "is_list(M,A,Z) == \<forall>l[M]. l \<in> Z \<longleftrightarrow> mem_list(M,A,l)"

subsubsection{*Towards Absoluteness of @{term formula_rec}*}

consts   depth :: "i=>i"
primrec
  "depth(Member(x,y)) = 0"
  "depth(Equal(x,y))  = 0"
  "depth(Nand(p,q)) = succ(depth(p) \<union> depth(q))"
  "depth(Forall(p)) = succ(depth(p))"

lemma depth_type [TC]: "p \<in> formula ==> depth(p) \<in> nat"
by (induct_tac p, simp_all) 


definition
  formula_N :: "i => i" where
    "formula_N(n) == (\<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X)) ^ n (0)"

lemma Member_in_formula_N [simp]:
     "Member(x,y) \<in> formula_N(succ(n)) \<longleftrightarrow> x \<in> nat & y \<in> nat"
by (simp add: formula_N_def Member_def) 

lemma Equal_in_formula_N [simp]:
     "Equal(x,y) \<in> formula_N(succ(n)) \<longleftrightarrow> x \<in> nat & y \<in> nat"
by (simp add: formula_N_def Equal_def) 

lemma Nand_in_formula_N [simp]:
     "Nand(x,y) \<in> formula_N(succ(n)) \<longleftrightarrow> x \<in> formula_N(n) & y \<in> formula_N(n)"
by (simp add: formula_N_def Nand_def) 

lemma Forall_in_formula_N [simp]:
     "Forall(x) \<in> formula_N(succ(n)) \<longleftrightarrow> x \<in> formula_N(n)"
by (simp add: formula_N_def Forall_def) 

text{*These two aren't simprules because they reveal the underlying
formula representation.*}
lemma formula_N_0: "formula_N(0) = 0"
by (simp add: formula_N_def)

lemma formula_N_succ:
     "formula_N(succ(n)) = 
      ((nat*nat) + (nat*nat)) + (formula_N(n) * formula_N(n) + formula_N(n))"
by (simp add: formula_N_def)

lemma formula_N_imp_formula:
  "[| p \<in> formula_N(n); n \<in> nat |] ==> p \<in> formula"
by (force simp add: formula_eq_Union formula_N_def)

lemma formula_N_imp_depth_lt [rule_format]:
     "n \<in> nat ==> \<forall>p \<in> formula_N(n). depth(p) < n"
apply (induct_tac n)  
apply (auto simp add: formula_N_0 formula_N_succ 
                      depth_type formula_N_imp_formula Un_least_lt_iff
                      Member_def [symmetric] Equal_def [symmetric]
                      Nand_def [symmetric] Forall_def [symmetric]) 
done

lemma formula_imp_formula_N [rule_format]:
     "p \<in> formula ==> \<forall>n\<in>nat. depth(p) < n \<longrightarrow> p \<in> formula_N(n)"
apply (induct_tac p)
apply (simp_all add: succ_Un_distrib Un_least_lt_iff) 
apply (force elim: natE)+
done

lemma formula_N_imp_eq_depth:
      "[|n \<in> nat; p \<notin> formula_N(n); p \<in> formula_N(succ(n))|] 
       ==> n = depth(p)"
apply (rule le_anti_sym) 
 prefer 2 apply (simp add: formula_N_imp_depth_lt) 
apply (frule formula_N_imp_formula, simp)
apply (simp add: not_lt_iff_le [symmetric]) 
apply (blast intro: formula_imp_formula_N) 
done


text{*This result and the next are unused.*}
lemma formula_N_mono [rule_format]:
  "[| m \<in> nat; n \<in> nat |] ==> m\<le>n \<longrightarrow> formula_N(m) \<subseteq> formula_N(n)"
apply (rule_tac m = m and n = n in diff_induct)
apply (simp_all add: formula_N_0 formula_N_succ, blast) 
done

lemma formula_N_distrib:
  "[| m \<in> nat; n \<in> nat |] ==> formula_N(m \<union> n) = formula_N(m) \<union> formula_N(n)"
apply (rule_tac i = m and j = n in Ord_linear_le, auto) 
apply (simp_all add: subset_Un_iff [THEN iffD1] subset_Un_iff2 [THEN iffD1] 
                     le_imp_subset formula_N_mono)
done

definition
  is_formula_N :: "[i=>o,i,i] => o" where
    "is_formula_N(M,n,Z) == 
      \<exists>zero[M]. empty(M,zero) & 
                is_iterates(M, is_formula_functor(M), zero, n, Z)"


definition  
  mem_formula :: "[i=>o,i] => o" where
    "mem_formula(M,p) == 
      \<exists>n[M]. \<exists>formn[M]. 
       finite_ordinal(M,n) & is_formula_N(M,n,formn) & p \<in> formn"

definition
  is_formula :: "[i=>o,i] => o" where
    "is_formula(M,Z) == \<forall>p[M]. p \<in> Z \<longleftrightarrow> mem_formula(M,p)"

locale M_datatypes = M_trancl +
 assumes list_replacement1:
   "M(A) ==> iterates_replacement(M, is_list_functor(M,A), 0)"
  and list_replacement2:
   "M(A) ==> strong_replacement(M,
         \<lambda>n y. n\<in>nat & is_iterates(M, is_list_functor(M,A), 0, n, y))"
  and formula_replacement1:
   "iterates_replacement(M, is_formula_functor(M), 0)"
  and formula_replacement2:
   "strong_replacement(M,
         \<lambda>n y. n\<in>nat & is_iterates(M, is_formula_functor(M), 0, n, y))"
  and nth_replacement:
   "M(l) ==> iterates_replacement(M, %l t. is_tl(M,l,t), l)"


subsubsection{*Absoluteness of the List Construction*}

lemma (in M_datatypes) list_replacement2':
  "M(A) ==> strong_replacement(M, \<lambda>n y. n\<in>nat & y = (\<lambda>X. {0} + A * X)^n (0))"
apply (insert list_replacement2 [of A])
apply (rule strong_replacement_cong [THEN iffD1])
apply (rule conj_cong [OF iff_refl iterates_abs [of "is_list_functor(M,A)"]])
apply (simp_all add: list_replacement1 relation1_def)
done

lemma (in M_datatypes) list_closed [intro,simp]:
     "M(A) ==> M(list(A))"
apply (insert list_replacement1)
by  (simp add: RepFun_closed2 list_eq_Union
               list_replacement2' relation1_def
               iterates_closed [of "is_list_functor(M,A)"])

text{*WARNING: use only with @{text "dest:"} or with variables fixed!*}
lemmas (in M_datatypes) list_into_M = transM [OF _ list_closed]

lemma (in M_datatypes) list_N_abs [simp]:
     "[|M(A); n\<in>nat; M(Z)|]
      ==> is_list_N(M,A,n,Z) \<longleftrightarrow> Z = list_N(A,n)"
apply (insert list_replacement1)
apply (simp add: is_list_N_def list_N_def relation1_def nat_into_M
                 iterates_abs [of "is_list_functor(M,A)" _ "\<lambda>X. {0} + A*X"])
done

lemma (in M_datatypes) list_N_closed [intro,simp]:
     "[|M(A); n\<in>nat|] ==> M(list_N(A,n))"
apply (insert list_replacement1)
apply (simp add: is_list_N_def list_N_def relation1_def nat_into_M
                 iterates_closed [of "is_list_functor(M,A)"])
done

lemma (in M_datatypes) mem_list_abs [simp]:
     "M(A) ==> mem_list(M,A,l) \<longleftrightarrow> l \<in> list(A)"
apply (insert list_replacement1)
apply (simp add: mem_list_def list_N_def relation1_def list_eq_Union
                 iterates_closed [of "is_list_functor(M,A)"])
done

lemma (in M_datatypes) list_abs [simp]:
     "[|M(A); M(Z)|] ==> is_list(M,A,Z) \<longleftrightarrow> Z = list(A)"
apply (simp add: is_list_def, safe)
apply (rule M_equalityI, simp_all)
done

subsubsection{*Absoluteness of Formulas*}

lemma (in M_datatypes) formula_replacement2':
  "strong_replacement(M, \<lambda>n y. n\<in>nat & y = (\<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X))^n (0))"
apply (insert formula_replacement2)
apply (rule strong_replacement_cong [THEN iffD1])
apply (rule conj_cong [OF iff_refl iterates_abs [of "is_formula_functor(M)"]])
apply (simp_all add: formula_replacement1 relation1_def)
done

lemma (in M_datatypes) formula_closed [intro,simp]:
     "M(formula)"
apply (insert formula_replacement1)
apply  (simp add: RepFun_closed2 formula_eq_Union
                  formula_replacement2' relation1_def
                  iterates_closed [of "is_formula_functor(M)"])
done

lemmas (in M_datatypes) formula_into_M = transM [OF _ formula_closed]

lemma (in M_datatypes) formula_N_abs [simp]:
     "[|n\<in>nat; M(Z)|]
      ==> is_formula_N(M,n,Z) \<longleftrightarrow> Z = formula_N(n)"
apply (insert formula_replacement1)
apply (simp add: is_formula_N_def formula_N_def relation1_def nat_into_M
                 iterates_abs [of "is_formula_functor(M)" _
                                  "\<lambda>X. ((nat*nat) + (nat*nat)) + (X*X + X)"])
done

lemma (in M_datatypes) formula_N_closed [intro,simp]:
     "n\<in>nat ==> M(formula_N(n))"
apply (insert formula_replacement1)
apply (simp add: is_formula_N_def formula_N_def relation1_def nat_into_M
                 iterates_closed [of "is_formula_functor(M)"])
done

lemma (in M_datatypes) mem_formula_abs [simp]:
     "mem_formula(M,l) \<longleftrightarrow> l \<in> formula"
apply (insert formula_replacement1)
apply (simp add: mem_formula_def relation1_def formula_eq_Union formula_N_def
                 iterates_closed [of "is_formula_functor(M)"])
done

lemma (in M_datatypes) formula_abs [simp]:
     "[|M(Z)|] ==> is_formula(M,Z) \<longleftrightarrow> Z = formula"
apply (simp add: is_formula_def, safe)
apply (rule M_equalityI, simp_all)
done


subsection{*Absoluteness for @{text \<epsilon>}-Closure: the @{term eclose} Operator*}

text{*Re-expresses eclose using "iterates"*}
lemma eclose_eq_Union:
     "eclose(A) = (\<Union>n\<in>nat. Union^n (A))"
apply (simp add: eclose_def)
apply (rule UN_cong)
apply (rule refl)
apply (induct_tac n)
apply (simp add: nat_rec_0)
apply (simp add: nat_rec_succ)
done

definition
  is_eclose_n :: "[i=>o,i,i,i] => o" where
    "is_eclose_n(M,A,n,Z) == is_iterates(M, big_union(M), A, n, Z)"

definition
  mem_eclose :: "[i=>o,i,i] => o" where
    "mem_eclose(M,A,l) ==
      \<exists>n[M]. \<exists>eclosen[M].
       finite_ordinal(M,n) & is_eclose_n(M,A,n,eclosen) & l \<in> eclosen"

definition
  is_eclose :: "[i=>o,i,i] => o" where
    "is_eclose(M,A,Z) == \<forall>u[M]. u \<in> Z \<longleftrightarrow> mem_eclose(M,A,u)"


locale M_eclose = M_datatypes +
 assumes eclose_replacement1:
   "M(A) ==> iterates_replacement(M, big_union(M), A)"
  and eclose_replacement2:
   "M(A) ==> strong_replacement(M,
         \<lambda>n y. n\<in>nat & is_iterates(M, big_union(M), A, n, y))"

lemma (in M_eclose) eclose_replacement2':
  "M(A) ==> strong_replacement(M, \<lambda>n y. n\<in>nat & y = Union^n (A))"
apply (insert eclose_replacement2 [of A])
apply (rule strong_replacement_cong [THEN iffD1])
apply (rule conj_cong [OF iff_refl iterates_abs [of "big_union(M)"]])
apply (simp_all add: eclose_replacement1 relation1_def)
done

lemma (in M_eclose) eclose_closed [intro,simp]:
     "M(A) ==> M(eclose(A))"
apply (insert eclose_replacement1)
by  (simp add: RepFun_closed2 eclose_eq_Union
               eclose_replacement2' relation1_def
               iterates_closed [of "big_union(M)"])

lemma (in M_eclose) is_eclose_n_abs [simp]:
     "[|M(A); n\<in>nat; M(Z)|] ==> is_eclose_n(M,A,n,Z) \<longleftrightarrow> Z = Union^n (A)"
apply (insert eclose_replacement1)
apply (simp add: is_eclose_n_def relation1_def nat_into_M
                 iterates_abs [of "big_union(M)" _ "Union"])
done

lemma (in M_eclose) mem_eclose_abs [simp]:
     "M(A) ==> mem_eclose(M,A,l) \<longleftrightarrow> l \<in> eclose(A)"
apply (insert eclose_replacement1)
apply (simp add: mem_eclose_def relation1_def eclose_eq_Union
                 iterates_closed [of "big_union(M)"])
done

lemma (in M_eclose) eclose_abs [simp]:
     "[|M(A); M(Z)|] ==> is_eclose(M,A,Z) \<longleftrightarrow> Z = eclose(A)"
apply (simp add: is_eclose_def, safe)
apply (rule M_equalityI, simp_all)
done


subsection {*Absoluteness for @{term transrec}*}

text{* @{prop "transrec(a,H) \<equiv> wfrec(Memrel(eclose({a})), a, H)"} *}

definition
  is_transrec :: "[i=>o, [i,i,i]=>o, i, i] => o" where
   "is_transrec(M,MH,a,z) ==
      \<exists>sa[M]. \<exists>esa[M]. \<exists>mesa[M].
       upair(M,a,a,sa) & is_eclose(M,sa,esa) & membership(M,esa,mesa) &
       is_wfrec(M,MH,mesa,a,z)"

definition
  transrec_replacement :: "[i=>o, [i,i,i]=>o, i] => o" where
   "transrec_replacement(M,MH,a) ==
      \<exists>sa[M]. \<exists>esa[M]. \<exists>mesa[M].
       upair(M,a,a,sa) & is_eclose(M,sa,esa) & membership(M,esa,mesa) &
       wfrec_replacement(M,MH,mesa)"

text{*The condition @{term "Ord(i)"} lets us use the simpler
  @{text "trans_wfrec_abs"} rather than @{text "trans_wfrec_abs"},
  which I haven't even proved yet. *}
theorem (in M_eclose) transrec_abs:
  "[|transrec_replacement(M,MH,i);  relation2(M,MH,H);
     Ord(i);  M(i);  M(z);
     \<forall>x[M]. \<forall>g[M]. function(g) \<longrightarrow> M(H(x,g))|]
   ==> is_transrec(M,MH,i,z) \<longleftrightarrow> z = transrec(i,H)"
by (simp add: trans_wfrec_abs transrec_replacement_def is_transrec_def
       transrec_def eclose_sing_Ord_eq wf_Memrel trans_Memrel relation_Memrel)


theorem (in M_eclose) transrec_closed:
     "[|transrec_replacement(M,MH,i);  relation2(M,MH,H);
        Ord(i);  M(i);
        \<forall>x[M]. \<forall>g[M]. function(g) \<longrightarrow> M(H(x,g))|]
      ==> M(transrec(i,H))"
by (simp add: trans_wfrec_closed transrec_replacement_def is_transrec_def
        transrec_def eclose_sing_Ord_eq wf_Memrel trans_Memrel relation_Memrel)


text{*Helps to prove instances of @{term transrec_replacement}*}
lemma (in M_eclose) transrec_replacementI:
   "[|M(a);
      strong_replacement (M,
                  \<lambda>x z. \<exists>y[M]. pair(M, x, y, z) &
                               is_wfrec(M,MH,Memrel(eclose({a})),x,y))|]
    ==> transrec_replacement(M,MH,a)"
by (simp add: transrec_replacement_def wfrec_replacement_def)


subsection{*Absoluteness for the List Operator @{term length}*}
text{*But it is never used.*}

definition
  is_length :: "[i=>o,i,i,i] => o" where
    "is_length(M,A,l,n) ==
       \<exists>sn[M]. \<exists>list_n[M]. \<exists>list_sn[M].
        is_list_N(M,A,n,list_n) & l \<notin> list_n &
        successor(M,n,sn) & is_list_N(M,A,sn,list_sn) & l \<in> list_sn"


lemma (in M_datatypes) length_abs [simp]:
     "[|M(A); l \<in> list(A); n \<in> nat|] ==> is_length(M,A,l,n) \<longleftrightarrow> n = length(l)"
apply (subgoal_tac "M(l) & M(n)")
 prefer 2 apply (blast dest: transM)
apply (simp add: is_length_def)
apply (blast intro: list_imp_list_N nat_into_Ord list_N_imp_eq_length
             dest: list_N_imp_length_lt)
done

text{*Proof is trivial since @{term length} returns natural numbers.*}
lemma (in M_trivial) length_closed [intro,simp]:
     "l \<in> list(A) ==> M(length(l))"
by (simp add: nat_into_M)


subsection {*Absoluteness for the List Operator @{term nth}*}

lemma nth_eq_hd_iterates_tl [rule_format]:
     "xs \<in> list(A) ==> \<forall>n \<in> nat. nth(n,xs) = hd' (tl'^n (xs))"
apply (induct_tac xs)
apply (simp add: iterates_tl_Nil hd'_Nil, clarify)
apply (erule natE)
apply (simp add: hd'_Cons)
apply (simp add: tl'_Cons iterates_commute)
done

lemma (in M_basic) iterates_tl'_closed:
     "[|n \<in> nat; M(x)|] ==> M(tl'^n (x))"
apply (induct_tac n, simp)
apply (simp add: tl'_Cons tl'_closed)
done

text{*Immediate by type-checking*}
lemma (in M_datatypes) nth_closed [intro,simp]:
     "[|xs \<in> list(A); n \<in> nat; M(A)|] ==> M(nth(n,xs))"
apply (case_tac "n < length(xs)")
 apply (blast intro: nth_type transM)
apply (simp add: not_lt_iff_le nth_eq_0)
done

definition
  is_nth :: "[i=>o,i,i,i] => o" where
    "is_nth(M,n,l,Z) ==
      \<exists>X[M]. is_iterates(M, is_tl(M), l, n, X) & is_hd(M,X,Z)"

lemma (in M_datatypes) nth_abs [simp]:
     "[|M(A); n \<in> nat; l \<in> list(A); M(Z)|]
      ==> is_nth(M,n,l,Z) \<longleftrightarrow> Z = nth(n,l)"
apply (subgoal_tac "M(l)")
 prefer 2 apply (blast intro: transM)
apply (simp add: is_nth_def nth_eq_hd_iterates_tl nat_into_M
                 tl'_closed iterates_tl'_closed
                 iterates_abs [OF _ relation1_tl] nth_replacement)
done


subsection{*Relativization and Absoluteness for the @{term formula} Constructors*}

definition
  is_Member :: "[i=>o,i,i,i] => o" where
     --{* because @{term "Member(x,y) \<equiv> Inl(Inl(\<langle>x,y\<rangle>))"}*}
    "is_Member(M,x,y,Z) ==
        \<exists>p[M]. \<exists>u[M]. pair(M,x,y,p) & is_Inl(M,p,u) & is_Inl(M,u,Z)"

lemma (in M_trivial) Member_abs [simp]:
     "[|M(x); M(y); M(Z)|] ==> is_Member(M,x,y,Z) \<longleftrightarrow> (Z = Member(x,y))"
by (simp add: is_Member_def Member_def)

lemma (in M_trivial) Member_in_M_iff [iff]:
     "M(Member(x,y)) \<longleftrightarrow> M(x) & M(y)"
by (simp add: Member_def)

definition
  is_Equal :: "[i=>o,i,i,i] => o" where
     --{* because @{term "Equal(x,y) \<equiv> Inl(Inr(\<langle>x,y\<rangle>))"}*}
    "is_Equal(M,x,y,Z) ==
        \<exists>p[M]. \<exists>u[M]. pair(M,x,y,p) & is_Inr(M,p,u) & is_Inl(M,u,Z)"

lemma (in M_trivial) Equal_abs [simp]:
     "[|M(x); M(y); M(Z)|] ==> is_Equal(M,x,y,Z) \<longleftrightarrow> (Z = Equal(x,y))"
by (simp add: is_Equal_def Equal_def)

lemma (in M_trivial) Equal_in_M_iff [iff]: "M(Equal(x,y)) \<longleftrightarrow> M(x) & M(y)"
by (simp add: Equal_def)

definition
  is_Nand :: "[i=>o,i,i,i] => o" where
     --{* because @{term "Nand(x,y) \<equiv> Inr(Inl(\<langle>x,y\<rangle>))"}*}
    "is_Nand(M,x,y,Z) ==
        \<exists>p[M]. \<exists>u[M]. pair(M,x,y,p) & is_Inl(M,p,u) & is_Inr(M,u,Z)"

lemma (in M_trivial) Nand_abs [simp]:
     "[|M(x); M(y); M(Z)|] ==> is_Nand(M,x,y,Z) \<longleftrightarrow> (Z = Nand(x,y))"
by (simp add: is_Nand_def Nand_def)

lemma (in M_trivial) Nand_in_M_iff [iff]: "M(Nand(x,y)) \<longleftrightarrow> M(x) & M(y)"
by (simp add: Nand_def)

definition
  is_Forall :: "[i=>o,i,i] => o" where
     --{* because @{term "Forall(x) \<equiv> Inr(Inr(p))"}*}
    "is_Forall(M,p,Z) == \<exists>u[M]. is_Inr(M,p,u) & is_Inr(M,u,Z)"

lemma (in M_trivial) Forall_abs [simp]:
     "[|M(x); M(Z)|] ==> is_Forall(M,x,Z) \<longleftrightarrow> (Z = Forall(x))"
by (simp add: is_Forall_def Forall_def)

lemma (in M_trivial) Forall_in_M_iff [iff]: "M(Forall(x)) \<longleftrightarrow> M(x)"
by (simp add: Forall_def)



subsection {*Absoluteness for @{term formula_rec}*}

definition
  formula_rec_case :: "[[i,i]=>i, [i,i]=>i, [i,i,i,i]=>i, [i,i]=>i, i, i] => i" where
    --{* the instance of @{term formula_case} in @{term formula_rec}*}
   "formula_rec_case(a,b,c,d,h) ==
        formula_case (a, b,
                \<lambda>u v. c(u, v, h ` succ(depth(u)) ` u,
                              h ` succ(depth(v)) ` v),
                \<lambda>u. d(u, h ` succ(depth(u)) ` u))"

text{*Unfold @{term formula_rec} to @{term formula_rec_case}.
     Express @{term formula_rec} without using @{term rank} or @{term Vset},
neither of which is absolute.*}
lemma (in M_trivial) formula_rec_eq:
  "p \<in> formula ==>
   formula_rec(a,b,c,d,p) =
   transrec (succ(depth(p)),
             \<lambda>x h. Lambda (formula, formula_rec_case(a,b,c,d,h))) ` p"
apply (simp add: formula_rec_case_def)
apply (induct_tac p)
   txt{*Base case for @{term Member}*}
   apply (subst transrec, simp add: formula.intros)
  txt{*Base case for @{term Equal}*}
  apply (subst transrec, simp add: formula.intros)
 txt{*Inductive step for @{term Nand}*}
 apply (subst transrec)
 apply (simp add: succ_Un_distrib formula.intros)
txt{*Inductive step for @{term Forall}*}
apply (subst transrec)
apply (simp add: formula_imp_formula_N formula.intros)
done


subsubsection{*Absoluteness for the Formula Operator @{term depth}*}

definition
  is_depth :: "[i=>o,i,i] => o" where
    "is_depth(M,p,n) ==
       \<exists>sn[M]. \<exists>formula_n[M]. \<exists>formula_sn[M].
        is_formula_N(M,n,formula_n) & p \<notin> formula_n &
        successor(M,n,sn) & is_formula_N(M,sn,formula_sn) & p \<in> formula_sn"


lemma (in M_datatypes) depth_abs [simp]:
     "[|p \<in> formula; n \<in> nat|] ==> is_depth(M,p,n) \<longleftrightarrow> n = depth(p)"
apply (subgoal_tac "M(p) & M(n)")
 prefer 2 apply (blast dest: transM)
apply (simp add: is_depth_def)
apply (blast intro: formula_imp_formula_N nat_into_Ord formula_N_imp_eq_depth
             dest: formula_N_imp_depth_lt)
done

text{*Proof is trivial since @{term depth} returns natural numbers.*}
lemma (in M_trivial) depth_closed [intro,simp]:
     "p \<in> formula ==> M(depth(p))"
by (simp add: nat_into_M)


subsubsection{*@{term is_formula_case}: relativization of @{term formula_case}*}

definition
 is_formula_case ::
    "[i=>o, [i,i,i]=>o, [i,i,i]=>o, [i,i,i]=>o, [i,i]=>o, i, i] => o" where
  --{*no constraint on non-formulas*}
  "is_formula_case(M, is_a, is_b, is_c, is_d, p, z) ==
      (\<forall>x[M]. \<forall>y[M]. finite_ordinal(M,x) \<longrightarrow> finite_ordinal(M,y) \<longrightarrow>
                      is_Member(M,x,y,p) \<longrightarrow> is_a(x,y,z)) &
      (\<forall>x[M]. \<forall>y[M]. finite_ordinal(M,x) \<longrightarrow> finite_ordinal(M,y) \<longrightarrow>
                      is_Equal(M,x,y,p) \<longrightarrow> is_b(x,y,z)) &
      (\<forall>x[M]. \<forall>y[M]. mem_formula(M,x) \<longrightarrow> mem_formula(M,y) \<longrightarrow>
                     is_Nand(M,x,y,p) \<longrightarrow> is_c(x,y,z)) &
      (\<forall>x[M]. mem_formula(M,x) \<longrightarrow> is_Forall(M,x,p) \<longrightarrow> is_d(x,z))"

lemma (in M_datatypes) formula_case_abs [simp]:
     "[| Relation2(M,nat,nat,is_a,a); Relation2(M,nat,nat,is_b,b);
         Relation2(M,formula,formula,is_c,c); Relation1(M,formula,is_d,d);
         p \<in> formula; M(z) |]
      ==> is_formula_case(M,is_a,is_b,is_c,is_d,p,z) \<longleftrightarrow>
          z = formula_case(a,b,c,d,p)"
apply (simp add: formula_into_M is_formula_case_def)
apply (erule formula.cases)
   apply (simp_all add: Relation1_def Relation2_def)
done

lemma (in M_datatypes) formula_case_closed [intro,simp]:
  "[|p \<in> formula;
     \<forall>x[M]. \<forall>y[M]. x\<in>nat \<longrightarrow> y\<in>nat \<longrightarrow> M(a(x,y));
     \<forall>x[M]. \<forall>y[M]. x\<in>nat \<longrightarrow> y\<in>nat \<longrightarrow> M(b(x,y));
     \<forall>x[M]. \<forall>y[M]. x\<in>formula \<longrightarrow> y\<in>formula \<longrightarrow> M(c(x,y));
     \<forall>x[M]. x\<in>formula \<longrightarrow> M(d(x))|] ==> M(formula_case(a,b,c,d,p))"
by (erule formula.cases, simp_all)


subsubsection {*Absoluteness for @{term formula_rec}: Final Results*}

definition
  is_formula_rec :: "[i=>o, [i,i,i]=>o, i, i] => o" where
    --{* predicate to relativize the functional @{term formula_rec}*}
   "is_formula_rec(M,MH,p,z)  ==
      \<exists>dp[M]. \<exists>i[M]. \<exists>f[M]. finite_ordinal(M,dp) & is_depth(M,p,dp) &
             successor(M,dp,i) & fun_apply(M,f,p,z) & is_transrec(M,MH,i,f)"


text{*Sufficient conditions to relativize the instance of @{term formula_case}
      in @{term formula_rec}*}
lemma (in M_datatypes) Relation1_formula_rec_case:
     "[|Relation2(M, nat, nat, is_a, a);
        Relation2(M, nat, nat, is_b, b);
        Relation2 (M, formula, formula,
           is_c, \<lambda>u v. c(u, v, h`succ(depth(u))`u, h`succ(depth(v))`v));
        Relation1(M, formula,
           is_d, \<lambda>u. d(u, h ` succ(depth(u)) ` u));
        M(h) |]
      ==> Relation1(M, formula,
                         is_formula_case (M, is_a, is_b, is_c, is_d),
                         formula_rec_case(a, b, c, d, h))"
apply (simp (no_asm) add: formula_rec_case_def Relation1_def)
apply (simp add: formula_case_abs)
done


text{*This locale packages the premises of the following theorems,
      which is the normal purpose of locales.  It doesn't accumulate
      constraints on the class @{term M}, as in most of this deveopment.*}
locale Formula_Rec = M_eclose +
  fixes a and is_a and b and is_b and c and is_c and d and is_d and MH
  defines
      "MH(u::i,f,z) ==
        \<forall>fml[M]. is_formula(M,fml) \<longrightarrow>
             is_lambda
         (M, fml, is_formula_case (M, is_a, is_b, is_c(f), is_d(f)), z)"

  assumes a_closed: "[|x\<in>nat; y\<in>nat|] ==> M(a(x,y))"
      and a_rel:    "Relation2(M, nat, nat, is_a, a)"
      and b_closed: "[|x\<in>nat; y\<in>nat|] ==> M(b(x,y))"
      and b_rel:    "Relation2(M, nat, nat, is_b, b)"
      and c_closed: "[|x \<in> formula; y \<in> formula; M(gx); M(gy)|]
                     ==> M(c(x, y, gx, gy))"
      and c_rel:
         "M(f) ==>
          Relation2 (M, formula, formula, is_c(f),
             \<lambda>u v. c(u, v, f ` succ(depth(u)) ` u, f ` succ(depth(v)) ` v))"
      and d_closed: "[|x \<in> formula; M(gx)|] ==> M(d(x, gx))"
      and d_rel:
         "M(f) ==>
          Relation1(M, formula, is_d(f), \<lambda>u. d(u, f ` succ(depth(u)) ` u))"
      and fr_replace: "n \<in> nat ==> transrec_replacement(M,MH,n)"
      and fr_lam_replace:
           "M(g) ==>
            strong_replacement
              (M, \<lambda>x y. x \<in> formula &
                  y = \<langle>x, formula_rec_case(a,b,c,d,g,x)\<rangle>)";

lemma (in Formula_Rec) formula_rec_case_closed:
    "[|M(g); p \<in> formula|] ==> M(formula_rec_case(a, b, c, d, g, p))"
by (simp add: formula_rec_case_def a_closed b_closed c_closed d_closed)

lemma (in Formula_Rec) formula_rec_lam_closed:
    "M(g) ==> M(Lambda (formula, formula_rec_case(a,b,c,d,g)))"
by (simp add: lam_closed2 fr_lam_replace formula_rec_case_closed)

lemma (in Formula_Rec) MH_rel2:
     "relation2 (M, MH,
             \<lambda>x h. Lambda (formula, formula_rec_case(a,b,c,d,h)))"
apply (simp add: relation2_def MH_def, clarify)
apply (rule lambda_abs2)
apply (rule Relation1_formula_rec_case)
apply (simp_all add: a_rel b_rel c_rel d_rel formula_rec_case_closed)
done

lemma (in Formula_Rec) fr_transrec_closed:
    "n \<in> nat
     ==> M(transrec
          (n, \<lambda>x h. Lambda(formula, formula_rec_case(a, b, c, d, h))))"
by (simp add: transrec_closed [OF fr_replace MH_rel2]
              nat_into_M formula_rec_lam_closed)

text{*The main two results: @{term formula_rec} is absolute for @{term M}.*}
theorem (in Formula_Rec) formula_rec_closed:
    "p \<in> formula ==> M(formula_rec(a,b,c,d,p))"
by (simp add: formula_rec_eq fr_transrec_closed
              transM [OF _ formula_closed])

theorem (in Formula_Rec) formula_rec_abs:
  "[| p \<in> formula; M(z)|]
   ==> is_formula_rec(M,MH,p,z) \<longleftrightarrow> z = formula_rec(a,b,c,d,p)"
by (simp add: is_formula_rec_def formula_rec_eq transM [OF _ formula_closed]
              transrec_abs [OF fr_replace MH_rel2] depth_type
              fr_transrec_closed formula_rec_lam_closed eq_commute)


end
