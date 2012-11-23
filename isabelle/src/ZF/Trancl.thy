(*  Title:      ZF/Trancl.thy
    Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1992  University of Cambridge
*)

header{*Relations: Their General Properties and Transitive Closure*}

theory Trancl imports Fixedpt Perm begin

definition
  refl     :: "[i,i]=>o"  where
    "refl(A,r) == (\<forall>x\<in>A. <x,x> \<in> r)"

definition
  irrefl   :: "[i,i]=>o"  where
    "irrefl(A,r) == \<forall>x\<in>A. <x,x> \<notin> r"

definition
  sym      :: "i=>o"  where
    "sym(r) == \<forall>x y. <x,y>: r \<longrightarrow> <y,x>: r"

definition
  asym     :: "i=>o"  where
    "asym(r) == \<forall>x y. <x,y>:r \<longrightarrow> ~ <y,x>:r"

definition
  antisym  :: "i=>o"  where
    "antisym(r) == \<forall>x y.<x,y>:r \<longrightarrow> <y,x>:r \<longrightarrow> x=y"

definition
  trans    :: "i=>o"  where
    "trans(r) == \<forall>x y z. <x,y>: r \<longrightarrow> <y,z>: r \<longrightarrow> <x,z>: r"

definition
  trans_on :: "[i,i]=>o"  ("trans[_]'(_')")  where
    "trans[A](r) == \<forall>x\<in>A. \<forall>y\<in>A. \<forall>z\<in>A.
                          <x,y>: r \<longrightarrow> <y,z>: r \<longrightarrow> <x,z>: r"

definition
  rtrancl :: "i=>i"  ("(_^*)" [100] 100)  (*refl/transitive closure*)  where
    "r^* == lfp(field(r)*field(r), %s. id(field(r)) \<union> (r O s))"

definition
  trancl  :: "i=>i"  ("(_^+)" [100] 100)  (*transitive closure*)  where
    "r^+ == r O r^*"

definition
  equiv    :: "[i,i]=>o"  where
    "equiv(A,r) == r \<subseteq> A*A & refl(A,r) & sym(r) & trans(r)"


subsection{*General properties of relations*}

subsubsection{*irreflexivity*}

lemma irreflI:
    "[| !!x. x \<in> A ==> <x,x> \<notin> r |] ==> irrefl(A,r)"
by (simp add: irrefl_def)

lemma irreflE: "[| irrefl(A,r);  x \<in> A |] ==>  <x,x> \<notin> r"
by (simp add: irrefl_def)

subsubsection{*symmetry*}

lemma symI:
     "[| !!x y.<x,y>: r ==> <y,x>: r |] ==> sym(r)"
by (unfold sym_def, blast)

lemma symE: "[| sym(r); <x,y>: r |]  ==>  <y,x>: r"
by (unfold sym_def, blast)

subsubsection{*antisymmetry*}

lemma antisymI:
     "[| !!x y.[| <x,y>: r;  <y,x>: r |] ==> x=y |] ==> antisym(r)"
by (simp add: antisym_def, blast)

lemma antisymE: "[| antisym(r); <x,y>: r;  <y,x>: r |]  ==>  x=y"
by (simp add: antisym_def, blast)

subsubsection{*transitivity*}

lemma transD: "[| trans(r);  <a,b>:r;  <b,c>:r |] ==> <a,c>:r"
by (unfold trans_def, blast)

lemma trans_onD:
    "[| trans[A](r);  <a,b>:r;  <b,c>:r;  a \<in> A;  b \<in> A;  c \<in> A |] ==> <a,c>:r"
by (unfold trans_on_def, blast)

lemma trans_imp_trans_on: "trans(r) ==> trans[A](r)"
by (unfold trans_def trans_on_def, blast)

lemma trans_on_imp_trans: "[|trans[A](r); r \<subseteq> A*A|] ==> trans(r)";
by (simp add: trans_on_def trans_def, blast)


