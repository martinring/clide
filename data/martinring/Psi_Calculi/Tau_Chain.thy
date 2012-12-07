(* 
   Title: Psi-calculi   
   Author/Maintainer: Jesper Bengtson (jebe@itu.dk), 2012
*)
theory Tau_Chain
  imports Semantics
begin

context env begin

abbreviation tauChain :: "'b \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> bool" ("_ \<rhd> _ \<Longrightarrow>\<^sup>^\<^sub>\<tau> _" [80, 80, 80] 80)
where "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<equiv> (P, P') \<in> {(P, P'). \<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'}^*"

abbreviation tauStepChain :: "'b \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> bool" ("_ \<rhd> _ \<Longrightarrow>\<^sub>\<tau> _" [80, 80, 80] 80)
where "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P' \<equiv> (P, P') \<in> {(P, P'). \<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'}^+"

abbreviation tauContextChain :: "('a, 'b, 'c) psi \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> bool" ("_ \<Longrightarrow>\<^sup>^\<^sub>\<tau> _" [80, 80] 80)
where "P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<equiv> \<one> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
abbreviation tauContextStepChain :: "('a, 'b, 'c) psi \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> bool" ("_ \<Longrightarrow>\<^sub>\<tau> _" [80, 80] 80)
where "P \<Longrightarrow>\<^sub>\<tau> P' \<equiv> \<one> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"

lemmas tauChainInduct[consumes 1, case_names TauBase TauStep] = rtrancl.induct[of _ _ "{(P, P'). \<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'}", simplified]
lemmas tauStepChainInduct[consumes 1, case_names TauBase TauStep] = trancl.induct[of _ _ "{(P, P'). \<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'}", simplified]


lemma tauActTauStepChain:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'"

  shows "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
using assms by auto

lemma tauActTauChain:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'"

  shows "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
using assms by(auto simp add: rtrancl_eq_or_trancl)

lemma tauStepChainEqvt[eqvt]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   p  :: "name prm"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"

  shows "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sub>\<tau> (p \<bullet> P')"
using assms
proof(induct rule: tauStepChainInduct)  
  case(TauBase P P')
  hence "\<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'" by simp
  thus ?case by(force dest: semantics.eqvt simp add: eqvts)
next
  case(TauStep P P' P'')
  hence "\<Psi> \<rhd> P' \<longmapsto>\<tau> \<prec> P''" by simp  
  hence "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P') \<longmapsto>\<tau> \<prec> (p \<bullet> P'')" by(force dest: semantics.eqvt simp add: eqvts)
  with `(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sub>\<tau> (p \<bullet> P')` show ?case
    by(subst trancl.trancl_into_trancl) auto
qed

lemma tauChainEqvt[eqvt]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   p  :: "name prm"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"

  shows "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> P')"
using assms
by(auto simp add: rtrancl_eq_or_trancl eqvts)

lemma tauStepChainEqvt'[eqvt]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   p  :: "name prm"

  shows "(p \<bullet> (\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P')) = (p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sub>\<tau> (p \<bullet> P')"
apply(auto simp add: eqvts perm_set_def pt_bij[OF pt_name_inst, OF at_name_inst])
by(drule_tac p="rev p" in tauStepChainEqvt) auto

lemma tauChainEqvt'[eqvt]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   p  :: "name prm"

  shows "(p \<bullet> (\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P')) = (p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> P')"
apply(auto simp add: eqvts perm_set_def pt_bij[OF pt_name_inst, OF at_name_inst] rtrancl_eq_or_trancl)
by(drule_tac p="rev p" in tauStepChainEqvt) auto

lemma tauStepChainFresh:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   x  :: name

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "x \<sharp> P"

  shows "x \<sharp> P'"
using assms
by(induct rule: trancl.induct) (auto dest: tauFreshDerivative)

lemma tauChainFresh:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   x  :: name

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "x \<sharp> P"

  shows "x \<sharp> P'"
using assms
by(auto simp add: rtrancl_eq_or_trancl intro: tauStepChainFresh)

lemma tauStepChainFreshChain:
  fixes \<Psi>    :: 'b
  and   P     :: "('a, 'b, 'c) psi"
  and   P'    :: "('a, 'b, 'c) psi"
  and   xvec  :: "name list"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "xvec \<sharp>* P"

  shows "xvec \<sharp>* P'"
using assms
by(induct xvec) (auto intro: tauStepChainFresh)

lemma tauChainFreshChain:
  fixes \<Psi>    :: 'b
  and   P     :: "('a, 'b, 'c) psi"
  and   P'    :: "('a, 'b, 'c) psi"
  and   xvec  :: "name list"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "xvec \<sharp>* P"

  shows "xvec \<sharp>* P'"
using assms
by(induct xvec) (auto intro: tauChainFresh)

lemma tauStepChainCase:
  fixes \<Psi>  :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   \<phi>  :: 'c
  and   Cs :: "('c \<times> ('a, 'b, 'c) psi) list"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "(\<phi>, P) mem Cs"
  and     "\<Psi> \<turnstile> \<phi>"
  and     "guarded P"

  shows "\<Psi> \<rhd> (Cases Cs) \<Longrightarrow>\<^sub>\<tau> P'"
using assms
by(induct rule: trancl.induct) (auto intro: Case trancl_into_trancl)

lemma tauStepChainResPres:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   x  :: name  

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "x \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>x\<rparr>P'"
using assms
by(induct rule: trancl.induct) (auto dest: Scope trancl_into_trancl)

lemma tauChainResPres:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   x  :: name  

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "x \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>x\<rparr>P'"
using assms
by(auto simp add: rtrancl_eq_or_trancl intro: tauStepChainResPres)

lemma tauStepChainResChainPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   P'   :: "('a, 'b, 'c) psi"
  and   xvec :: "name list"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "xvec \<sharp>* \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>P'"
using assms
by(induct xvec) (auto intro: tauStepChainResPres)

lemma tauChainResChainPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   P'   :: "('a, 'b, 'c) psi"
  and   xvec :: "name list"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "xvec \<sharp>* \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>P'"
using assms
by(induct xvec) (auto intro: tauChainResPres)

lemma tauStepChainPar1:
  fixes \<Psi>  :: 'b
  and   \<Psi>\<^isub>Q :: 'b
  and   P   :: "('a, 'b, 'c) psi"
  and   P'  :: "('a, 'b, 'c) psi"
  and   Q   :: "('a, 'b, 'c) psi"
  and   A\<^isub>Q :: "name list"

  assumes "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>"
  and     "A\<^isub>Q \<sharp>* \<Psi>"
  and     "A\<^isub>Q \<sharp>* P"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sub>\<tau> P' \<parallel> Q"
using assms
by(induct rule: trancl.induct)  (auto dest: Par1 tauStepChainFreshChain trancl_into_trancl)

lemma tauChainPar1:
  fixes \<Psi>  :: 'b
  and   \<Psi>\<^isub>Q :: 'b
  and   P   :: "('a, 'b, 'c) psi"
  and   P'  :: "('a, 'b, 'c) psi"
  and   Q   :: "('a, 'b, 'c) psi"
  and   A\<^isub>Q :: "name list"

  assumes "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>"
  and     "A\<^isub>Q \<sharp>* \<Psi>"
  and     "A\<^isub>Q \<sharp>* P"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<parallel> Q"
using assms
by(auto simp add: rtrancl_eq_or_trancl intro: tauStepChainPar1)

lemma tauStepChainPar2:
  fixes \<Psi>  :: 'b
  and   \<Psi>\<^isub>P :: 'b
  and   Q   :: "('a, 'b, 'c) psi"
  and   Q'  :: "('a, 'b, 'c) psi"
  and   P   :: "('a, 'b, 'c) psi"
  and   A\<^isub>P :: "name list"

  assumes "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> Q \<Longrightarrow>\<^sub>\<tau> Q'"
  and     "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
  and     "A\<^isub>P \<sharp>* \<Psi>"
  and     "A\<^isub>P \<sharp>* Q"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sub>\<tau> P \<parallel> Q'"
using assms
by(induct rule: trancl.induct) (auto dest: Par2 trancl_into_trancl tauStepChainFreshChain)

lemma tauChainPar2:
  fixes \<Psi>  :: 'b
  and   \<Psi>\<^isub>P :: 'b
  and   Q   :: "('a, 'b, 'c) psi"
  and   Q'  :: "('a, 'b, 'c) psi"
  and   P   :: "('a, 'b, 'c) psi"
  and   A\<^isub>P :: "name list"

  assumes "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q'"
  and     "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
  and     "A\<^isub>P \<sharp>* \<Psi>"
  and     "A\<^isub>P \<sharp>* Q"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P \<parallel> Q'"
using assms
by(auto simp add: rtrancl_eq_or_trancl intro: tauStepChainPar2)

lemma tauStepChainBang:
  fixes \<Psi>  :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<parallel> !P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "guarded P"

  shows "\<Psi> \<rhd> !P \<Longrightarrow>\<^sub>\<tau> P'"
using assms
by(induct x1=="P \<parallel> !P" P' rule: trancl.induct) (auto intro: Bang dest: Bang trancl_into_trancl)

lemma tauStepChainStatEq:
  fixes \<Psi>  :: 'b
  and   P   :: "('a, 'b, 'c) psi"
  and   P'  :: "('a, 'b, 'c) psi"
  and   \<Psi>' :: 'b

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     "\<Psi> \<simeq> \<Psi>'"

  shows "\<Psi>' \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
using assms
by(induct rule: trancl.induct) (auto dest: statEqTransition trancl_into_trancl)

