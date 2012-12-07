(*  Title:      POPLmark/POPLmarkRecordCtxt.thy
    Author:     Stefan Berghofer, TU Muenchen, 2005
*)

theory POPLmarkRecordCtxt
imports POPLmarkRecord
begin

section {* Evaluation contexts *}

text {*
\label{sec:evaluation-ctxt}
In this section, we present a different way of formalizing the evaluation relation.
Rather than using additional congruence rules, we first formalize a set @{text ctxt}
of evaluation contexts, describing the locations in a term where reductions
can occur. We have chosen a higher-order formalization of evaluation contexts as
functions from terms to terms. We define simultaneously a set @{text rctxt}
of evaluation contexts for records represented as functions from terms to lists
of fields.
*}

inductive_set
  ctxt :: "(trm \<Rightarrow> trm) set"
  and rctxt :: "(trm \<Rightarrow> rcd) set"
where
  C_Hole: "(\<lambda>t. t) \<in> ctxt"
| C_App1: "E \<in> ctxt \<Longrightarrow> (\<lambda>t. E t \<bullet> u) \<in> ctxt"
| C_App2: "v \<in> value \<Longrightarrow> E \<in> ctxt \<Longrightarrow> (\<lambda>t. v \<bullet> E t) \<in> ctxt"
| C_TApp: "E \<in> ctxt \<Longrightarrow> (\<lambda>t. E t \<bullet>\<^isub>\<tau> T) \<in> ctxt"
| C_Proj: "E \<in> ctxt \<Longrightarrow> (\<lambda>t. E t..l) \<in> ctxt"
| C_Rcd: "E \<in> rctxt \<Longrightarrow> (\<lambda>t. Rcd (E t)) \<in> ctxt"
| C_Let: "E \<in> ctxt \<Longrightarrow> (\<lambda>t. LET p = E t IN u) \<in> ctxt"
| C_hd: "E \<in> ctxt \<Longrightarrow> (\<lambda>t. (l, E t) \<Colon> fs) \<in> rctxt"
| C_tl: "v \<in> value \<Longrightarrow> E \<in> rctxt \<Longrightarrow> (\<lambda>t. (l, v) \<Colon> E t) \<in> rctxt"

lemmas rctxt_induct = ctxt_rctxt.inducts(2)
  [of _ "\<lambda>x. True", simplified True_simps, consumes 1, case_names C_hd C_tl]

lemma rctxt_labels:
  assumes H: "E \<in> rctxt"
  shows "E t\<langle>l\<rangle>\<^isub>? = \<bottom> \<Longrightarrow> E t'\<langle>l\<rangle>\<^isub>? = \<bottom>" using H
  by (induct rule: rctxt_induct) auto

text {*
The evaluation relation @{text "t \<longmapsto>\<^sub>c t'"} is now characterized by the rule @{text E_Ctxt},
which allows reductions in arbitrary contexts, as well as the rules @{text E_Abs},
@{text E_TAbs}, @{text E_LetV}, and @{text E_ProjRcd} describing the ``immediate''
reductions, which have already been presented in \secref{sec:evaluation} and
\secref{sec:evaluation-rcd}.
*}

inductive
  eval :: "trm \<Rightarrow> trm \<Rightarrow> bool"  (infixl "\<longmapsto>\<^sub>c" 50)
where
  E_Ctxt: "t \<longmapsto>\<^sub>c t' \<Longrightarrow> E \<in> ctxt \<Longrightarrow> E t \<longmapsto>\<^sub>c E t'"