subsection{*Transitive closure of a relation*}

lemma rtrancl_bnd_mono:
     "bnd_mono(field(r)*field(r), %s. id(field(r)) \<union> (r O s))"
by (rule bnd_monoI, blast+)

lemma rtrancl_mono: "r<=s ==> r^* \<subseteq> s^*"
apply (unfold rtrancl_def)
apply (rule lfp_mono)
apply (rule rtrancl_bnd_mono)+
apply blast
done

(* @{term"r^* = id(field(r)) \<union> ( r O r^* )"}    *)
lemmas rtrancl_unfold =
     rtrancl_bnd_mono [THEN rtrancl_def [THEN def_lfp_unfold]]

(** The relation rtrancl **)

(*  @{term"r^* \<subseteq> field(r) * field(r)"}  *)
lemmas rtrancl_type = rtrancl_def [THEN def_lfp_subset]

lemma relation_rtrancl: "relation(r^*)"
apply (simp add: relation_def)
apply (blast dest: rtrancl_type [THEN subsetD])
done

(*Reflexivity of rtrancl*)
lemma rtrancl_refl: "[| a \<in> field(r) |] ==> <a,a> \<in> r^*"
apply (rule rtrancl_unfold [THEN ssubst])
apply (erule idI [THEN UnI1])
done

(*Closure under composition with r  *)
lemma rtrancl_into_rtrancl: "[| <a,b> \<in> r^*;  <b,c> \<in> r |] ==> <a,c> \<in> r^*"
apply (rule rtrancl_unfold [THEN ssubst])
apply (rule compI [THEN UnI2], assumption, assumption)
done

(*rtrancl of r contains all pairs in r  *)
lemma r_into_rtrancl: "<a,b> \<in> r ==> <a,b> \<in> r^*"
by (rule rtrancl_refl [THEN rtrancl_into_rtrancl], blast+)

(*The premise ensures that r consists entirely of pairs*)
lemma r_subset_rtrancl: "relation(r) ==> r \<subseteq> r^*"
by (simp add: relation_def, blast intro: r_into_rtrancl)

lemma rtrancl_field: "field(r^*) = field(r)"
by (blast intro: r_into_rtrancl dest!: rtrancl_type [THEN subsetD])


(** standard induction rule **)

lemma rtrancl_full_induct [case_names initial step, consumes 1]:
  "[| <a,b> \<in> r^*;
      !!x. x \<in> field(r) ==> P(<x,x>);
      !!x y z.[| P(<x,y>); <x,y>: r^*; <y,z>: r |]  ==>  P(<x,z>) |]
   ==>  P(<a,b>)"
by (erule def_induct [OF rtrancl_def rtrancl_bnd_mono], blast)

(*nice induction rule.
  Tried adding the typing hypotheses y,z \<in> field(r), but these
  caused expensive case splits!*)
lemma rtrancl_induct [case_names initial step, induct set: rtrancl]:
  "[| <a,b> \<in> r^*;
      P(a);
      !!y z.[| <a,y> \<in> r^*;  <y,z> \<in> r;  P(y) |] ==> P(z)
   |] ==> P(b)"
(*by induction on this formula*)
apply (subgoal_tac "\<forall>y. <a,b> = <a,y> \<longrightarrow> P (y) ")
(*now solve first subgoal: this formula is sufficient*)
apply (erule spec [THEN mp], rule refl)
(*now do the induction*)
apply (erule rtrancl_full_induct, blast+)
done

(*transitivity of transitive closure!! -- by induction.*)
lemma trans_rtrancl: "trans(r^*)"
apply (unfold trans_def)
apply (intro allI impI)
apply (erule_tac b = z in rtrancl_induct, assumption)
apply (blast intro: rtrancl_into_rtrancl)
done

lemmas rtrancl_trans = trans_rtrancl [THEN transD]