lemma tauChainStatEq:
  fixes \<Psi>  :: 'b
  and   P   :: "('a, 'b, 'c) psi"
  and   P'  :: "('a, 'b, 'c) psi"
  and   \<Psi>' :: 'b

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "\<Psi> \<simeq> \<Psi>'"

  shows "\<Psi>' \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
using assms
by(auto simp add: rtrancl_eq_or_trancl intro: tauStepChainStatEq)

definition weakTransition :: "'b \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow>  ('a, 'b, 'c) psi \<Rightarrow> 'a action \<Rightarrow> ('a, 'b, 'c) psi \<Rightarrow> bool" ("_ : _ \<rhd> _ \<Longrightarrow>_ \<prec> _" [80, 80, 80, 80, 80] 80)
where
  "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P' \<equiv> \<exists>P''. \<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<and> (insertAssertion (extractFrame Q) \<Psi>) \<hookrightarrow>\<^sub>F (insertAssertion (extractFrame P'') \<Psi>) \<and>
                                          \<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"

lemma weakTransitionI:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   P''  :: "('a, 'b, 'c) psi"
  and   \<alpha>   :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
  and     "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
  and     "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
using assms
by(auto simp add: weakTransition_def)

lemma weakTransitionE:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"

  assumes "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"

  obtains P'' where "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                 and "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
using assms
by(auto simp add: weakTransition_def)

lemma weakTransitionClosed[eqvt]:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   p    :: "name prm"

  assumes "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"

  shows "(p \<bullet> \<Psi>) : (p \<bullet> Q) \<rhd> (p \<bullet> P) \<Longrightarrow>(p \<bullet> \<alpha>)\<prec> (p \<bullet> P')"
proof -
  from assms obtain P'' where "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)

  from `\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''` have "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> P'')"
    by(rule tauChainEqvt)
  moreover from `insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>` 
  have "(p \<bullet> (insertAssertion (extractFrame Q) \<Psi>)) \<hookrightarrow>\<^sub>F (p \<bullet> (insertAssertion (extractFrame P'') \<Psi>))"
    by(rule FrameStatImpClosed)
  hence "insertAssertion (extractFrame(p \<bullet> Q)) (p \<bullet> \<Psi>) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(p \<bullet> P'')) (p \<bullet> \<Psi>)" by(simp add: eqvts)
  moreover from `\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'` have "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P'') \<longmapsto>(p \<bullet> (\<alpha> \<prec> P'))"
    by(rule semantics.eqvt)
  hence "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P'') \<longmapsto>(p \<bullet> \<alpha>) \<prec> (p \<bullet> P')" by(simp add: eqvts)
  ultimately show ?thesis by(rule weakTransitionI)
qed
(*
lemma weakTransitionAlpha:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   p    :: "name prm"
  and   yvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     S: "set p \<subseteq> set xvec \<times> set(p \<bullet> xvec)"
  and     "xvec \<sharp>* (p \<bullet> xvec)"
  and     "(p \<bullet> xvec) \<sharp>* P"
  and     "(p \<bullet> xvec) \<sharp>* N"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> P')"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  note PChain QeqP''
  moreover from PChain `(p \<bullet> xvec) \<sharp>* P` have "(p \<bullet> xvec) \<sharp>* P''" by(rule tauChainFreshChain)
  with P''Trans `xvec \<sharp>* (p \<bullet> xvec)` `(p \<bullet> xvec) \<sharp>* N` have "(p \<bullet> xvec) \<sharp>* P'"
    by(force intro: outputFreshChainDerivative)
  with P''Trans S `(p \<bullet> xvec) \<sharp>* N` have "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> P')"
    by(simp add: boundOutputChainAlpha'')
  ultimately show ?thesis by(rule weakTransitionI)
qed
*)
lemma weakOutputAlpha:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   p    :: "name prm"
  and   yvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> P'"
  and     S: "set p \<subseteq> set xvec \<times> set(p \<bullet> xvec)"
  and     "distinctPerm p"
  and     "xvec \<sharp>* P"
  and     "xvec \<sharp>* (p \<bullet> xvec)"
  and     "(p \<bullet> xvec) \<sharp>* M"
  and     "distinct xvec"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (p \<bullet> P')"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> P'"
    by(rule weakTransitionE)


  note PChain QeqP''
  moreover from PChain `xvec \<sharp>* P` have "xvec \<sharp>* P''" by(rule tauChainFreshChain)
  with P''Trans `xvec \<sharp>* (p \<bullet> xvec)` `distinct xvec` `(p \<bullet> xvec) \<sharp>* M` have "xvec \<sharp>* (p \<bullet> N)" and "xvec \<sharp>* P'"
    by(force intro: outputFreshChainDerivative)+
  hence "(p \<bullet> xvec) \<sharp>* (p \<bullet> p \<bullet> N)" and "(p \<bullet> xvec) \<sharp>* (p \<bullet> P')"
    by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])+
  with `distinctPerm p` have "(p \<bullet> xvec) \<sharp>* N" and "(p \<bullet> xvec) \<sharp>* (p \<bullet> P')" by simp+
  with P''Trans S `distinctPerm p` have "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (p \<bullet> P')"
    apply(simp add: residualInject)
    by(subst boundOutputChainAlpha) auto
    
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakFreshDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   x    :: name

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "x \<sharp> P"
  and     "x \<sharp> \<alpha>"
  and     "bn \<alpha> \<sharp>* subject \<alpha>"
  and     "distinct(bn \<alpha>)"

  shows "x \<sharp> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `x \<sharp> P` have "x \<sharp> P''" by(rule tauChainFresh)
  with P''Trans show "x \<sharp> P'" using `x \<sharp> \<alpha>` `bn \<alpha> \<sharp>* subject \<alpha>` `distinct(bn \<alpha>)`
    by(force intro: freeFreshDerivative)
qed

lemma weakFreshChainDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   yvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "yvec \<sharp>* P"
  and     "yvec \<sharp>* \<alpha>"
  and     "bn \<alpha> \<sharp>* subject \<alpha>"
  and     "distinct(bn \<alpha>)"

  shows "yvec \<sharp>* P'"
using assms
by(induct yvec) (auto intro: weakFreshDerivative)

lemma weakInputFreshDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   x    :: name

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>N\<rparr> \<prec> P'"
  and     "x \<sharp> P"
  and     "x \<sharp> N"

  shows "x \<sharp> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `x \<sharp> P` have "x \<sharp> P''" by(rule tauChainFresh)
  with P''Trans show "x \<sharp> P'" using `x \<sharp> N` 
    by(force intro: inputFreshDerivative)
qed

lemma weakInputFreshChainDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   xvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>N\<rparr> \<prec> P'"
  and     "xvec \<sharp>* P"
  and     "xvec \<sharp>* N"

  shows "xvec \<sharp>* P'"
using assms
by(induct xvec) (auto intro: weakInputFreshDerivative)

lemma weakOutputFreshDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   x    :: name

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     "x \<sharp> P"
  and     "x \<sharp> xvec"
  and     "xvec \<sharp>* M"
  and     "distinct xvec"

  shows "x \<sharp> N"
  and   "x \<sharp> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `x \<sharp> P` have "x \<sharp> P''" by(rule tauChainFresh)
  with P''Trans show "x \<sharp> N" and "x \<sharp> P'" using `x \<sharp> xvec` `xvec \<sharp>* M` `distinct xvec`
    by(force intro: outputFreshDerivative)+
qed

lemma weakOutputFreshChainDerivative:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   yvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     "yvec \<sharp>* P"
  and     "xvec \<sharp>* yvec"
  and     "xvec \<sharp>* M"
  and     "distinct xvec"

  shows "yvec \<sharp>* N"
  and   "yvec \<sharp>* P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `yvec \<sharp>* P` have "yvec \<sharp>* P''" by(rule tauChainFreshChain)
  with P''Trans show "yvec \<sharp>* N" and "yvec \<sharp>* P'" using `xvec \<sharp>* yvec` `xvec \<sharp>* M` `distinct xvec`
    by(force intro: outputFreshChainDerivative)+
qed

lemma weakOutputPermSubject:
  fixes \<Psi>   :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   p    :: "name prm"
  and   yvec :: "name list"
  and   zvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     S: "set p \<subseteq> set yvec \<times> set zvec"
  and     "yvec \<sharp>* \<Psi>"
  and     "zvec \<sharp>* \<Psi>"
  and     "yvec \<sharp>* P"
  and     "zvec \<sharp>* P"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>(p \<bullet> M)\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>" 
                            and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `yvec \<sharp>* P` `zvec \<sharp>* P` have "yvec \<sharp>* P''" and "zvec \<sharp>* P''"
    by(force intro: tauChainFreshChain)+

  note PChain QeqP''
  moreover from P''Trans S `yvec \<sharp>* \<Psi>` `zvec \<sharp>* \<Psi>` `yvec \<sharp>* P''` `zvec \<sharp>* P''` have "\<Psi> \<rhd> P'' \<longmapsto>(p \<bullet> M)\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule_tac outputPermSubject) (assumption | auto)
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakInputPermSubject:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   p    :: "name prm"
  and   yvec :: "name list"
  and   zvec :: "name list"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>N\<rparr> \<prec> P'"
  and     S: "set p \<subseteq> set yvec \<times> set zvec"
  and     "yvec \<sharp>* \<Psi>"
  and     "zvec \<sharp>* \<Psi>"
  and     "yvec \<sharp>* P"
  and     "zvec \<sharp>* P"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>(p \<bullet> M)\<lparr>N\<rparr> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>" 
                            and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `yvec \<sharp>* P` `zvec \<sharp>* P` have "yvec \<sharp>* P''" and "zvec \<sharp>* P''"
    by(force intro: tauChainFreshChain)+

  note PChain QeqP''
  moreover from P''Trans S `yvec \<sharp>* \<Psi>` `zvec \<sharp>* \<Psi>` `yvec \<sharp>* P''` `zvec \<sharp>* P''` have "\<Psi> \<rhd> P'' \<longmapsto>(p \<bullet> M)\<lparr>N\<rparr> \<prec> P'"
    by(rule_tac inputPermSubject) auto
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakInput:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   K    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   Tvec :: "'a list"
  and   P    :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<turnstile> M \<leftrightarrow> K"
  and     "distinct xvec" 
  and     "set xvec \<subseteq> supp N"
  and     "length xvec = length Tvec"
  and     Qeq\<Psi>: "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"

  shows "\<Psi> : Q \<rhd> M\<lparr>\<lambda>*xvec N\<rparr>.P \<Longrightarrow>K\<lparr>(N[xvec::=Tvec])\<rparr> \<prec> P[xvec::=Tvec]"