| E_Abs: "v\<^isub>2 \<in> value \<Longrightarrow> (\<lambda>:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet> v\<^isub>2 \<longmapsto>\<^sub>c t\<^isub>1\<^isub>2[0 \<mapsto> v\<^isub>2]"
| E_TAbs: "(\<lambda><:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet>\<^isub>\<tau> T\<^isub>2 \<longmapsto>\<^sub>c t\<^isub>1\<^isub>2[0 \<mapsto>\<^isub>\<tau> T\<^isub>2]"
| E_LetV: "v \<in> value \<Longrightarrow> \<turnstile> p \<rhd> v \<Rightarrow> ts \<Longrightarrow> (LET p = v IN t) \<longmapsto>\<^sub>c t[0 \<mapsto>\<^isub>s ts]"
| E_ProjRcd: "fs\<langle>l\<rangle>\<^isub>? = \<lfloor>v\<rfloor> \<Longrightarrow> v \<in> value \<Longrightarrow> Rcd fs..l \<longmapsto>\<^sub>c v"

text {*
In the proof of the preservation theorem, the case corresponding to the rule @{text E_Ctxt}
requires a lemma stating that replacing
a term @{term t} in a well-typed term of the form @{term "E t"}, where @{term E} is
a context, by a term @{term t'} of the same type does not change the type of the
resulting term @{term "E t'"}.
The proof is by mutual induction on the typing derivations for terms and records.
*}

lemma context_typing: -- {* A.18 *}
  "\<Gamma> \<turnstile> u : T \<Longrightarrow> E \<in> ctxt \<Longrightarrow> u = E t \<Longrightarrow>
     (\<And>T\<^isub>0. \<Gamma> \<turnstile> t : T\<^isub>0 \<Longrightarrow> \<Gamma> \<turnstile> t' : T\<^isub>0) \<Longrightarrow> \<Gamma> \<turnstile> E t' : T"
  "\<Gamma> \<turnstile> fs [:] fTs \<Longrightarrow> E\<^isub>r \<in> rctxt \<Longrightarrow> fs = E\<^isub>r t \<Longrightarrow>
     (\<And>T\<^isub>0. \<Gamma> \<turnstile> t : T\<^isub>0 \<Longrightarrow> \<Gamma> \<turnstile> t' : T\<^isub>0) \<Longrightarrow> \<Gamma> \<turnstile> E\<^isub>r t' [:] fTs"
proof (induct arbitrary: E t t' and E\<^isub>r t t' set: typing typings)
  case (T_Var \<Gamma> i U T E t t')
  from `E \<in> ctxt`
  have "E = (\<lambda>t. t)" using T_Var by cases simp_all
  with T_Var show ?case by (blast intro: typing_typings.intros)
next
  case (T_Abs T\<^isub>1 T\<^isub>2 \<Gamma> t\<^isub>2 E t t')
  from `E \<in> ctxt`
  have "E = (\<lambda>t. t)" using T_Abs by cases simp_all
  with T_Abs show ?case by (blast intro: typing_typings.intros)
next
  case (T_App \<Gamma> t\<^isub>1 T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 t\<^isub>2 E t t')
  from `E \<in> ctxt`
  show ?case using T_App
    by cases (simp_all, (blast intro: typing_typings.intros)+)
next
  case (T_TAbs T\<^isub>1 \<Gamma> t\<^isub>2 T\<^isub>2 E t t')
  from `E \<in> ctxt`
  have "E = (\<lambda>t. t)" using T_TAbs by cases simp_all
  with T_TAbs show ?case by (blast intro: typing_typings.intros)
next
  case (T_TApp \<Gamma> t\<^isub>1 T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 T\<^isub>2 E t t')
  from `E \<in> ctxt`
  show ?case using T_TApp
    by cases (simp_all, (blast intro: typing_typings.intros)+)
next
  case (T_Sub \<Gamma> t S T E ta t')
  thus ?case by (blast intro: typing_typings.intros)
next
  case (T_Let \<Gamma> t\<^isub>1 T\<^isub>1 p \<Delta> t\<^isub>2 T\<^isub>2 E t t')
  from `E \<in> ctxt`
  show ?case using T_Let
    by cases (simp_all, (blast intro: typing_typings.intros)+)
next
  case (T_Rcd \<Gamma> fs fTs E t t')
  from `E \<in> ctxt`
  show ?case using T_Rcd
    by cases (simp_all, (blast intro: typing_typings.intros)+)
next
  case (T_Proj \<Gamma> t fTs l T E ta t')
  from `E \<in> ctxt`
  show ?case using T_Proj
    by cases (simp_all, (blast intro: typing_typings.intros)+)
next
  case (T_Nil \<Gamma> E t t')
  from `E \<in> rctxt`
  show ?case using T_Nil
    by cases simp_all
next
  case (T_Cons \<Gamma> t T fs fTs l E ta t')
  from `E \<in> rctxt`
  show ?case using T_Cons
    by cases (blast intro: typing_typings.intros rctxt_labels)+
qed

text {*
The fact that immediate reduction preserves the types of terms is
proved in several parts. The proof of each statement is by induction
on the typing derivation.
*}

theorem Abs_preservation: -- {* A.19(1) *}
  assumes H: "\<Gamma> \<turnstile> (\<lambda>:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet> t\<^isub>2 : T"
  shows "\<Gamma> \<turnstile> t\<^isub>1\<^isub>2[0 \<mapsto> t\<^isub>2] : T"
  using H
proof (induct \<Gamma> "(\<lambda>:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet> t\<^isub>2" T arbitrary: T\<^isub>1\<^isub>1 t\<^isub>1\<^isub>2 t\<^isub>2 rule: typing_induct)
  case (T_App \<Gamma> T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 t\<^isub>2 T\<^isub>1\<^isub>1' t\<^isub>1\<^isub>2)
  from `\<Gamma> \<turnstile> (\<lambda>:T\<^isub>1\<^isub>1'. t\<^isub>1\<^isub>2) : T\<^isub>1\<^isub>1 \<rightarrow> T\<^isub>1\<^isub>2`
  obtain S'
    where T\<^isub>1\<^isub>1: "\<Gamma> \<turnstile> T\<^isub>1\<^isub>1 <: T\<^isub>1\<^isub>1'"
    and t\<^isub>1\<^isub>2: "VarB T\<^isub>1\<^isub>1' \<Colon> \<Gamma> \<turnstile> t\<^isub>1\<^isub>2 : S'"
    and S': "\<Gamma> \<turnstile> S'[0 \<mapsto>\<^isub>\<tau> Top]\<^isub>\<tau> <: T\<^isub>1\<^isub>2" by (rule Abs_type' [simplified]) blast
  from `\<Gamma> \<turnstile> t\<^isub>2 : T\<^isub>1\<^isub>1`
  have "\<Gamma> \<turnstile> t\<^isub>2 : T\<^isub>1\<^isub>1'" using T\<^isub>1\<^isub>1 by (rule T_Sub)
  with t\<^isub>1\<^isub>2 have "\<Gamma> \<turnstile> t\<^isub>1\<^isub>2[0 \<mapsto> t\<^isub>2] : S'[0 \<mapsto>\<^isub>\<tau> Top]\<^isub>\<tau>"
    by (rule subst_type [where \<Delta>="[]", simplified])
  then show ?case using S' by (rule T_Sub)
next
  case T_Sub
  thus ?case by (blast intro: typing_typings.intros)
qed

theorem TAbs_preservation: -- {* A.19(2) *}
  assumes H: "\<Gamma> \<turnstile> (\<lambda><:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet>\<^isub>\<tau> T\<^isub>2 : T"
  shows "\<Gamma> \<turnstile> t\<^isub>1\<^isub>2[0 \<mapsto>\<^isub>\<tau> T\<^isub>2] : T"
  using H
proof (induct \<Gamma> "(\<lambda><:T\<^isub>1\<^isub>1. t\<^isub>1\<^isub>2) \<bullet>\<^isub>\<tau> T\<^isub>2" T arbitrary: T\<^isub>1\<^isub>1 t\<^isub>1\<^isub>2 T\<^isub>2 rule: typing_induct)
  case (T_TApp \<Gamma> T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 T\<^isub>2 T\<^isub>1\<^isub>1' t\<^isub>1\<^isub>2)
  from `\<Gamma> \<turnstile> (\<lambda><:T\<^isub>1\<^isub>1'. t\<^isub>1\<^isub>2) : (\<forall><:T\<^isub>1\<^isub>1. T\<^isub>1\<^isub>2)`
  obtain S'
    where "TVarB T\<^isub>1\<^isub>1 \<Colon> \<Gamma> \<turnstile> t\<^isub>1\<^isub>2 : S'"
    and "TVarB T\<^isub>1\<^isub>1 \<Colon> \<Gamma> \<turnstile> S' <: T\<^isub>1\<^isub>2" by (rule TAbs_type') blast
  hence "TVarB T\<^isub>1\<^isub>1 \<Colon> \<Gamma> \<turnstile> t\<^isub>1\<^isub>2 : T\<^isub>1\<^isub>2" by (rule T_Sub)
  then show ?case using `\<Gamma> \<turnstile> T\<^isub>2 <: T\<^isub>1\<^isub>1`
    by (rule substT_type [where \<Delta>="[]", simplified])
next
  case T_Sub
  thus ?case by (blast intro: typing_typings.intros)
qed

theorem Let_preservation: -- {* A.19(3) *}
  assumes H: "\<Gamma> \<turnstile> (LET p = t\<^isub>1 IN t\<^isub>2) : T"
  shows "\<turnstile> p \<rhd> t\<^isub>1 \<Rightarrow> ts \<Longrightarrow> \<Gamma> \<turnstile> t\<^isub>2[0 \<mapsto>\<^isub>s ts] : T"
  using H
proof (induct \<Gamma> "LET p = t\<^isub>1 IN t\<^isub>2" T arbitrary: p t\<^isub>1 t\<^isub>2 ts rule: typing_induct)
  case (T_Let \<Gamma> t\<^isub>1 T\<^isub>1 p \<Delta> t\<^isub>2 T\<^isub>2 ts)
  from `\<turnstile> p : T\<^isub>1 \<Rightarrow> \<Delta>` `\<Gamma> \<turnstile> t\<^isub>1 : T\<^isub>1` `\<Delta> @ \<Gamma> \<turnstile> t\<^isub>2 : T\<^isub>2` `\<turnstile> p \<rhd> t\<^isub>1 \<Rightarrow> ts`
  show ?case
    by (rule match_type(1) [of _ _ _ _ _ "[]", simplified])
next
  case T_Sub
  thus ?case by (blast intro: typing_typings.intros)
qed

theorem Proj_preservation: -- {* A.19(4) *}
  assumes H: "\<Gamma> \<turnstile> Rcd fs..l : T"
  shows "fs\<langle>l\<rangle>\<^isub>? = \<lfloor>v\<rfloor> \<Longrightarrow> \<Gamma> \<turnstile> v : T"
  using H
proof (induct \<Gamma> "Rcd fs..l" T arbitrary: fs l v rule: typing_induct)
  case (T_Proj \<Gamma> fTs l T fs v)
  from `\<Gamma> \<turnstile> Rcd fs : RcdT fTs`
  have "\<forall>(l, U)\<in>set fTs. \<exists>u. fs\<langle>l\<rangle>\<^isub>? = \<lfloor>u\<rfloor> \<and> \<Gamma> \<turnstile> u : U"
    by (rule Rcd_type1')
  with T_Proj show ?case by (fastforce dest: assoc_set)
next
  case T_Sub
  thus ?case by (blast intro: typing_typings.intros)
qed

theorem preservation: -- {* A.20 *}
  assumes H: "t \<longmapsto>\<^sub>c t'"
  shows "\<Gamma> \<turnstile> t : T \<Longrightarrow> \<Gamma> \<turnstile> t' : T" using H
proof (induct arbitrary: \<Gamma> T)
  case (E_Ctxt t t' E \<Gamma> T)
  from E_Ctxt(4,3) refl E_Ctxt(2)
  show ?case by (rule context_typing)
next
  case (E_Abs v\<^isub>2 T\<^isub>1\<^isub>1 t\<^isub>1\<^isub>2 \<Gamma> T)
  from E_Abs(2)
  show ?case by (rule Abs_preservation)
next
  case (E_TAbs T\<^isub>1\<^isub>1 t\<^isub>1\<^isub>2 T\<^isub>2 \<Gamma> T)
  thus ?case by (rule TAbs_preservation)
next
  case (E_LetV v p ts t \<Gamma> T)
  from E_LetV(3,2)
  show ?case by (rule Let_preservation)
next
  case (E_ProjRcd fs l v \<Gamma> T)
  from E_ProjRcd(3,1)
  show ?case by (rule Proj_preservation)
qed

text {*
For the proof of the progress theorem, we need a lemma stating that each well-typed,
closed term @{term t} is either a canonical value, or can be decomposed into an
evaluation context @{term E} and a term @{term "t\<^isub>0"} such that @{term "t\<^isub>0"} is a redex.
The proof of this result, which is called the {\it decomposition lemma}, is again
by induction on the typing derivation.
A similar property is also needed for records.
*}

theorem context_decomp: -- {* A.15 *}
  "[] \<turnstile> t : T \<Longrightarrow> 
     t \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')"
  "[] \<turnstile> fs [:] fTs \<Longrightarrow>
     (\<forall>(l, t) \<in> set fs. t \<in> value) \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> rctxt \<and> fs = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')"
proof (induct "[]::env" t T and "[]::env" fs fTs set: typing typings)
  case T_Var
  thus ?case by simp
next
  case T_Abs
  from value.Abs show ?case ..
next
  case (T_App t\<^isub>1 T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 t\<^isub>2)
  from `t\<^isub>1 \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')`
  show ?case
  proof
    assume t\<^isub>1_val: "t\<^isub>1 \<in> value"
    with T_App obtain t S where t\<^isub>1: "t\<^isub>1 = (\<lambda>:S. t)"
      by (auto dest!: Fun_canonical)
    from `t\<^isub>2 \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>2 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')`
    show ?thesis
    proof
      assume "t\<^isub>2 \<in> value"
      with t\<^isub>1 have "t\<^isub>1 \<bullet> t\<^isub>2 \<longmapsto>\<^sub>c t[0 \<mapsto> t\<^isub>2]"
        by simp (rule eval.intros)
      thus ?thesis by (iprover intro: C_Hole)
    next
      assume "\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>2 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0'"
      with t\<^isub>1_val show ?thesis by (iprover intro: ctxt_rctxt.intros)
    qed
  next
    assume "\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0'"
    thus ?thesis by (iprover intro: ctxt_rctxt.intros)
  qed
next
  case T_TAbs
  from value.TAbs show ?case ..
next
  case (T_TApp t\<^isub>1 T\<^isub>1\<^isub>1 T\<^isub>1\<^isub>2 T\<^isub>2)
  from `t\<^isub>1 \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')`
  show ?case
  proof
    assume "t\<^isub>1 \<in> value"
    with T_TApp obtain t S where "t\<^isub>1 = (\<lambda><:S. t)"
      by (auto dest!: TyAll_canonical)
    hence "t\<^isub>1 \<bullet>\<^isub>\<tau> T\<^isub>2 \<longmapsto>\<^sub>c t[0 \<mapsto>\<^isub>\<tau> T\<^isub>2]" by simp (rule eval.intros)
    thus ?thesis by (iprover intro: C_Hole)
  next
    assume "\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0'"
    thus ?thesis by (iprover intro: ctxt_rctxt.intros)
  qed
next
  case (T_Sub t S T)
  show ?case by (rule T_Sub)
next
  case (T_Let t\<^isub>1 T\<^isub>1 p \<Delta> t\<^isub>2 T\<^isub>2)
  from `t\<^isub>1 \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')`
  show ?case
  proof
    assume t\<^isub>1: "t\<^isub>1 \<in> value"
    with T_Let have "\<exists>ts. \<turnstile> p \<rhd> t\<^isub>1 \<Rightarrow> ts"
      by (auto intro: ptyping_match)
    with t\<^isub>1 show ?thesis by (iprover intro: eval.intros C_Hole)
  next
    assume "\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t\<^isub>1 = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0'"
    thus ?thesis by (iprover intro: ctxt_rctxt.intros)
  qed
next
  case (T_Rcd fs fTs)
  thus ?case by (blast intro: value.intros eval.intros ctxt_rctxt.intros)
next
  case (T_Proj t fTs l T)
  from `t \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')`
  show ?case
  proof
    assume tv: "t \<in> value"
    with T_Proj obtain fs where
      t: "t = Rcd fs" and fs: "\<forall>(l, t) \<in> set fs. t \<in> value"
      by (auto dest: RcdT_canonical)
    with T_Proj have "[] \<turnstile> Rcd fs : RcdT fTs" by simp
    hence "\<forall>(l, U)\<in>set fTs. \<exists>u. fs\<langle>l\<rangle>\<^isub>? = \<lfloor>u\<rfloor> \<and> [] \<turnstile> u : U"
      by (rule Rcd_type1')
    with T_Proj obtain u where u: "fs\<langle>l\<rangle>\<^isub>? = \<lfloor>u\<rfloor>" by (blast dest: assoc_set)
    with fs have "u \<in> value" by (blast dest: assoc_set)
    with u t show ?thesis by (iprover intro: eval.intros C_Hole)
  next
    assume "\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0'"
    thus ?case by (iprover intro: ctxt_rctxt.intros)
  qed
next
  case T_Nil
  show ?case by simp
next
  case (T_Cons t T fs fTs l)
  thus ?case by (auto intro: ctxt_rctxt.intros)
qed

theorem progress: -- {* A.16 *}
  assumes H: "[] \<turnstile> t : T"
  shows "t \<in> value \<or> (\<exists>t'. t \<longmapsto>\<^sub>c t')"
proof -
  from H have "t \<in> value \<or> (\<exists>E t\<^isub>0 t\<^isub>0'. E \<in> ctxt \<and> t = E t\<^isub>0 \<and> t\<^isub>0 \<longmapsto>\<^sub>c t\<^isub>0')"
    by (rule context_decomp)
  thus ?thesis by (iprover intro: eval.intros)
qed

text {*
Finally, we prove that the two definitions of the evaluation relation
are equivalent. The proof that @{term "t \<longmapsto>\<^sub>c t'"} implies @{term "t \<longmapsto> t'"}
requires a lemma stating that @{text "\<longmapsto>"} is compatible with evaluation contexts.
*}

lemma ctxt_imp_eval:
  "E \<in> ctxt \<Longrightarrow> t \<longmapsto> t' \<Longrightarrow> E t \<longmapsto> E t'"
  "E\<^isub>r \<in> rctxt \<Longrightarrow> t \<longmapsto> t' \<Longrightarrow> E\<^isub>r t [\<longmapsto>] E\<^isub>r t'"
  by (induct rule: ctxt_rctxt.inducts) (auto intro: eval_evals.intros)

lemma eval_evalc_eq: "(t \<longmapsto> t') = (t \<longmapsto>\<^sub>c t')"
proof
  fix ts ts'
  have r: "t \<longmapsto> t' \<Longrightarrow> t \<longmapsto>\<^sub>c t'" and
    "ts [\<longmapsto>] ts' \<Longrightarrow> \<exists>E t t'. E \<in> rctxt \<and> ts = E t \<and> ts' = E t' \<and> t \<longmapsto>\<^sub>c t'"
    by (induct rule: eval_evals.inducts) (iprover intro: ctxt_rctxt.intros eval.intros)+
  assume "t \<longmapsto> t'"
  thus "t \<longmapsto>\<^sub>c t'" by (rule r)
next
  assume "t \<longmapsto>\<^sub>c t'"
  thus "t \<longmapsto> t'"
    by induct (auto intro: eval_evals.intros ctxt_imp_eval)
qed

end