(*elimination of rtrancl -- by induction on a special formula*)
lemma rtranclE:
    "[| <a,b> \<in> r^*;  (a=b) ==> P;
        !!y.[| <a,y> \<in> r^*;   <y,b> \<in> r |] ==> P |]
     ==> P"
apply (subgoal_tac "a = b | (\<exists>y. <a,y> \<in> r^* & <y,b> \<in> r) ")
(*see HOL/trancl*)
apply blast
apply (erule rtrancl_induct, blast+)
done


(**** The relation trancl ****)

(*Transitivity of r^+ is proved by transitivity of r^*  *)
lemma trans_trancl: "trans(r^+)"
apply (unfold trans_def trancl_def)
apply (blast intro: rtrancl_into_rtrancl
                    trans_rtrancl [THEN transD, THEN compI])
done

lemmas trans_on_trancl = trans_trancl [THEN trans_imp_trans_on]

lemmas trancl_trans = trans_trancl [THEN transD]

(** Conversions between trancl and rtrancl **)

lemma trancl_into_rtrancl: "<a,b> \<in> r^+ ==> <a,b> \<in> r^*"
apply (unfold trancl_def)
apply (blast intro: rtrancl_into_rtrancl)
done

(*r^+ contains all pairs in r  *)
lemma r_into_trancl: "<a,b> \<in> r ==> <a,b> \<in> r^+"
apply (unfold trancl_def)
apply (blast intro!: rtrancl_refl)
done

(*The premise ensures that r consists entirely of pairs*)
lemma r_subset_trancl: "relation(r) ==> r \<subseteq> r^+"
by (simp add: relation_def, blast intro: r_into_trancl)


(*intro rule by definition: from r^* and r  *)
lemma rtrancl_into_trancl1: "[| <a,b> \<in> r^*;  <b,c> \<in> r |]   ==>  <a,c> \<in> r^+"
by (unfold trancl_def, blast)

(*intro rule from r and r^*  *)
lemma rtrancl_into_trancl2:
    "[| <a,b> \<in> r;  <b,c> \<in> r^* |]   ==>  <a,c> \<in> r^+"
apply (erule rtrancl_induct)
 apply (erule r_into_trancl)
apply (blast intro: r_into_trancl trancl_trans)
done

(*Nice induction rule for trancl*)
lemma trancl_induct [case_names initial step, induct set: trancl]:
  "[| <a,b> \<in> r^+;
      !!y.  [| <a,y> \<in> r |] ==> P(y);
      !!y z.[| <a,y> \<in> r^+;  <y,z> \<in> r;  P(y) |] ==> P(z)
   |] ==> P(b)"
apply (rule compEpair)
apply (unfold trancl_def, assumption)
(*by induction on this formula*)
apply (subgoal_tac "\<forall>z. <y,z> \<in> r \<longrightarrow> P (z) ")
(*now solve first subgoal: this formula is sufficient*)
 apply blast
apply (erule rtrancl_induct)
apply (blast intro: rtrancl_into_trancl1)+
done

(*elimination of r^+ -- NOT an induction rule*)
lemma tranclE:
    "[| <a,b> \<in> r^+;
        <a,b> \<in> r ==> P;
        !!y.[| <a,y> \<in> r^+; <y,b> \<in> r |] ==> P
     |] ==> P"
apply (subgoal_tac "<a,b> \<in> r | (\<exists>y. <a,y> \<in> r^+ & <y,b> \<in> r) ")
apply blast
apply (rule compEpair)
apply (unfold trancl_def, assumption)
apply (erule rtranclE)
apply (blast intro: rtrancl_into_trancl1)+
done

lemma trancl_type: "r^+ \<subseteq> field(r)*field(r)"
apply (unfold trancl_def)
apply (blast elim: rtrancl_type [THEN subsetD, THEN SigmaE2])
done

lemma relation_trancl: "relation(r^+)"
apply (simp add: relation_def)
apply (blast dest: trancl_type [THEN subsetD])
done