proof -
  have "\<Psi> \<rhd>  M\<lparr>\<lambda>*xvec N\<rparr>.P \<Longrightarrow>\<^sup>^\<^sub>\<tau> M\<lparr>\<lambda>*xvec N\<rparr>.P" by simp
  moreover from Qeq\<Psi> have "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(M\<lparr>\<lambda>*xvec N\<rparr>.P)) \<Psi>"
    by auto
  moreover from assms have "\<Psi> \<rhd> M\<lparr>\<lambda>*xvec N\<rparr>.P \<longmapsto>K\<lparr>(N[xvec::=Tvec])\<rparr> \<prec> P[xvec::=Tvec]"
    by(rule_tac Input)
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakOutput:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   K    :: 'a
  and   N    :: 'a
  and   P    :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<turnstile> M \<leftrightarrow> K"
  and     Qeq\<Psi>: "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"

  shows "\<Psi> : Q \<rhd> M\<langle>N\<rangle>.P \<Longrightarrow>K\<langle>N\<rangle> \<prec> P"
proof -
  have "\<Psi> \<rhd>  M\<langle>N\<rangle>.P \<Longrightarrow>\<^sup>^\<^sub>\<tau> M\<langle>N\<rangle>.P" by simp
  moreover from Qeq\<Psi> have "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(M\<langle>N\<rangle>.P)) \<Psi>"
    by auto
  moreover have "insertAssertion (extractFrame(M\<langle>N\<rangle>.P)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(M\<langle>N\<rangle>.P)) \<Psi>" by simp
  moreover from `\<Psi> \<turnstile> M \<leftrightarrow> K` have "\<Psi> \<rhd> M\<langle>N\<rangle>.P \<longmapsto>K\<langle>N\<rangle> \<prec> P"
    by(rule Output)
  ultimately show ?thesis by(rule_tac weakTransitionI) auto
qed

lemma insertGuardedAssertion:
  fixes P :: "('a, 'b, 'c) psi"

  assumes "guarded P"

  shows "insertAssertion(extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"
proof -
  obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>" by(rule freshFrame)
  from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" and "supp \<Psi>\<^isub>P = ({}::name set)"
    by(blast dest: guardedStatEq)+
  
  from FrP `A\<^isub>P \<sharp>* \<Psi>` `\<Psi>\<^isub>P \<simeq> \<one>` have "insertAssertion(extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>A\<^isub>P, \<Psi> \<otimes> \<one>\<rangle>"
    by simp (metis frameIntCompositionSym)
  moreover from `A\<^isub>P \<sharp>* \<Psi>` have "\<langle>A\<^isub>P, \<Psi> \<otimes> \<one>\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"
    by(rule_tac frameResFreshChain) auto
  ultimately show ?thesis by(rule FrameStatEqTrans)
qed
  
lemma weakCase:
  fixes \<Psi>   :: 'b 
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   R    :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "(\<phi>, P) mem CsP"
  and     "\<Psi> \<turnstile> \<phi>"
  and     "guarded P"
  and     RImpQ: "insertAssertion (extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame Q) \<Psi>"
  and     ImpR: "insertAssertion (extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>"

  shows "\<Psi> : R \<rhd> Cases CsP \<Longrightarrow>\<alpha> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)
  show ?thesis
  proof(case_tac "P = P''")
    assume "P = P''"
    have "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sup>^\<^sub>\<tau> Cases CsP" by simp
    moreover from ImpR AssertionStatEq_def have "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame(Cases CsP)) \<Psi>"
      by(rule_tac FrameStatImpTrans) (auto intro: Identity)+

    moreover from P''Trans `(\<phi>, P) mem CsP` `\<Psi> \<turnstile> \<phi>` `guarded P` `P = P''` have "\<Psi> \<rhd> Cases CsP \<longmapsto>\<alpha> \<prec> P'"
      by(blast intro: Case)
    ultimately show ?thesis
      by(rule weakTransitionI)
  next
    assume "P \<noteq> P''"
    with PChain have "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P''" by(simp add: rtrancl_eq_or_trancl)
    hence "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sub>\<tau> P''" using `(\<phi>, P) mem CsP` `\<Psi> \<turnstile> \<phi>` `guarded P` 
      by(rule tauStepChainCase)
    hence "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" by simp
    moreover from RImpQ QeqP'' have "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P'') \<Psi>"
      by(rule FrameStatImpTrans)
    ultimately show ?thesis using P''Trans by(rule weakTransitionI)
  qed
qed