lemma trancl_subset_times: "r \<subseteq> A * A ==> r^+ \<subseteq> A * A"
by (insert trancl_type [of r], blast)

lemma trancl_mono: "r<=s ==> r^+ \<subseteq> s^+"
by (unfold trancl_def, intro comp_mono rtrancl_mono)

lemma trancl_eq_r: "[|relation(r); trans(r)|] ==> r^+ = r"
apply (rule equalityI)
 prefer 2 apply (erule r_subset_trancl, clarify)
apply (frule trancl_type [THEN subsetD], clarify)
apply (erule trancl_induct, assumption)
apply (blast dest: transD)
done


(** Suggested by Sidi Ould Ehmety **)

lemma rtrancl_idemp [simp]: "(r^*)^* = r^*"
apply (rule equalityI, auto)
 prefer 2
 apply (frule rtrancl_type [THEN subsetD])
 apply (blast intro: r_into_rtrancl )
txt{*converse direction*}
apply (frule rtrancl_type [THEN subsetD], clarify)
apply (erule rtrancl_induct)
apply (simp add: rtrancl_refl rtrancl_field)
apply (blast intro: rtrancl_trans)
done

lemma rtrancl_subset: "[| R \<subseteq> S; S \<subseteq> R^* |] ==> S^* = R^*"
apply (drule rtrancl_mono)
apply (drule rtrancl_mono, simp_all, blast)
done

lemma rtrancl_Un_rtrancl:
     "[| relation(r); relation(s) |] ==> (r^* \<union> s^*)^* = (r \<union> s)^*"
apply (rule rtrancl_subset)
apply (blast dest: r_subset_rtrancl)
apply (blast intro: rtrancl_mono [THEN subsetD])
done

(*** "converse" laws by Sidi Ould Ehmety ***)

(** rtrancl **)

lemma rtrancl_converseD: "<x,y>:converse(r)^* ==> <x,y>:converse(r^*)"
apply (rule converseI)
apply (frule rtrancl_type [THEN subsetD])
apply (erule rtrancl_induct)
apply (blast intro: rtrancl_refl)
apply (blast intro: r_into_rtrancl rtrancl_trans)
done

lemma rtrancl_converseI: "<x,y>:converse(r^*) ==> <x,y>:converse(r)^*"
apply (drule converseD)
apply (frule rtrancl_type [THEN subsetD])
apply (erule rtrancl_induct)
apply (blast intro: rtrancl_refl)
apply (blast intro: r_into_rtrancl rtrancl_trans)
done

lemma rtrancl_converse: "converse(r)^* = converse(r^*)"
apply (safe intro!: equalityI)
apply (frule rtrancl_type [THEN subsetD])
apply (safe dest!: rtrancl_converseD intro!: rtrancl_converseI)
done

(** trancl **)

lemma trancl_converseD: "<a, b>:converse(r)^+ ==> <a, b>:converse(r^+)"
apply (erule trancl_induct)
apply (auto intro: r_into_trancl trancl_trans)
done

lemma trancl_converseI: "<x,y>:converse(r^+) ==> <x,y>:converse(r)^+"
apply (drule converseD)
apply (erule trancl_induct)
apply (auto intro: r_into_trancl trancl_trans)
done

lemma trancl_converse: "converse(r)^+ = converse(r^+)"
apply (safe intro!: equalityI)
apply (frule trancl_type [THEN subsetD])
apply (safe dest!: trancl_converseD intro!: trancl_converseI)
done

lemma converse_trancl_induct [case_names initial step, consumes 1]:
"[| <a, b>:r^+; !!y. <y, b> :r ==> P(y);
      !!y z. [| <y, z> \<in> r; <z, b> \<in> r^+; P(z) |] ==> P(y) |]
       ==> P(a)"
apply (drule converseI)
apply (simp (no_asm_use) add: trancl_converse [symmetric])
apply (erule trancl_induct)
apply (auto simp add: trancl_converse)
done

end