lemma weakOpen:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   yvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*(xvec@yvec)\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     "x \<in> supp N"
  and     "x \<sharp> \<Psi>"
  and     "x \<sharp> M"
  and     "x \<sharp> xvec"
  and     "x \<sharp> yvec"

  shows "\<Psi> : \<lparr>\<nu>x\<rparr>Q \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>M\<lparr>\<nu>*(xvec@x#yvec)\<rparr>\<langle>N\<rangle> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*(xvec@yvec)\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `x \<sharp> \<Psi>` have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>x\<rparr>P''" by(rule tauChainResPres)
  moreover from QeqP'' `x \<sharp> \<Psi>` have "insertAssertion (extractFrame(\<lparr>\<nu>x\<rparr>Q)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(\<lparr>\<nu>x\<rparr>P'')) \<Psi>" by(force intro: frameImpResPres)
  moreover from P''Trans `x \<in> supp N` `x \<sharp> \<Psi>` `x \<sharp> M` `x \<sharp> xvec` `x \<sharp> yvec` have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P'' \<longmapsto>M\<lparr>\<nu>*(xvec@x#yvec)\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule Open)
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakScope:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "x \<sharp> \<Psi>"
  and     "x \<sharp> \<alpha>"

  shows "\<Psi> : \<lparr>\<nu>x\<rparr>Q \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<alpha> \<prec> \<lparr>\<nu>x\<rparr>P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `x \<sharp> \<Psi>` have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>x\<rparr>P''" by(rule tauChainResPres)
  moreover from QeqP'' `x \<sharp> \<Psi>` have "insertAssertion (extractFrame(\<lparr>\<nu>x\<rparr>Q)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(\<lparr>\<nu>x\<rparr>P'')) \<Psi>" by(force intro: frameImpResPres)
  moreover from P''Trans `x \<sharp> \<Psi>` `x \<sharp> \<alpha>` have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P'' \<longmapsto>\<alpha> \<prec> \<lparr>\<nu>x\<rparr>P'"
    by(rule Scope)
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakPar1:
  fixes \<Psi>   :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   A\<^isub>Q   :: "name list"
  and   \<Psi>\<^isub>Q   :: 'b

  assumes PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q : R \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>"
  and     "bn \<alpha> \<sharp>* Q"
  and     "A\<^isub>Q \<sharp>* \<Psi>"
  and     "A\<^isub>Q \<sharp>* P"
  and     "A\<^isub>Q \<sharp>* \<alpha>"
  and     "A\<^isub>Q \<sharp>* R"

  shows "\<Psi> : R \<parallel> Q \<rhd> P \<parallel> Q \<Longrightarrow>\<alpha> \<prec> P' \<parallel> Q"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and ReqP'': "insertAssertion (extractFrame R) (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') (\<Psi> \<otimes> \<Psi>\<^isub>Q)"
                           and P''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `A\<^isub>Q \<sharp>* P` have "A\<^isub>Q \<sharp>* P''" by(rule tauChainFreshChain)
  from PChain FrQ `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<parallel> Q" by(rule tauChainPar1)
  moreover have "insertAssertion (extractFrame(R \<parallel> Q)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(P'' \<parallel> Q)) \<Psi>"
  proof -
    obtain A\<^isub>R \<Psi>\<^isub>R where FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* A\<^isub>Q" and "A\<^isub>R \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>R \<sharp>* \<Psi>"
      by(rule_tac C="(A\<^isub>Q, \<Psi>\<^isub>Q, \<Psi>)" in freshFrame) auto
    obtain A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "A\<^isub>P'' \<sharp>* A\<^isub>Q" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P'' \<sharp>* \<Psi>"
      by(rule_tac C="(A\<^isub>Q, \<Psi>\<^isub>Q, \<Psi>)" in freshFrame) auto

    from FrR FrP'' `A\<^isub>Q \<sharp>* R` `A\<^isub>Q \<sharp>* P''` `A\<^isub>R \<sharp>* A\<^isub>Q` `A\<^isub>P'' \<sharp>* A\<^isub>Q` have "A\<^isub>Q \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>Q \<sharp>* \<Psi>\<^isub>P''"
      by(force dest: extractFrameFreshChain)+
    have "\<langle>A\<^isub>R, \<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle>"
      by(metis frameNilStatEq frameResChainPres Associativity Commutativity Composition AssertionStatEqTrans)
    moreover from ReqP'' FrR FrP'' `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q`
    have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle>" using freshCompChain by auto
    moreover have "\<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P'', \<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<Psi>\<^isub>Q\<rangle>"
      by(metis frameNilStatEq frameResChainPres Associativity Commutativity Composition AssertionStatEqTrans)
    ultimately have "\<langle>A\<^isub>R, \<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', \<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<Psi>\<^isub>Q\<rangle>"
      by(force dest: FrameStatImpTrans simp add: FrameStatEq_def)

    hence "\<langle>(A\<^isub>R@A\<^isub>Q), \<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>(A\<^isub>P''@A\<^isub>Q), \<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<Psi>\<^isub>Q\<rangle>"
      apply(simp add: frameChainAppend)
      apply(drule_tac xvec=A\<^isub>Q in frameImpResChainPres)
      by(metis frameImpChainComm FrameStatImpTrans)
    with FrR FrQ FrP'' `A\<^isub>R \<sharp>* A\<^isub>Q` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>R` `A\<^isub>P'' \<sharp>* A\<^isub>Q` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>P''` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* \<Psi>` ReqP''
    show ?thesis by simp
  qed
  moreover from P''Trans FrQ `bn \<alpha> \<sharp>* Q` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* P''` `A\<^isub>Q \<sharp>* \<alpha>` have "\<Psi> \<rhd> P'' \<parallel> Q \<longmapsto>\<alpha> \<prec> (P' \<parallel> Q)"
    by(rule Par1)  
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakPar2:
  fixes \<Psi>   :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   Q'   :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   A\<^isub>P   :: "name list"
  and   \<Psi>\<^isub>P  :: 'b

  assumes QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>P : R \<rhd> Q \<Longrightarrow>\<alpha> \<prec> Q'"
  and     FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
  and     "bn \<alpha> \<sharp>* P"
  and     "A\<^isub>P \<sharp>* \<Psi>"
  and     "A\<^isub>P \<sharp>* Q"
  and     "A\<^isub>P \<sharp>* \<alpha>"
  and     "A\<^isub>P \<sharp>* R"

  shows "\<Psi> : P \<parallel> R \<rhd> P \<parallel> Q \<Longrightarrow>\<alpha> \<prec> P \<parallel> Q'"
proof -
  from QTrans obtain Q'' where QChain: "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q''"
                           and ReqQ'': "insertAssertion (extractFrame R) (\<Psi> \<otimes> \<Psi>\<^isub>P) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame Q'') (\<Psi> \<otimes> \<Psi>\<^isub>P)"
                           and Q''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> Q'' \<longmapsto>\<alpha> \<prec> Q'"
    by(rule weakTransitionE)

  from QChain `A\<^isub>P \<sharp>* Q` have "A\<^isub>P \<sharp>* Q''" by(rule tauChainFreshChain)

  from QChain FrP `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* Q` have "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P \<parallel> Q''" by(rule tauChainPar2)
  moreover have "insertAssertion (extractFrame(P \<parallel> R)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame(P \<parallel> Q'')) \<Psi>"
  proof -
    obtain A\<^isub>R \<Psi>\<^isub>R where FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* A\<^isub>P" and "A\<^isub>R \<sharp>* \<Psi>\<^isub>P" and "A\<^isub>R \<sharp>* \<Psi>"
      by(rule_tac C="(A\<^isub>P, \<Psi>\<^isub>P, \<Psi>)" in freshFrame) auto
    obtain A\<^isub>Q'' \<Psi>\<^isub>Q'' where FrQ'': "extractFrame Q'' = \<langle>A\<^isub>Q'', \<Psi>\<^isub>Q''\<rangle>" and "A\<^isub>Q'' \<sharp>* A\<^isub>P" and "A\<^isub>Q'' \<sharp>* \<Psi>\<^isub>P" and "A\<^isub>Q'' \<sharp>* \<Psi>"
      by(rule_tac C="(A\<^isub>P, \<Psi>\<^isub>P, \<Psi>)" in freshFrame) auto

    from FrR FrQ'' `A\<^isub>P \<sharp>* R` `A\<^isub>P \<sharp>* Q''` `A\<^isub>R \<sharp>* A\<^isub>P` `A\<^isub>Q'' \<sharp>* A\<^isub>P` have "A\<^isub>P \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>P \<sharp>* \<Psi>\<^isub>Q''"
      by(force dest: extractFrameFreshChain)+
    have "\<langle>A\<^isub>R, \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>R\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<Psi>\<^isub>R\<rangle>"
      by(metis frameNilStatEq frameResChainPres Associativity Commutativity Composition AssertionStatEqTrans)

    moreover from ReqQ'' FrR FrQ'' `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>\<^isub>P` `A\<^isub>Q'' \<sharp>* \<Psi>` `A\<^isub>Q'' \<sharp>* \<Psi>\<^isub>P`
    have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>Q'', (\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<Psi>\<^isub>Q''\<rangle>" using freshCompChain by simp
    moreover have "\<langle>A\<^isub>Q'', (\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<Psi>\<^isub>Q''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q'', \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>Q''\<rangle>"
      by(metis frameNilStatEq frameResChainPres Associativity Commutativity Composition AssertionStatEqTrans)
    ultimately have "\<langle>A\<^isub>R, \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>Q'', \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>Q''\<rangle>"
      by(force dest: FrameStatImpTrans simp add: FrameStatEq_def)
    hence "\<langle>(A\<^isub>P@A\<^isub>R), \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>(A\<^isub>P@A\<^isub>Q''), \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>Q''\<rangle>"
      apply(simp add: frameChainAppend)
      apply(drule_tac xvec=A\<^isub>P in frameImpResChainPres)
      by(metis frameImpChainComm FrameStatImpTrans)
    with FrR FrP FrQ'' `A\<^isub>R \<sharp>* A\<^isub>P` `A\<^isub>R \<sharp>* \<Psi>\<^isub>P` `A\<^isub>P \<sharp>* \<Psi>\<^isub>R` `A\<^isub>Q'' \<sharp>* A\<^isub>P` `A\<^isub>Q'' \<sharp>* \<Psi>\<^isub>P` `A\<^isub>P \<sharp>* \<Psi>\<^isub>Q''` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>Q'' \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* \<Psi>` ReqQ''
    show ?thesis by simp
  qed
  moreover from Q''Trans FrP `bn \<alpha> \<sharp>* P` `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* Q''` `A\<^isub>P \<sharp>* \<alpha>` have "\<Psi> \<rhd> P \<parallel> Q'' \<longmapsto>\<alpha> \<prec> (P \<parallel> Q')"
    by(rule_tac Par2) auto
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma weakComm1:
  fixes \<Psi>   :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   A\<^isub>Q   :: "name list"
  and   \<Psi>\<^isub>Q   :: 'b

  assumes PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q : R \<rhd> P \<Longrightarrow>M\<lparr>N\<rparr> \<prec> P'"
  and     FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
  and     QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q'"
  and     FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>"
  and     MeqK: "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K"
  and     "A\<^isub>R \<sharp>* \<Psi>"
  and     "A\<^isub>R \<sharp>* P"
  and     "A\<^isub>R \<sharp>* Q"
  and     "A\<^isub>R \<sharp>* R"
  and     "A\<^isub>R \<sharp>* M"
  and     "A\<^isub>R \<sharp>* A\<^isub>Q"
  and     "A\<^isub>Q \<sharp>* \<Psi>"
  and     "A\<^isub>Q \<sharp>* P"
  and     "A\<^isub>Q \<sharp>* Q"
  and     "A\<^isub>Q \<sharp>* R"
  and     "A\<^isub>Q \<sharp>* K"
  and     "xvec \<sharp>* P"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sub>\<tau> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q'))"
proof -
  from `extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* P` `A\<^isub>Q \<sharp>* Q` `A\<^isub>Q \<sharp>* R` `A\<^isub>Q \<sharp>* K` `A\<^isub>R \<sharp>* A\<^isub>Q`
  obtain A\<^isub>Q' where FrQ': "extractFrame Q = \<langle>A\<^isub>Q', \<Psi>\<^isub>Q\<rangle>" and "distinct A\<^isub>Q'" and "A\<^isub>Q' \<sharp>* \<Psi>" and "A\<^isub>Q' \<sharp>* P" 
               and "A\<^isub>Q' \<sharp>* Q" and "A\<^isub>Q' \<sharp>* R" and "A\<^isub>Q' \<sharp>* K" and "A\<^isub>R \<sharp>* A\<^isub>Q'"
    by(rule_tac C="(\<Psi>, P, Q, R, K, A\<^isub>R)" in distinctFrame) auto

  from PTrans obtain P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and RimpP'': "insertAssertion (extractFrame R) (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') (\<Psi> \<otimes> \<Psi>\<^isub>Q)"
                           and P''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P'' \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `A\<^isub>Q' \<sharp>* P` have "A\<^isub>Q' \<sharp>* P''" by(rule tauChainFreshChain)
  obtain A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "A\<^isub>P'' \<sharp>* (\<Psi>, A\<^isub>Q', \<Psi>\<^isub>Q, A\<^isub>R, \<Psi>\<^isub>R, M, N, K, R, Q, P'', xvec)" and "distinct A\<^isub>P''"
    by(rule freshFrame)
  hence "A\<^isub>P'' \<sharp>* \<Psi>" and "A\<^isub>P'' \<sharp>* A\<^isub>Q'" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P'' \<sharp>* M" and "A\<^isub>P'' \<sharp>* R" and "A\<^isub>P'' \<sharp>* Q"
    and "A\<^isub>P'' \<sharp>* N" and "A\<^isub>P'' \<sharp>* K" and "A\<^isub>P'' \<sharp>* A\<^isub>R" and "A\<^isub>P'' \<sharp>* P''" and "A\<^isub>P'' \<sharp>* xvec" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R"
    by simp+
  from FrR `A\<^isub>R \<sharp>* A\<^isub>Q'` `A\<^isub>Q' \<sharp>* R` have "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R" by(drule_tac extractFrameFreshChain) auto
  from FrQ' `A\<^isub>R \<sharp>* A\<^isub>Q'` `A\<^isub>R \<sharp>* Q` have "A\<^isub>R \<sharp>* \<Psi>\<^isub>Q" by(drule_tac extractFrameFreshChain) auto
  from PChain `xvec \<sharp>* P` have "xvec \<sharp>* P''" by(force intro: tauChainFreshChain)+

  have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle>" 
    by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
  moreover with RimpP'' FrP'' FrR `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q`
  have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle>" using freshCompChain
    by(simp add: freshChainSimps)
  moreover have "\<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'') \<otimes> \<Psi>\<^isub>Q\<rangle>"
    by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
  ultimately have RImpP'': "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'') \<otimes> \<Psi>\<^isub>Q\<rangle>"
    by(rule FrameStatEqImpCompose)
      
  from PChain FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<parallel> Q" by(rule tauChainPar1)
  moreover from QTrans FrR P''Trans MeqK RImpP'' FrP'' FrQ' `distinct A\<^isub>P''` `distinct A\<^isub>Q'` `A\<^isub>P'' \<sharp>* A\<^isub>Q'` `A\<^isub>R \<sharp>* A\<^isub>Q'`
        `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P''` `A\<^isub>Q' \<sharp>* Q` `A\<^isub>Q' \<sharp>* R` `A\<^isub>Q' \<sharp>* K` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R` `A\<^isub>P'' \<sharp>* Q`
        `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* M` `A\<^isub>Q \<sharp>* R` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* M`
  obtain K' where "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<rhd> Q \<longmapsto>K'\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q'" and "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K'" and "A\<^isub>Q' \<sharp>* K'"
    by(rule_tac comm1Aux) (assumption | simp)+
  with P''Trans FrP'' have "\<Psi> \<rhd> P'' \<parallel> Q \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q')" using FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P''` `A\<^isub>Q' \<sharp>* Q`
    `xvec \<sharp>* P''` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* Q` `A\<^isub>P'' \<sharp>* M`  `A\<^isub>P'' \<sharp>* A\<^isub>Q'`
    by(rule_tac Comm1)
  ultimately show ?thesis
    by(drule_tac tauActTauStepChain) auto
qed

lemma weakComm2:
  fixes \<Psi>   :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   A\<^isub>Q   :: "name list"
  and   \<Psi>\<^isub>Q   :: 'b

  assumes PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q : R \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
  and     QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>K\<lparr>N\<rparr> \<prec> Q'"
  and     FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>"
  and     MeqK: "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K"
  and     "A\<^isub>R \<sharp>* \<Psi>"
  and     "A\<^isub>R \<sharp>* P"
  and     "A\<^isub>R \<sharp>* Q"
  and     "A\<^isub>R \<sharp>* R"
  and     "A\<^isub>R \<sharp>* M"
  and     "A\<^isub>R \<sharp>* A\<^isub>Q"
  and     "A\<^isub>Q \<sharp>* \<Psi>"
  and     "A\<^isub>Q \<sharp>* P"
  and     "A\<^isub>Q \<sharp>* Q"
  and     "A\<^isub>Q \<sharp>* R"
  and     "A\<^isub>Q \<sharp>* K"
  and     "xvec \<sharp>* Q"
  and     "xvec \<sharp>* M"
  and     "xvec \<sharp>* A\<^isub>Q"
  and     "xvec \<sharp>* A\<^isub>R"

  shows "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sub>\<tau> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q'))"
proof -
  from `extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* P` `A\<^isub>Q \<sharp>* Q` `A\<^isub>Q \<sharp>* R` `A\<^isub>Q \<sharp>* K` `A\<^isub>R \<sharp>* A\<^isub>Q` `xvec \<sharp>* A\<^isub>Q`
  obtain A\<^isub>Q' where FrQ': "extractFrame Q = \<langle>A\<^isub>Q', \<Psi>\<^isub>Q\<rangle>" and "distinct A\<^isub>Q'" and "A\<^isub>Q' \<sharp>* \<Psi>" and "A\<^isub>Q' \<sharp>* P" 
               and "A\<^isub>Q' \<sharp>* Q" and "A\<^isub>Q' \<sharp>* R" and "A\<^isub>Q' \<sharp>* K" and "A\<^isub>R \<sharp>* A\<^isub>Q'" and "A\<^isub>Q' \<sharp>* xvec"
    by(rule_tac C="(\<Psi>, P, Q, R, K, A\<^isub>R, xvec)" in distinctFrame) auto

  from PTrans obtain P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and RimpP'': "insertAssertion (extractFrame R) (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') (\<Psi> \<otimes> \<Psi>\<^isub>Q)"
                           and P''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> P'' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `A\<^isub>Q' \<sharp>* P` have "A\<^isub>Q' \<sharp>* P''" by(rule tauChainFreshChain)
  obtain A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "A\<^isub>P'' \<sharp>* (\<Psi>, A\<^isub>Q', \<Psi>\<^isub>Q, A\<^isub>R, \<Psi>\<^isub>R, M, N, K, R, Q, P'', xvec)" and "distinct A\<^isub>P''"
    by(rule freshFrame)
  hence "A\<^isub>P'' \<sharp>* \<Psi>" and "A\<^isub>P'' \<sharp>* A\<^isub>Q'" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P'' \<sharp>* M" and "A\<^isub>P'' \<sharp>* R" and "A\<^isub>P'' \<sharp>* Q"
    and "A\<^isub>P'' \<sharp>* N" and "A\<^isub>P'' \<sharp>* K" and "A\<^isub>P'' \<sharp>* A\<^isub>R" and "A\<^isub>P'' \<sharp>* P''" and "A\<^isub>P'' \<sharp>* xvec" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R"
    by simp+
  from FrR `A\<^isub>R \<sharp>* A\<^isub>Q'` `A\<^isub>Q' \<sharp>* R` have "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R" by(drule_tac extractFrameFreshChain) auto
  from FrQ' `A\<^isub>R \<sharp>* A\<^isub>Q'` `A\<^isub>R \<sharp>* Q` have "A\<^isub>R \<sharp>* \<Psi>\<^isub>Q" by(drule_tac extractFrameFreshChain) auto

  have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle>" 
    by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
  moreover with RimpP'' FrP'' FrR `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q`
  have "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle>" using freshCompChain
    by(simp add: freshChainSimps)
  moreover have "\<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>P''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'') \<otimes> \<Psi>\<^isub>Q\<rangle>"
    by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
  ultimately have RImpP'': "\<langle>A\<^isub>R, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'') \<otimes> \<Psi>\<^isub>Q\<rangle>"
    by(rule FrameStatEqImpCompose)
      
  from PChain FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> Q \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<parallel> Q" by(rule tauChainPar1)
  moreover from QTrans FrR P''Trans MeqK RImpP'' FrP'' FrQ' `distinct A\<^isub>P''` `distinct A\<^isub>Q'` `A\<^isub>P'' \<sharp>* A\<^isub>Q'` `A\<^isub>R \<sharp>* A\<^isub>Q'`
        `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P''` `A\<^isub>Q' \<sharp>* Q` `A\<^isub>Q' \<sharp>* R` `A\<^isub>Q' \<sharp>* K` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R` `A\<^isub>P'' \<sharp>* Q`
        `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* M` `A\<^isub>Q \<sharp>* R` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* M` `xvec \<sharp>* A\<^isub>R` `xvec \<sharp>* M` `A\<^isub>Q' \<sharp>* xvec`
  obtain K' where "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<rhd> Q \<longmapsto>K'\<lparr>N\<rparr> \<prec> Q'" and "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K'" and "A\<^isub>Q' \<sharp>* K'"
    by(rule_tac comm2Aux) (assumption | simp)+
  with P''Trans FrP'' have "\<Psi> \<rhd> P'' \<parallel> Q \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q')" using FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* P''` `A\<^isub>Q' \<sharp>* Q`
    `xvec \<sharp>* Q` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* Q` `A\<^isub>P'' \<sharp>* M`  `A\<^isub>P'' \<sharp>* A\<^isub>Q'`
    by(rule_tac Comm2)
  ultimately show ?thesis
    by(drule_tac tauActTauStepChain) auto
qed

lemma frameImpIntComposition:
  fixes \<Psi>  :: 'b
  and   \<Psi>' :: 'b
  and   A\<^isub>F :: "name list"
  and   \<Psi>\<^isub>F :: 'b

  assumes "\<Psi> \<simeq> \<Psi>'"

  shows "\<langle>A\<^isub>F, \<Psi> \<otimes> \<Psi>\<^isub>F\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle>"
proof -
  from assms have "\<langle>A\<^isub>F, \<Psi> \<otimes> \<Psi>\<^isub>F\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle>" by(rule frameIntComposition)
  thus ?thesis by(simp add: FrameStatEq_def)
qed

lemma insertAssertionStatImp:
  fixes F  :: "'b frame"
  and   \<Psi>  :: 'b
  and   G  :: "'b frame"
  and   \<Psi>' :: 'b

  assumes FeqG: "insertAssertion F \<Psi> \<hookrightarrow>\<^sub>F insertAssertion G \<Psi>"
  and     "\<Psi> \<simeq> \<Psi>'"

  shows "insertAssertion F \<Psi>' \<hookrightarrow>\<^sub>F insertAssertion G \<Psi>'"
proof -
  obtain A\<^isub>F \<Psi>\<^isub>F where FrF: "F = \<langle>A\<^isub>F, \<Psi>\<^isub>F\<rangle>" and "A\<^isub>F \<sharp>* \<Psi>" and "A\<^isub>F \<sharp>* \<Psi>'"
    by(rule_tac C="(\<Psi>, \<Psi>')" in freshFrame) auto
  obtain A\<^isub>G \<Psi>\<^isub>G where FrG: "G = \<langle>A\<^isub>G, \<Psi>\<^isub>G\<rangle>" and "A\<^isub>G \<sharp>* \<Psi>" and "A\<^isub>G \<sharp>* \<Psi>'"
    by(rule_tac C="(\<Psi>, \<Psi>')" in freshFrame) auto

  from `\<Psi> \<simeq> \<Psi>'` have "\<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>F, \<Psi> \<otimes> \<Psi>\<^isub>F\<rangle>" by (metis frameIntComposition FrameStatEqSym)
  moreover from `\<Psi> \<simeq> \<Psi>'` have "\<langle>A\<^isub>G, \<Psi> \<otimes> \<Psi>\<^isub>G\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>G, \<Psi>' \<otimes> \<Psi>\<^isub>G\<rangle>" by(rule frameIntComposition)
  ultimately have "\<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>G, \<Psi>' \<otimes> \<Psi>\<^isub>G\<rangle>" using FeqG FrF FrG `A\<^isub>F \<sharp>* \<Psi>` `A\<^isub>G \<sharp>* \<Psi>` `\<Psi> \<simeq> \<Psi>'`
    by(force simp add: FrameStatEq_def dest: FrameStatImpTrans)
  with FrF FrG `A\<^isub>F \<sharp>* \<Psi>'` `A\<^isub>G \<sharp>* \<Psi>'` show ?thesis by simp
qed

lemma insertAssertionStatEq:
  fixes F  :: "'b frame"
  and   \<Psi>  :: 'b
  and   G  :: "'b frame"
  and   \<Psi>' :: 'b

  assumes FeqG: "insertAssertion F \<Psi> \<simeq>\<^sub>F insertAssertion G \<Psi>"
  and     "\<Psi> \<simeq> \<Psi>'"

  shows "insertAssertion F \<Psi>' \<simeq>\<^sub>F insertAssertion G \<Psi>'"
proof -
  obtain A\<^isub>F \<Psi>\<^isub>F where FrF: "F = \<langle>A\<^isub>F, \<Psi>\<^isub>F\<rangle>" and "A\<^isub>F \<sharp>* \<Psi>" and "A\<^isub>F \<sharp>* \<Psi>'"
    by(rule_tac C="(\<Psi>, \<Psi>')" in freshFrame) auto
  obtain A\<^isub>G \<Psi>\<^isub>G where FrG: "G = \<langle>A\<^isub>G, \<Psi>\<^isub>G\<rangle>" and "A\<^isub>G \<sharp>* \<Psi>" and "A\<^isub>G \<sharp>* \<Psi>'"
    by(rule_tac C="(\<Psi>, \<Psi>')" in freshFrame) auto

  from FeqG FrF FrG `A\<^isub>F \<sharp>* \<Psi>` `A\<^isub>G \<sharp>* \<Psi>` `\<Psi> \<simeq> \<Psi>'`
  have "\<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>G, \<Psi>' \<otimes> \<Psi>\<^isub>G\<rangle>"
    by simp (metis frameIntComposition FrameStatEqTrans FrameStatEqSym)
  with FrF FrG `A\<^isub>F \<sharp>* \<Psi>'` `A\<^isub>G \<sharp>* \<Psi>'` show ?thesis by simp
qed

lemma weakTransitionStatEq:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   \<Psi>'  :: 'b

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "\<Psi> \<simeq> \<Psi>'"

  shows "\<Psi>' : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and QeqP'': "insertAssertion (extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)

  from PChain `\<Psi> \<simeq> \<Psi>'` have "\<Psi>' \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" by(rule tauChainStatEq)
  moreover from QeqP'' `\<Psi> \<simeq> \<Psi>'` have "insertAssertion (extractFrame Q) \<Psi>' \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') \<Psi>'"
    by(rule insertAssertionStatImp)
  moreover from P''Trans `\<Psi> \<simeq> \<Psi>'` have "\<Psi>' \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule statEqTransition)
  ultimately show ?thesis by(rule weakTransitionI)
qed

lemma transitionWeakTransition:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> P'"
  and     "insertAssertion(extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P) \<Psi>"

  shows "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
using assms
by(fastsimp intro: weakTransitionI)

lemma weakPar1Guarded:
  fixes \<Psi>  :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : R \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "bn \<alpha> \<sharp>* Q"
  and     "guarded Q"

  shows "\<Psi> : (R \<parallel> Q) \<rhd> P \<parallel> Q \<Longrightarrow>\<alpha> \<prec> P' \<parallel> Q"
proof -
  obtain A\<^isub>Q \<Psi>\<^isub>Q where FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" and "A\<^isub>Q \<sharp>* \<Psi>" and "A\<^isub>Q \<sharp>* P" and "A\<^isub>Q \<sharp>* \<alpha>" and "A\<^isub>Q \<sharp>* R"
    by(rule_tac C="(\<Psi>, P, \<alpha>, R)" in freshFrame) auto
  from `guarded Q` FrQ have "\<Psi>\<^isub>Q \<simeq> \<one>" by(blast dest: guardedStatEq)
  with PTrans have "\<Psi> \<otimes> \<Psi>\<^isub>Q : R \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'" by(metis weakTransitionStatEq Identity AssertionStatEqSym compositionSym)
  thus ?thesis using FrQ `bn \<alpha> \<sharp>* Q` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* P` `A\<^isub>Q \<sharp>* \<alpha>` `A\<^isub>Q \<sharp>* R` 
    by(rule weakPar1)
qed

lemma weakBang:
  fixes \<Psi>   :: 'b
  and   R    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : R \<rhd> P \<parallel> !P \<Longrightarrow>\<alpha> \<prec> P'"
  and     "guarded P"

  shows "\<Psi> : R \<rhd> !P \<Longrightarrow>\<alpha> \<prec> P'"
proof -
  from PTrans obtain P'' where PChain: "\<Psi> \<rhd> P \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                           and RImpP'': "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P'') \<Psi>"
                           and P''Trans: "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    by(rule weakTransitionE)
  moreover obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>" by(rule freshFrame)
  moreover from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" by(blast dest: guardedStatEq)
  ultimately show ?thesis
  proof(auto simp add: rtrancl_eq_or_trancl)
    have "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> !P" by simp
    moreover assume RimpP: "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P, \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<one>\<rangle>"
    have "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame(!P)) \<Psi>"
    proof -
      from `\<Psi>\<^isub>P \<simeq> \<one>` have "\<langle>A\<^isub>P, \<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<one>\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P, \<Psi> \<otimes> \<one>\<rangle>"
	by(metis frameIntCompositionSym frameIntAssociativity frameIntCommutativity frameIntIdentity FrameStatEqTrans FrameStatEqSym)
      moreover from `A\<^isub>P \<sharp>* \<Psi>` have "\<langle>A\<^isub>P, \<Psi> \<otimes> \<one>\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"
	by(force intro: frameResFreshChain)
      ultimately show ?thesis using RimpP by(auto simp add: FrameStatEq_def dest: FrameStatImpTrans)
    qed
    moreover assume "\<Psi> \<rhd> P \<parallel> !P \<longmapsto>\<alpha> \<prec> P'"
    hence "\<Psi> \<rhd> !P \<longmapsto>\<alpha> \<prec> P'" using `guarded P` by(rule Bang)
   ultimately show ?thesis by(rule weakTransitionI)
  next
    fix P'''
    assume "\<Psi> \<rhd> P \<parallel> !P \<Longrightarrow>\<^sub>\<tau>  P''"
    hence "\<Psi> \<rhd> !P \<Longrightarrow>\<^sub>\<tau> P''" using `guarded P` by(rule tauStepChainBang)
    hence "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" by simp
    moreover assume "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P'') \<Psi>"
                and "\<Psi> \<rhd> P'' \<longmapsto>\<alpha> \<prec> P'"
    ultimately show ?thesis by(rule weakTransitionI)
  qed
qed

lemma weakTransitionFrameImp:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  and   R    :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and             "insertAssertion(extractFrame R) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame Q) \<Psi>"

  shows "\<Psi> : R \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
using assms
by(auto simp add: weakTransition_def intro: FrameStatImpTrans)

lemma guardedFrameStatEq:
  fixes P :: "('a, 'b, 'c) psi"

  assumes "guarded P"

  shows "extractFrame P \<simeq>\<^sub>F \<langle>\<epsilon>, \<one>\<rangle>"
proof -
  obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" by(rule freshFrame)
  from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" by(blast dest: guardedStatEq)
  hence "\<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P, \<one>\<rangle>" by(rule_tac frameResChainPres) auto
  moreover have "\<langle>A\<^isub>P, \<one>\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<one>\<rangle>" by(rule_tac frameResFreshChain) auto
  ultimately show ?thesis using FrP by(force intro: FrameStatEqTrans)
qed

lemma weakGuardedTransition:
  fixes \<Psi>   :: 'b
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<alpha>    :: "'a action"
  and   P'   :: "('a, 'b, 'c) psi"
  and   R    :: "('a, 'b, 'c) psi"

  assumes PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
  and    "guarded Q"

  shows "\<Psi> : \<zero> \<rhd> P \<Longrightarrow>\<alpha> \<prec> P'"
proof -
  obtain A\<^isub>Q \<Psi>\<^isub>Q where FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" and "A\<^isub>Q \<sharp>* \<Psi>" by(rule freshFrame)
  moreover from `guarded Q` FrQ have "\<Psi>\<^isub>Q \<simeq> \<one>" by(blast dest: guardedStatEq)
  hence "\<langle>A\<^isub>Q, \<Psi> \<otimes> \<Psi>\<^isub>Q\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q, \<Psi> \<otimes> \<one>\<rangle>" by(metis frameIntCompositionSym)
  moreover from `A\<^isub>Q \<sharp>* \<Psi>` have "\<langle>A\<^isub>Q, \<Psi> \<otimes> \<one>\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>" by(rule_tac frameResFreshChain) auto
  ultimately have "insertAssertion(extractFrame Q) \<Psi> \<simeq>\<^sub>F insertAssertion (extractFrame (\<zero>)) \<Psi>"
    using FrQ `A\<^isub>Q \<sharp>* \<Psi>` by simp (blast intro: FrameStatEqTrans)
  with PTrans show ?thesis by(rule_tac weakTransitionFrameImp) (auto simp add: FrameStatEq_def) 
qed

lemma expandTauChainFrame:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   A\<^isub>P :: "name list"
  and   \<Psi>\<^isub>P :: 'b
  and   C   :: "'d::fs_name"

  assumes PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
  and     "distinct A\<^isub>P"
  and     "A\<^isub>P \<sharp>* P"
  and     "A\<^isub>P \<sharp>* C"

  obtains \<Psi>' A\<^isub>P' \<Psi>\<^isub>P' where "extractFrame P' = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'" and "A\<^isub>P' \<sharp>* P'" and "A\<^isub>P' \<sharp>* C" and "distinct A\<^isub>P'"
using PChain FrP `A\<^isub>P \<sharp>* P`
proof(induct arbitrary: thesis rule: tauChainInduct)
  case(TauBase P)
  have "\<Psi>\<^isub>P \<otimes> SBottom' \<simeq> \<Psi>\<^isub>P" by(rule Identity)
  with `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>` show ?case using `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* C` `distinct A\<^isub>P` by(rule TauBase)
next
  case(TauStep P P' P'')
  from `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>` `A\<^isub>P \<sharp>* P`
  obtain \<Psi>' A\<^isub>P' \<Psi>\<^isub>P' where FrP': "extractFrame P' = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'"
                       and "A\<^isub>P' \<sharp>* P'" and "A\<^isub>P' \<sharp>* C" and "distinct A\<^isub>P'"
    by(rule_tac TauStep)
  from `\<Psi> \<rhd> P' \<longmapsto>\<tau> \<prec> P''` FrP' `distinct A\<^isub>P'` `A\<^isub>P' \<sharp>* P'` `A\<^isub>P' \<sharp>* C`
  obtain \<Psi>'' A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "\<Psi>\<^isub>P' \<otimes> \<Psi>'' \<simeq> \<Psi>\<^isub>P''"
                          and "A\<^isub>P'' \<sharp>* P''" and "A\<^isub>P'' \<sharp>* C" and "distinct A\<^isub>P''"
    by(rule expandTauFrame)
  from `\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'` have "(\<Psi>\<^isub>P \<otimes> \<Psi>') \<otimes> \<Psi>'' \<simeq> \<Psi>\<^isub>P' \<otimes> \<Psi>''" by(rule Composition)
  with `\<Psi>\<^isub>P' \<otimes> \<Psi>'' \<simeq> \<Psi>\<^isub>P''` have "\<Psi>\<^isub>P \<otimes> \<Psi>' \<otimes> \<Psi>'' \<simeq> \<Psi>\<^isub>P''"
    by(metis AssertionStatEqTrans Associativity Commutativity)
  with FrP'' show ?case using `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* C` `distinct A\<^isub>P''`
    by(rule TauStep)
qed

lemma frameIntImpComposition:
  fixes \<Psi>  :: 'b
  and   \<Psi>' :: 'b
  and   A\<^isub>F :: "name list"
  and   \<Psi>\<^isub>F :: 'b

  assumes "\<Psi> \<simeq> \<Psi>'"

  shows "\<langle>A\<^isub>F, \<Psi> \<otimes> \<Psi>\<^isub>F\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>F, \<Psi>' \<otimes> \<Psi>\<^isub>F\<rangle>"
using assms frameIntComposition
by(simp add: FrameStatEq_def)

lemma tauChainInduct2[consumes 1, case_names TauBase TauStep]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     cBase: "\<And>P. Prop P P"
  and     cStep: "\<And>P P' P''. \<lbrakk>\<Psi> \<rhd> P' \<longmapsto>\<tau> \<prec> P''; \<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'; Prop P P'\<rbrakk> \<Longrightarrow> Prop P P''"

  shows "Prop P P'"
using assms
by(rule tauChainInduct)

lemma tauStepChainInduct2[consumes 1, case_names TauBase TauStep]:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'"
  and     cBase: "\<And>P P'. \<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P' \<Longrightarrow> Prop P P'"
  and     cStep: "\<And>P P' P''. \<lbrakk>\<Psi> \<rhd> P' \<longmapsto>\<tau> \<prec> P''; \<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'; Prop P P'\<rbrakk> \<Longrightarrow> Prop P P''"

  shows "Prop P P'"
using assms
by(rule tauStepChainInduct)

lemma weakTransferTauChainFrame:
  fixes \<Psi>\<^isub>F :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  and   A\<^isub>P :: "name list"
  and   \<Psi>\<^isub>P :: 'b
  and   A\<^isub>F :: "name list"
  and   A\<^isub>G :: "name list"
  and   \<Psi>\<^isub>G :: 'b

  assumes PChain: "\<Psi>\<^isub>F \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
  and     "distinct A\<^isub>P"
  and     FeqG: "\<And>\<Psi>. insertAssertion (\<langle>A\<^isub>F, \<Psi>\<^isub>F \<otimes> \<Psi>\<^isub>P\<rangle>) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (\<langle>A\<^isub>G, \<Psi>\<^isub>G \<otimes> \<Psi>\<^isub>P\<rangle>) \<Psi>"
  and     "A\<^isub>F \<sharp>* \<Psi>\<^isub>G"
  and     "A\<^isub>G \<sharp>* \<Psi>"
  and     "A\<^isub>G \<sharp>* \<Psi>\<^isub>F"
  and     "A\<^isub>F \<sharp>* A\<^isub>G"
  and     "A\<^isub>F \<sharp>* P"
  and     "A\<^isub>G \<sharp>* P"
  and     "A\<^isub>P \<sharp>* A\<^isub>F"
  and     "A\<^isub>P \<sharp>* A\<^isub>G"
  and     "A\<^isub>P \<sharp>* \<Psi>\<^isub>F"
  and     "A\<^isub>P \<sharp>* \<Psi>\<^isub>G"
  and     "A\<^isub>P \<sharp>* P"

  shows "\<Psi>\<^isub>G \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
using PChain FrP `A\<^isub>F \<sharp>* P` `A\<^isub>G \<sharp>* P` `A\<^isub>P \<sharp>* P` 
proof(induct rule: tauChainInduct2)
  case TauBase
  thus ?case by simp
next
  case(TauStep P P' P'')
  have FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" by fact
  then have PChain: "\<Psi>\<^isub>G \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'" using `A\<^isub>F \<sharp>* P` `A\<^isub>G \<sharp>* P` `A\<^isub>P \<sharp>* P` by(rule TauStep)
  then obtain A\<^isub>P' \<Psi>\<^isub>P' \<Psi>' where FrP': "extractFrame P' = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'"
                            and "A\<^isub>P' \<sharp>* A\<^isub>F" and "A\<^isub>P' \<sharp>* A\<^isub>G" and "A\<^isub>P' \<sharp>* \<Psi>\<^isub>F" and "A\<^isub>P' \<sharp>* \<Psi>\<^isub>G"
                            and "distinct A\<^isub>P'"
                
    using FrP `distinct A\<^isub>P` `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* A\<^isub>F` `A\<^isub>P \<sharp>* A\<^isub>G` `A\<^isub>P \<sharp>* \<Psi>\<^isub>F` `A\<^isub>P \<sharp>* \<Psi>\<^isub>G`
    by(rule_tac C="(A\<^isub>F, A\<^isub>G, \<Psi>\<^isub>F, \<Psi>\<^isub>G)" in expandTauChainFrame) auto

  from PChain `A\<^isub>F \<sharp>* P` `A\<^isub>G \<sharp>* P` have "A\<^isub>F \<sharp>* P'" and "A\<^isub>G \<sharp>* P'" by(blast dest: tauChainFreshChain)+

  with `A\<^isub>F \<sharp>* P` `A\<^isub>G \<sharp>* P` `A\<^isub>P \<sharp>* A\<^isub>F` `A\<^isub>P \<sharp>* A\<^isub>G``A\<^isub>P' \<sharp>* A\<^isub>F` `A\<^isub>P' \<sharp>* A\<^isub>G` FrP FrP'
  have "A\<^isub>F \<sharp>* \<Psi>\<^isub>P" and "A\<^isub>G \<sharp>* \<Psi>\<^isub>P" and "A\<^isub>F \<sharp>* \<Psi>\<^isub>P'" and "A\<^isub>G \<sharp>* \<Psi>\<^isub>P'"
    by(auto dest: extractFrameFreshChain)

  from FeqG have FeqG: "insertAssertion (\<langle>A\<^isub>F, \<Psi>\<^isub>F \<otimes> \<Psi>\<^isub>P\<rangle>) \<Psi>' \<hookrightarrow>\<^sub>F insertAssertion (\<langle>A\<^isub>G, \<Psi>\<^isub>G \<otimes> \<Psi>\<^isub>P\<rangle>) \<Psi>'"
    by blast
  obtain p::"name prm" where "(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>F" and  "(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>P" and "(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>P'" and "(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>'"
                         and Sp: "(set p) \<subseteq> set A\<^isub>F \<times> set(p \<bullet> A\<^isub>F)" and "distinctPerm p"
      by(rule_tac xvec=A\<^isub>F and c="(\<Psi>\<^isub>F, \<Psi>\<^isub>P, \<Psi>', \<Psi>\<^isub>P')" in name_list_avoiding) auto
  obtain q::"name prm" where "(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>G" and  "(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>P" and "(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>P'" and "(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>'"
                         and Sq: "(set q) \<subseteq> set A\<^isub>G \<times> set(q \<bullet> A\<^isub>G)" and "distinctPerm q"
    by(rule_tac xvec=A\<^isub>G and c="(\<Psi>\<^isub>G, \<Psi>\<^isub>P, \<Psi>', \<Psi>\<^isub>P')" in name_list_avoiding) auto
  from `\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'` have "\<langle>(p \<bullet> A\<^isub>F), ((p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P')\<rangle> \<simeq>\<^sub>F \<langle>(p \<bullet> A\<^isub>F), (p \<bullet> \<Psi>\<^isub>F) \<otimes> (\<Psi>\<^isub>P \<otimes> \<Psi>')\<rangle>"
    by(rule frameIntCompositionSym[OF AssertionStatEqSym])
  hence "\<langle>(p \<bullet> A\<^isub>F), (p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P'\<rangle> \<simeq>\<^sub>F \<langle>(p \<bullet> A\<^isub>F), \<Psi>' \<otimes> ((p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P)\<rangle>"
    by(metis frameIntAssociativity FrameStatEqTrans frameIntCommutativity FrameStatEqSym)
  moreover from FeqG `A\<^isub>F \<sharp>* \<Psi>\<^isub>P` `(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>P` `(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>F` `(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>'` Sp
  have "\<langle>(p \<bullet> A\<^isub>F), \<Psi>' \<otimes> ((p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P)\<rangle> \<hookrightarrow>\<^sub>F insertAssertion (\<langle>A\<^isub>G, \<Psi>\<^isub>G \<otimes> \<Psi>\<^isub>P\<rangle>) \<Psi>'"
    apply(erule_tac rev_mp) by(subst frameChainAlpha) (auto simp add: eqvts)
  hence "\<langle>(p \<bullet> A\<^isub>F), \<Psi>' \<otimes> ((p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P)\<rangle> \<hookrightarrow>\<^sub>F  (\<langle>(q \<bullet> A\<^isub>G), \<Psi>' \<otimes> (q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P\<rangle>)"
    using `A\<^isub>G \<sharp>* \<Psi>\<^isub>P` `(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>P` `(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>G` `(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>'` Sq
    apply(erule_tac rev_mp) by(subst frameChainAlpha) (auto simp add: eqvts)
  moreover have "\<langle>(q \<bullet> A\<^isub>G), \<Psi>' \<otimes> ((q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P)\<rangle> \<simeq>\<^sub>F \<langle>(q \<bullet> A\<^isub>G), (q \<bullet> \<Psi>\<^isub>G) \<otimes> (\<Psi>\<^isub>P \<otimes> \<Psi>')\<rangle>"
    by(metis frameIntAssociativity FrameStatEqTrans frameIntCommutativity FrameStatEqSym)
  hence "\<langle>(q \<bullet> A\<^isub>G), \<Psi>' \<otimes> ((q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P)\<rangle> \<simeq>\<^sub>F \<langle>(q \<bullet> A\<^isub>G), (q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P'\<rangle>" using `\<Psi>\<^isub>P \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>P'`
    by(blast intro: FrameStatEqTrans frameIntCompositionSym)
  ultimately have "\<langle>(p \<bullet> A\<^isub>F), (p \<bullet> \<Psi>\<^isub>F) \<otimes> \<Psi>\<^isub>P'\<rangle> \<hookrightarrow>\<^sub>F \<langle>(q \<bullet> A\<^isub>G), (q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P'\<rangle>"
    by(rule FrameStatEqImpCompose)
  with `A\<^isub>F \<sharp>* \<Psi>\<^isub>P'` `(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>P'` `(p \<bullet> A\<^isub>F) \<sharp>* \<Psi>\<^isub>F` Sp have "\<langle>A\<^isub>F, \<Psi>\<^isub>F \<otimes> \<Psi>\<^isub>P'\<rangle> \<hookrightarrow>\<^sub>F \<langle>(q \<bullet> A\<^isub>G), (q \<bullet> \<Psi>\<^isub>G) \<otimes> \<Psi>\<^isub>P'\<rangle>"
    by(subst frameChainAlpha) (auto simp add: eqvts)
  with `A\<^isub>G \<sharp>* \<Psi>\<^isub>P'` `(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>P'` `(q \<bullet> A\<^isub>G) \<sharp>* \<Psi>\<^isub>G` Sq have "\<langle>A\<^isub>F, \<Psi>\<^isub>F \<otimes> \<Psi>\<^isub>P'\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>G, \<Psi>\<^isub>G \<otimes> \<Psi>\<^isub>P'\<rangle>"
    by(subst frameChainAlpha) (auto simp add: eqvts)
  
  with `\<Psi>\<^isub>F \<rhd> P' \<longmapsto>\<tau> \<prec> P''` FrP' `distinct A\<^isub>P'`
       `A\<^isub>F \<sharp>* P'` `A\<^isub>G \<sharp>* P'` `A\<^isub>F \<sharp>* \<Psi>\<^isub>G` `A\<^isub>G \<sharp>* \<Psi>\<^isub>F` `A\<^isub>P' \<sharp>* A\<^isub>F` `A\<^isub>P' \<sharp>* A\<^isub>G` `A\<^isub>P' \<sharp>* \<Psi>\<^isub>F` `A\<^isub>P' \<sharp>* \<Psi>\<^isub>G`
  have "\<Psi>\<^isub>G \<rhd> P' \<longmapsto>\<tau> \<prec> P''" by(rule_tac transferTauFrame)
  with PChain show ?case by(simp add: r_into_rtrancl rtrancl_into_rtrancl)
qed

coinductive quiet :: "('a, 'b, 'c) psi \<Rightarrow> bool"
  where "\<lbrakk>\<forall>\<Psi>. (insertAssertion (extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle> \<and> 
              (\<forall>Rs. \<Psi> \<rhd> P \<longmapsto> Rs \<longrightarrow> (\<exists>P'. Rs = \<tau> \<prec> P' \<and> quiet P')))\<rbrakk> \<Longrightarrow> quiet P"

lemma quietFrame:
  fixes \<Psi> :: 'b
  and   P    :: "('a, 'b, 'c) psi"

  assumes "quiet P"

  shows "insertAssertion (extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>"
using assms
by(erule_tac quiet.cases) force
  
lemma quietTransition:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   Rs :: "('a, 'b, 'c) residual"

  assumes "quiet P"
  and     "\<Psi> \<rhd> P \<longmapsto> Rs"

  obtains P' where "Rs = \<tau> \<prec> P'" and "quiet P'"
using assms
by(erule_tac quiet.cases) force
  
lemma quietEqvt:
  fixes P :: "('a, 'b, 'c) psi"
  and   p :: "name prm"

  assumes "quiet P"

  shows "quiet(p \<bullet> P)"
proof -
  let ?X = "\<lambda>P. \<exists>p::name prm. quiet(p \<bullet> P)"
  from assms have "?X (p \<bullet> P)" by(rule_tac x="rev p" in exI) auto
  thus ?thesis
    apply coinduct
    apply(clarify)
    apply(rule_tac x=x in exI)
    apply auto
    apply(drule_tac \<Psi>="p \<bullet> \<Psi>" in quietFrame)
    apply(drule_tac p="rev p" in FrameStatEqClosed)
    apply(simp add: eqvts)
    apply(drule_tac pi=p in semantics.eqvt)
    apply(erule_tac quietTransition)
    apply assumption
    apply(rule_tac x="rev p \<bullet> P'" in exI)
    apply auto
    apply(drule_tac pi="rev p" in pt_bij3)
    apply(simp add: eqvts)
    apply(rule_tac x=p in exI)
    by simp
qed
  

lemma quietOutput:
  fixes \<Psi>   :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P'   :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
  and     "quiet P"

  shows False
using assms
apply(erule_tac quiet.cases)
by(force simp add: residualInject)

lemma quietInput:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   M  :: 'a
  and   N  :: 'a
  and   P' :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
  and     "quiet P"

  shows False
using assms
by(erule_tac quiet.cases) (force simp add: residualInject)

lemma quietTau:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'"
  and     "insertAssertion (extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>"
  and     "quiet P"

  shows "quiet P'"
using assms
by(erule_tac quiet.cases) (force simp add: residualInject)

lemma tauChainCases[consumes 1, case_names TauBase TauStep]:
  fixes \<Psi>  :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "P = P' \<Longrightarrow> Prop"
  and     "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P' \<Longrightarrow> Prop"

  shows Prop
using assms
by(blast elim: rtranclE dest: rtrancl_into_trancl1)

end

end
