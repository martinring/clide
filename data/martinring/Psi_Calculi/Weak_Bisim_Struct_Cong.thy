(* 
   Title: Psi-calculi   
   Author/Maintainer: Jesper Bengtson (jebe@itu.dk), 2012
*)
theory Weak_Bisim_Struct_Cong
  imports Weak_Bisim_Pres Bisim_Struct_Cong
begin

context env begin

lemma weakBisimParComm:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  
  shows "\<Psi> \<rhd> P \<parallel> Q \<approx> Q \<parallel> P"
by(metis bisimParComm strongBisimWeakBisim)

lemma weakBisimResComm:
  fixes x :: name
  and   \<Psi> :: 'b
  and   y :: name
  and   P :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "y \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>y\<rparr>P) \<approx> \<lparr>\<nu>y\<rparr>(\<lparr>\<nu>x\<rparr>P)"
using assms
by(metis bisimResComm strongBisimWeakBisim)

lemma weakBisimResComm':
  fixes x    :: name
  and   \<Psi>   :: 'b
  and   xvec :: "name list"
  and   P    :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "xvec \<sharp>* \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>*xvec\<rparr>P) \<approx> \<lparr>\<nu>*xvec\<rparr>(\<lparr>\<nu>x\<rparr>P)"
using assms
by(metis bisimResComm' strongBisimWeakBisim)

lemma weakBisimScopeExt:
  fixes x :: name
  and   \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "x \<sharp> P"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(P \<parallel> Q) \<approx> P \<parallel> \<lparr>\<nu>x\<rparr>Q"
using assms
by(metis bisimScopeExt strongBisimWeakBisim)

lemma weakBisimScopeExtChain:
  fixes xvec :: "name list"
  and   \<Psi>    :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  assumes "xvec \<sharp>* \<Psi>"
  and     "xvec \<sharp>* P"

  shows "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P \<parallel> Q) \<approx> P \<parallel> (\<lparr>\<nu>*xvec\<rparr>Q)"
using assms
by(metis bisimScopeExtChain strongBisimWeakBisim)

lemma weakBisimParAssoc:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> (P \<parallel> Q) \<parallel> R \<approx> P \<parallel> (Q \<parallel> R)"
by(metis bisimParAssoc strongBisimWeakBisim)

lemma weakBisimParNil:
  fixes P :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> P \<parallel> \<zero> \<approx> P"
by(metis bisimParNil strongBisimWeakBisim)

lemma weakBisimResNil:
  fixes x :: name
  and   \<Psi> :: 'b
  
  assumes "x \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>\<zero> \<approx> \<zero>"
using assms
by(metis bisimResNil strongBisimWeakBisim)

lemma weakBisimOutputPushRes:
  fixes x :: name
  and   \<Psi> :: 'b
  and   M :: 'a
  and   N :: 'a
  and   P :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "x \<sharp> M"
  and     "x \<sharp> N"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(M\<langle>N\<rangle>.P) \<approx> M\<langle>N\<rangle>.\<lparr>\<nu>x\<rparr>P"
using assms
by(metis bisimOutputPushRes strongBisimWeakBisim)

lemma weakBisimInputPushRes:
  fixes x    :: name
  and   \<Psi>    :: 'b
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a
  and   P    :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "x \<sharp> M"
  and     "x \<sharp> xvec"
  and     "x \<sharp> N"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(M\<lparr>\<lambda>*xvec N\<rparr>.P) \<approx> M\<lparr>\<lambda>*xvec N\<rparr>.\<lparr>\<nu>x\<rparr>P"
using assms
by(metis bisimInputPushRes strongBisimWeakBisim)

lemma weakBisimCasePushRes:
  fixes x  :: name
  and   \<Psi>  :: 'b
  and   Cs :: "('c \<times> ('a, 'b, 'c) psi) list"

  assumes "x \<sharp> \<Psi>"
  and     "x \<sharp> (map fst Cs)"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(Cases Cs) \<approx> Cases(map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) Cs)"
using assms
by(metis bisimCasePushRes strongBisimWeakBisim)

lemma weakBangExt:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  
  assumes "guarded P"

  shows "\<Psi> \<rhd> !P \<approx> P \<parallel> !P"
using assms
by(metis bangExt strongBisimWeakBisim)

lemma weakBisimParSym:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<approx> Q"

  shows "\<Psi> \<rhd> R \<parallel> P \<approx> R \<parallel> Q"
using assms
by(metis weakBisimParComm weakBisimParPres weakBisimTransitive)

lemma weakBisimScopeExtSym:
  fixes x :: name
  and   Q :: "('a, 'b, 'c) psi"
  and   P :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> \<Psi>"
  and     "x \<sharp> Q"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(P \<parallel> Q) \<approx> (\<lparr>\<nu>x\<rparr>P) \<parallel> Q"
using assms
by(metis weakBisimScopeExt weakBisimTransitive weakBisimParComm weakBisimE weakBisimResPres)

lemma weakBisimScopeExtChainSym:
  fixes xvec :: "name list"
  and   Q    :: "('a, 'b, 'c) psi"
  and   P    :: "('a, 'b, 'c) psi"

  assumes "xvec \<sharp>* \<Psi>"
  and     "xvec \<sharp>* Q"

  shows "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P \<parallel> Q) \<approx> (\<lparr>\<nu>*xvec\<rparr>P) \<parallel> Q"
using assms
by(induct xvec) (auto intro: weakBisimScopeExtSym weakBisimReflexive weakBisimTransitive weakBisimResPres)

lemma weakBisimParPresAuxSym:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
  and     "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
  and     "A\<^isub>R \<sharp>* \<Psi>"
  and     "A\<^isub>R \<sharp>* P"
  and     "A\<^isub>R \<sharp>* Q"

  shows "\<Psi> \<rhd> R \<parallel> P \<approx> R \<parallel> Q"
using assms
by(metis weakBisimParComm weakBisimParPresAux weakBisimTransitive)

lemma weakBisimParPresSym:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<approx> Q"

  shows "\<Psi> \<rhd> R \<parallel> P \<approx> R \<parallel> Q"
using assms
by(metis weakBisimParComm weakBisimParPres weakBisimTransitive)

lemma guardedFrameStatEq:
  fixes P :: "('a, 'b, 'c) psi"

  assumes "guarded P"

  shows "extractFrame P \<simeq>\<^sub>F \<langle>\<epsilon>, \<one>\<rangle>"
proof -
  obtain A\<^isub>P \<Psi>\<^isub>P where FrR: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>"
    by(rule freshFrame)

  with `guarded P` have "\<Psi>\<^isub>P \<simeq> \<one>" and "((supp \<Psi>\<^isub>P)::name set) = {}"
    by(metis guardedStatEq)+
  from `supp \<Psi>\<^isub>P = {}` have "A\<^isub>P \<sharp>* \<Psi>\<^isub>P" by(auto simp add: fresh_star_def fresh_def)
  hence "\<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle> \<simeq>\<^sub>F \<langle>[], \<Psi>\<^isub>P\<rangle>" by(force intro: frameResFreshChain)
  moreover from `\<Psi>\<^isub>P \<simeq> \<one>` have  "\<langle>[], \<Psi>\<^isub>P\<rangle> \<simeq>\<^sub>F \<langle>[], \<one>\<rangle>"
    by(simp add: FrameStatEq_def FrameStatImp_def AssertionStatEq_def AssertionStatImp_def)
  ultimately show ?thesis using FrR by(rule_tac FrameStatEqTrans) auto
qed

lemma guardedInsertAssertion:
  fixes P :: "('a, 'b, 'c) psi"
  and   \<Psi> :: 'b

  assumes "guarded P"

  shows "insertAssertion (extractFrame P) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>"
proof -
  obtain A\<^isub>P \<Psi>\<^isub>P where FrR: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>"
    by(rule freshFrame)

  with `guarded P` have "\<Psi>\<^isub>P \<simeq> \<one>" and "((supp \<Psi>\<^isub>P)::name set) = {}"
    by(metis guardedStatEq)+
  from `supp \<Psi>\<^isub>P = {}` have "A\<^isub>P \<sharp>* \<Psi>\<^isub>P" by(auto simp add: fresh_star_def fresh_def)
  hence "\<langle>A\<^isub>P, \<Psi> \<otimes> \<Psi>\<^isub>P\<rangle> \<simeq>\<^sub>F \<langle>[], \<Psi> \<otimes> \<Psi>\<^isub>P\<rangle>" using `A\<^isub>P \<sharp>* \<Psi>` by(force intro: frameResFreshChain)
  moreover from `\<Psi>\<^isub>P \<simeq> \<one>` have  "\<langle>\<epsilon>, \<Psi> \<otimes> \<Psi>\<^isub>P\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>" by(force intro: compositionSym)
  moreover have "\<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>" by(force intro: Identity)
  ultimately show ?thesis using FrR `A\<^isub>P \<sharp>* \<Psi>`
    by(force intro: FrameStatEqTrans AssertionStatEqTrans)
qed

lemma insertDoubleAssertionStatEq':
  fixes F  :: "'b frame"
  and   \<Psi>  :: 'b
  and   \<Psi>' :: 'b

  shows "insertAssertion(insertAssertion F \<Psi>) \<Psi>' \<simeq>\<^sub>F (insertAssertion F) (\<Psi>' \<otimes> \<Psi>)"
proof -
  obtain A\<^isub>F \<Psi>\<^isub>F where "F = \<langle>A\<^isub>F, \<Psi>\<^isub>F\<rangle>" and "A\<^isub>F \<sharp>* \<Psi>" and "A\<^isub>F \<sharp>* \<Psi>'" and "A\<^isub>F \<sharp>* (\<Psi>' \<otimes> \<Psi>)"
    by(rule_tac C="(\<Psi>, \<Psi>')" in freshFrame) auto
  thus ?thesis
    by auto (metis frameIntAssociativity FrameStatEqSym)
qed

lemma bangActE:
  assumes "\<Psi> \<rhd> !P \<longmapsto>\<alpha> \<prec> P'"
  and     "bn \<alpha> \<sharp>* subject \<alpha>"
  and     "guarded P"
  and     "\<alpha> \<noteq> \<tau>"
  and     "bn \<alpha> \<sharp>* P"

  obtains Q where "\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q" and "P' \<sim> Q \<parallel> !P"
proof -
  assume "\<And>Q. \<lbrakk>\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q; P' \<sim> Q \<parallel> !P\<rbrakk> \<Longrightarrow> thesis"
  moreover from `\<Psi> \<rhd> !P \<longmapsto>\<alpha> \<prec> P'` `bn \<alpha> \<sharp>* subject \<alpha>` `\<alpha> \<noteq> \<tau>` `bn \<alpha> \<sharp>* P`  have "\<exists>Q. \<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q \<and> P' \<sim> Q \<parallel> !P"
  proof(nominal_induct rule: bangInduct')
    case(cAlpha \<alpha> P' p)
    then obtain Q where "\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q" and "P' \<sim> Q \<parallel> (P \<parallel> !P)" by fastsimp
    from `\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q` have "distinct(bn \<alpha>)" by(rule boundOutputDistinct)
    have S: "set p \<subseteq> set(bn \<alpha>) \<times> set(bn(p \<bullet> \<alpha>))" by fact
    from `\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q` `bn(p \<bullet> \<alpha>) \<sharp>* \<alpha>` `bn(p \<bullet> \<alpha>) \<sharp>* P` `bn \<alpha> \<sharp>* subject \<alpha>` `distinct(bn \<alpha>)`
    have "bn(p \<bullet> \<alpha>) \<sharp>* Q" by(force dest: freeFreshChainDerivative)
    with `\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q` `bn(p \<bullet> \<alpha>) \<sharp>* \<alpha>` S `bn \<alpha> \<sharp>* subject \<alpha>` `distinct(bn \<alpha>)` have "\<Psi> \<rhd> P \<longmapsto>(p \<bullet> \<alpha>) \<prec> (p \<bullet> Q)"
      by(fastsimp simp add: residualAlpha)
    moreover from `P' \<sim> Q \<parallel> (P \<parallel> !P)` have "(p \<bullet> \<one>) \<rhd> (p \<bullet> P') \<sim> (p \<bullet> (Q \<parallel> (P \<parallel> !P)))"
      by(rule bisimClosed)
    with `(bn \<alpha>) \<sharp>* P` `bn(p \<bullet> \<alpha>) \<sharp>* P` S have "(p \<bullet> P') \<sim> (p \<bullet> Q) \<parallel> (P \<parallel> !P)"
      by(simp add: eqvts)
    ultimately show ?case by blast
  next
    case(cPar1 \<alpha> P')
    from `guarded P` have "P' \<parallel> !P \<sim> P' \<parallel> (P \<parallel> !P)" by(metis bangExt bisimParPresSym)
    with `\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> P'` show ?case by blast
  next
    case(cPar2 \<alpha> P')
    then obtain Q where PTrans: "\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q" and "P' \<sim> Q \<parallel> !P" by blast
    from `P' \<sim> Q \<parallel> !P` have "P \<parallel> P' \<sim> Q \<parallel> (P \<parallel> !P)"
      by(metis bisimParPresSym bisimParAssoc bisimTransitive bisimParComm)
    with PTrans show ?case by blast
  next
    case cComm1
    from `\<tau> \<noteq> \<tau>` have False by simp
    thus ?case by simp
  next
    case cComm2
    from `\<tau> \<noteq> \<tau>` have False by simp
    thus ?case by simp
  next
    case(cBang \<alpha> P')
    then obtain Q where PTrans: "\<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q" and "P' \<sim> Q \<parallel> (P \<parallel> !P)" by blast
    from `P' \<sim> Q \<parallel> (P \<parallel> !P)` `guarded P` have "P' \<sim> Q \<parallel> !P" by(metis bisimTransitive bisimParPresSym bangExt bisimSymmetric)
    with PTrans show ?case by blast
  qed
  ultimately show ?thesis by blast
qed

lemma bangTauE:
  assumes "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> P'"
  and     "guarded P"

  obtains Q where "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> Q" and "P' \<sim> Q \<parallel> !P"
using assms
proof -
  assume "\<And>Q. \<lbrakk>\<Psi> \<rhd> P \<parallel> P\<longmapsto>\<tau> \<prec> Q; P' \<sim> Q \<parallel> !P\<rbrakk> \<Longrightarrow> thesis"
  moreover from assms have "\<exists>Q. \<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> Q \<and> P' \<sim> Q \<parallel> !P"
  proof(nominal_induct rule: bangTauInduct)
    case(cPar1 P')
    obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>" and "A\<^isub>P \<sharp>* P"
      by(rule_tac C="(\<Psi>, P)" in freshFrame) auto
    from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" by(drule_tac guardedStatEq) auto
    with `\<Psi> \<rhd> P \<longmapsto>\<tau> \<prec> P'` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>\<tau> \<prec> P'"
      by(rule_tac statEqTransition, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    hence "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> P' \<parallel> P" using FrP `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P` by(rule_tac Par1) auto 
    moreover from `guarded P` have "P' \<parallel> !P \<sim> (P' \<parallel> P) \<parallel> (P \<parallel> !P)"
      by(metis bisimParPresSym bisimParAssoc bisimTransitive bisimParComm bangExt)
    ultimately show ?case by blast
  next
    case(cPar2 P')
    then obtain n Q where PTrans: "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> Q" and "P' \<sim> Q \<parallel> !P" by blast
    from `P' \<sim> Q \<parallel> !P` have "P \<parallel> P' \<sim> Q \<parallel> (P \<parallel> !P)"
      by(metis bisimParPresSym bisimParAssoc bisimTransitive bisimParComm)
    with PTrans show ?case by blast
  next
    case(cComm1 M N P' K xvec P'')
    obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>" and "A\<^isub>P \<sharp>* P" and "A\<^isub>P \<sharp>* M"
      by(rule_tac C="(\<Psi>, P, M)" in freshFrame) auto
    from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" by(drule_tac guardedStatEq) auto
    obtain A\<^isub>P' \<Psi>\<^isub>P' where FrP': "extractFrame P = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "A\<^isub>P' \<sharp>* \<Psi>" and "A\<^isub>P' \<sharp>* P" and "A\<^isub>P' \<sharp>* K" and "A\<^isub>P' \<sharp>* A\<^isub>P"
      by(rule_tac C="(\<Psi>, P, K, A\<^isub>P)" in freshFrame) auto
    from `guarded P` FrP' have "\<Psi>\<^isub>P' \<simeq> \<one>" by(drule_tac guardedStatEq) auto
    with `\<Psi> \<rhd> P \<longmapsto>M\<lparr>N\<rparr> \<prec> P'` have "\<Psi> \<otimes> \<Psi>\<^isub>P' \<rhd> P \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
      by(rule_tac statEqTransition, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    moreover from `\<Psi> \<rhd> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P''` `guarded P` `xvec \<sharp>* P` `xvec \<sharp>* K`
    obtain Q where PTrans: "\<Psi> \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q" and "P'' \<sim> Q \<parallel> !P" 
      by(drule_tac bangActE) auto
    from PTrans `\<Psi>\<^isub>P \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q"
      by(rule_tac statEqTransition, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    moreover from `\<Psi> \<turnstile> M \<leftrightarrow> K` `\<Psi>\<^isub>P \<simeq> \<one>` `\<Psi>\<^isub>P' \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>P' \<turnstile> M \<leftrightarrow> K"
      by(rule_tac statEqEnt, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    ultimately have "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q)" using FrP FrP' `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* M` `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* P` `A\<^isub>P' \<sharp>* K` `A\<^isub>P' \<sharp>* A\<^isub>P` `xvec \<sharp>* P`
      by(rule_tac Comm1) (assumption | simp)+
    moreover from `P'' \<sim> Q \<parallel> !P` `guarded P` have "P' \<parallel> P'' \<sim> (P' \<parallel> Q) \<parallel> (P \<parallel> !P)"
      by(metis bisimTransitive bangExt bisimParPresSym bisimParAssoc bisimSymmetric) 
    hence "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'') \<sim> \<lparr>\<nu>*xvec\<rparr>((P' \<parallel> Q) \<parallel> (P \<parallel> !P))" by(rule_tac bisimResChainPres) auto
    with `xvec \<sharp>* P` `xvec \<sharp>* \<Psi>` have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'') \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q)) \<parallel> (P \<parallel> !P)"
      by(force intro: bisimTransitive bisimScopeExtChainSym)
    ultimately show ?case by blast
  next
    case(cComm2 M N P' K xvec P'')
    obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* \<Psi>" and "A\<^isub>P \<sharp>* P" and "A\<^isub>P \<sharp>* M"
      by(rule_tac C="(\<Psi>, P, M)" in freshFrame) auto
    from `guarded P` FrP have "\<Psi>\<^isub>P \<simeq> \<one>" by(drule_tac guardedStatEq) auto
    obtain A\<^isub>P' \<Psi>\<^isub>P' where FrP': "extractFrame P = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "A\<^isub>P' \<sharp>* \<Psi>" and "A\<^isub>P' \<sharp>* P" and "A\<^isub>P' \<sharp>* K" and "A\<^isub>P' \<sharp>* A\<^isub>P"
      by(rule_tac C="(\<Psi>, P, K, A\<^isub>P)" in freshFrame) auto
    from `guarded P` FrP' have "\<Psi>\<^isub>P' \<simeq> \<one>" by(drule_tac guardedStatEq) auto
    with `\<Psi> \<rhd> P \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'` have "\<Psi> \<otimes> \<Psi>\<^isub>P' \<rhd> P \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
      by(rule_tac statEqTransition, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    moreover from `\<Psi> \<rhd> !P \<longmapsto>K\<lparr>N\<rparr> \<prec> P''` `guarded P`
    obtain Q where PTrans: "\<Psi> \<rhd> P \<longmapsto>K\<lparr>N\<rparr> \<prec> Q" and "P'' \<sim> Q \<parallel> !P" by(rule_tac bangActE) auto
    from PTrans `\<Psi>\<^isub>P \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>K\<lparr>N\<rparr> \<prec> Q"
      by(rule_tac statEqTransition, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    moreover from `\<Psi> \<turnstile> M \<leftrightarrow> K` `\<Psi>\<^isub>P \<simeq> \<one>` `\<Psi>\<^isub>P' \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>P' \<turnstile> M \<leftrightarrow> K"
      by(rule_tac statEqEnt, auto) (metis Identity AssertionStatEqSym compositionSym AssertionStatEqTrans)
    ultimately have "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q)" using FrP FrP' `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* M` `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* P` `A\<^isub>P' \<sharp>* K` `A\<^isub>P' \<sharp>* A\<^isub>P` `xvec \<sharp>* P`
      by(rule_tac Comm2) (assumption | simp)+
    moreover from `P'' \<sim> Q \<parallel> !P` `guarded P` have "P' \<parallel> P'' \<sim> (P' \<parallel> Q) \<parallel> (P \<parallel> !P)"
      by(metis bisimTransitive bangExt bisimParPresSym bisimParAssoc bisimSymmetric) 
    hence "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'') \<sim> \<lparr>\<nu>*xvec\<rparr>((P' \<parallel> Q) \<parallel> (P \<parallel> !P))" by(rule_tac bisimResChainPres) auto
    with `xvec \<sharp>* P` `xvec \<sharp>* \<Psi>` have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'') \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> Q)) \<parallel> (P \<parallel> !P)"
      by(force intro: bisimTransitive bisimScopeExtChainSym)
    ultimately show ?case by blast
  next
    case(cBang P')
    then obtain Q where PTrans: "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> Q" and "P' \<sim> Q \<parallel> (P \<parallel> !P)" by blast
    from `P' \<sim> Q \<parallel> (P \<parallel> !P)` `guarded P` have "P' \<sim> Q \<parallel> !P" by(metis bisimTransitive bisimParPresSym bangExt bisimSymmetric)
    with PTrans show ?case by blast
  qed
  ultimately show ?thesis by blast
qed

lemma tauBangI:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> P'"
  and     "guarded P"

  obtains Q where "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> Q" and "Q \<sim> P' \<parallel> !P"
proof -
  assume "\<And>Q. \<lbrakk>\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> Q; Q \<sim> P' \<parallel> !P\<rbrakk> \<Longrightarrow> thesis"
  moreover from `\<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> P'` have "\<exists>Q. \<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> Q \<and> Q \<sim> P' \<parallel> !P"
  proof(induct rule: parTauCases[where C="()"])
    case(cPar1 P' A\<^isub>P \<Psi>\<^isub>P)
    from `\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>\<tau> \<prec> P'` have "(\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<one> \<rhd> P \<longmapsto>\<tau> \<prec> P'" 
      by(rule statEqTransition) (metis Identity AssertionStatEqSym)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> P' \<parallel> !P" by(rule_tac Par1) auto
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> !P \<longmapsto>\<tau> \<prec> P' \<parallel> !P" using `guarded P` by(rule Bang)
     hence "\<Psi> \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> P \<parallel> (P' \<parallel> !P)" using `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>` `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P`
       by(rule_tac Par2) auto
     hence "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> P \<parallel> (P' \<parallel> !P)" using `guarded P` by(rule Bang)
     moreover have "P \<parallel> (P' \<parallel> !P) \<sim> P' \<parallel> P \<parallel> !P"
       by(metis bisimParAssoc bisimParComm bisimTransitive bisimSymmetric bisimParPres)
     ultimately show ?case by blast
   next
    case(cPar2 P' A\<^isub>P \<Psi>\<^isub>P)
    from `\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>\<tau> \<prec> P'` have "(\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<one> \<rhd> P \<longmapsto>\<tau> \<prec> P'" 
      by(rule statEqTransition) (metis Identity AssertionStatEqSym)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> P' \<parallel> !P" by(rule_tac Par1) auto
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> !P \<longmapsto>\<tau> \<prec> P' \<parallel> !P" using `guarded P` by(rule Bang)
     hence "\<Psi> \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> P \<parallel> (P' \<parallel> !P)" using `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>` `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P`
       by(rule_tac Par2) auto
     hence "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> P \<parallel> (P' \<parallel> !P)" using `guarded P` by(rule Bang)
     moreover have "P \<parallel> (P' \<parallel> !P) \<sim> P \<parallel> P' \<parallel> !P"
       by(metis bisimParAssoc bisimSymmetric)
     ultimately show ?case by blast
   next
     case(cComm1 \<Psi>\<^isub>P' M N P' A\<^isub>P \<Psi>\<^isub>P K xvec P'' A\<^isub>P')
     from `extractFrame P = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>` `guarded P` have "\<Psi>\<^isub>P' \<simeq> \<one>" by(blast dest: guardedStatEq)
     with `\<Psi> \<otimes> \<Psi>\<^isub>P' \<rhd> P \<longmapsto>M\<lparr>N\<rparr> \<prec> P'` have "\<Psi> \<otimes> \<one> \<rhd> P \<longmapsto>M\<lparr>N\<rparr> \<prec> P'"
       by(rule_tac statEqTransition, auto) (metis compositionSym AssertionStatEqSym)
     moreover note `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>`
     moreover from `\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P''` have "(\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<one> \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P''"
       by(rule statEqTransition) (metis Identity AssertionStatEqSym)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<parallel> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (P'' \<parallel> !P)" using `xvec \<sharp>* P` by(force intro: Par1)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (P'' \<parallel> !P)" using `guarded P` by(rule Bang)
     moreover from `\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>P' \<turnstile> M \<leftrightarrow> K` `\<Psi>\<^isub>P' \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<one> \<turnstile> M \<leftrightarrow> K"
       by(rule_tac statEqEnt, auto) (metis compositionSym AssertionStatEqSym)
     ultimately have "\<Psi> \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P))"
       using `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* M` `A\<^isub>P \<sharp>* A\<^isub>P'` `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* P` `A\<^isub>P' \<sharp>* K` `xvec \<sharp>* P`
       by(force intro: Comm1)
     hence "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P))" using `guarded P` by(rule Bang)
     moreover have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P)) \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'')) \<parallel> !P" 
     proof -
       have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P)) \<sim> \<lparr>\<nu>*xvec\<rparr>((P' \<parallel> P'') \<parallel> !P)"
	 by(force intro: bisimResChainPres bisimParAssoc[THEN bisimSymmetric])
       moreover have "\<lparr>\<nu>*xvec\<rparr>((P' \<parallel> P'') \<parallel> !P) \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'')) \<parallel> !P" using `xvec \<sharp>* P`
	 by(rule_tac bisimScopeExtChainSym) auto
       ultimately show ?thesis by(rule bisimTransitive)
     qed
     ultimately show ?case by blast
   next
     case(cComm2 \<Psi>\<^isub>P' M xvec N P' A\<^isub>P \<Psi>\<^isub>P K P'' A\<^isub>P')
     from `extractFrame P = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>` `guarded P` have "\<Psi>\<^isub>P' \<simeq> \<one>" by(blast dest: guardedStatEq)
     with `\<Psi> \<otimes> \<Psi>\<^isub>P' \<rhd> P \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle>\<prec> P'` have "\<Psi> \<otimes> \<one> \<rhd> P \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
       by(rule_tac statEqTransition, auto) (metis compositionSym AssertionStatEqSym)
     moreover note `extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>`
     moreover from `\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<longmapsto>K\<lparr>N\<rparr> \<prec> P''` have "(\<Psi> \<otimes> \<Psi>\<^isub>P) \<otimes> \<one> \<rhd> P \<longmapsto>K\<lparr>N\<rparr> \<prec> P''"
       by(rule statEqTransition) (metis Identity AssertionStatEqSym)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> P \<parallel> !P \<longmapsto>K\<lparr>N\<rparr> \<prec> (P'' \<parallel> !P)" by(force intro: Par1)
     hence "\<Psi> \<otimes> \<Psi>\<^isub>P \<rhd> !P \<longmapsto>K\<lparr>N\<rparr> \<prec> (P'' \<parallel> !P)" using `guarded P` by(rule Bang)
     moreover from `\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<Psi>\<^isub>P' \<turnstile> M \<leftrightarrow> K` `\<Psi>\<^isub>P' \<simeq> \<one>` have "\<Psi> \<otimes> \<Psi>\<^isub>P \<otimes> \<one> \<turnstile> M \<leftrightarrow> K"
       by(rule_tac statEqEnt, auto) (metis compositionSym AssertionStatEqSym)
     ultimately have "\<Psi> \<rhd> P \<parallel> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P))"
       using `A\<^isub>P \<sharp>* \<Psi>` `A\<^isub>P \<sharp>* P` `A\<^isub>P \<sharp>* M` `A\<^isub>P \<sharp>* A\<^isub>P'` `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* P` `A\<^isub>P' \<sharp>* K` `xvec \<sharp>* P`
       by(force intro: Comm2)
     hence "\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P))" using `guarded P` by(rule Bang)
     moreover have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P)) \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'')) \<parallel> !P" 
     proof -
       have "\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> (P'' \<parallel> !P)) \<sim> \<lparr>\<nu>*xvec\<rparr>((P' \<parallel> P'') \<parallel> !P)"
	 by(force intro: bisimResChainPres bisimParAssoc[THEN bisimSymmetric])
       moreover have "\<lparr>\<nu>*xvec\<rparr>((P' \<parallel> P'') \<parallel> !P) \<sim> (\<lparr>\<nu>*xvec\<rparr>(P' \<parallel> P'')) \<parallel> !P" using `xvec \<sharp>* P`
	 by(rule_tac bisimScopeExtChainSym) auto
       ultimately show ?thesis by(rule bisimTransitive)
     qed
     ultimately show ?case by blast
   qed
   ultimately show ?thesis by blast
qed

lemma tauChainBangI:
  fixes \<Psi> :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   P' :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<parallel> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
  and     "guarded P"

  obtains Q where "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q" and "\<Psi> \<rhd> Q \<sim> P' \<parallel> !P"
proof -
  assume "\<And>Q. \<lbrakk>\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q; \<Psi> \<rhd> Q \<sim> P' \<parallel> !P\<rbrakk> \<Longrightarrow> thesis"
  moreover from `\<Psi> \<rhd> P \<parallel> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'` have "\<exists>Q. \<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q \<and> \<Psi> \<rhd> Q \<sim> P' \<parallel> !P"
  proof(induct x1=="P \<parallel> P" P' rule: tauChainInduct)
    case TauBase
    have "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> !P" by simp
    moreover have "\<Psi> \<rhd> !P \<sim> (P \<parallel> P) \<parallel> !P" using `guarded P`
      by(metis bisimParAssoc bisimTransitive bisimParPresSym bangExt bisimParComm)
    ultimately show ?case by blast
  next
    case(TauStep R' R'')
    then obtain Q where PChain: "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q" and "\<Psi> \<rhd> Q \<sim> R' \<parallel> !P" by auto
    from `\<Psi> \<rhd> R' \<longmapsto>\<tau> \<prec> R''` have "\<Psi> \<otimes> \<one> \<rhd> R' \<longmapsto>\<tau> \<prec> R''" by(rule statEqTransition) (metis Identity AssertionStatEqSym)
    hence "\<Psi> \<rhd> R' \<parallel> !P \<longmapsto>\<tau> \<prec> R'' \<parallel> !P" by(rule_tac Par1) auto
    with `\<Psi> \<rhd> Q \<sim> R' \<parallel> !P` obtain Q' where QTrans: "\<Psi> \<rhd> Q \<longmapsto>\<tau> \<prec> Q'" and "\<Psi> \<rhd> Q' \<sim> R'' \<parallel> !P"
      by(force dest: bisimE(2) simE)
    from PChain QTrans have "\<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q'" by(auto dest: tauActTauChain)
    thus ?case using `\<Psi> \<rhd> Q' \<sim> R'' \<parallel> !P` by blast
  qed
  ultimately show ?thesis by blast
qed

lemma weakBisimBangPresAux:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<approx> Q"
  and     "guarded P"
  and     "guarded Q"

  shows   "\<Psi> \<rhd> R \<parallel> !P \<approx> R \<parallel> !Q"
proof -
  let ?X = "{(\<Psi>, R \<parallel> !P, R \<parallel> !Q) | \<Psi> R P Q. guarded P \<and> guarded Q \<and> \<Psi> \<rhd> P \<approx> Q}"
  let ?Y = "{(\<Psi>, P, Q) | \<Psi> P Q. \<exists>R S. \<Psi> \<rhd> P \<approx> R \<and> (\<Psi>, R, S) \<in> ?X \<and> \<Psi> \<rhd> S \<sim> Q}"

  from assms have "(\<Psi>, R \<parallel> !P, R \<parallel> !Q) \<in> ?X" by auto
  moreover have "eqvt ?X"
    by(fastsimp simp add: eqvt_def intro: weakBisimClosed)
  ultimately show ?thesis
  proof(coinduct rule: weakTransitiveCoinduct2)
    case(cStatImp \<Psi> P Q)
    thus ?case by(force dest: weakBisimE(3) simp add: weakStatImp_def)
  next
    case(cSim \<Psi> P Q)
    moreover {
      fix \<Psi> P Q R
      assume "\<Psi> \<rhd> P \<approx> Q"
      moreover have "eqvt ?Y" 
	apply(auto simp add: eqvt_def)
	apply(rule_tac x="p \<bullet> (Ra \<parallel> !P)" in exI, auto)
	apply(fastsimp dest: weakBisimClosed simp add: eqvts)
	apply(rule_tac x="(p \<bullet> Ra) \<parallel> !(p \<bullet> Q)" in exI, auto)
	apply(rule_tac x="p \<bullet> Ra" in exI)
	apply(rule_tac x="p \<bullet> P" in exI, auto)
	apply(rule_tac x="p \<bullet> Q" in exI, auto)
	apply(blast intro: weakBisimClosed)
	by(fastsimp dest: bisimClosed simp add: eqvts)
      moreover assume "guarded P" and "guarded Q" 
      moreover note weakBisimClosed bisimClosed weakBisimE(3) bisimE(3) weakBisimE(2) weakBisimE(4) bisimE(4) statEqWeakBisim statEqBisim weakBisimTransitive bisimTransitive weakBisimParAssoc[THEN weakBisimE(4)] bisimParAssoc[THEN bisimE(4)] weakBisimParPres 
      moreover have "\<And>\<Psi> P Q. \<Psi> \<rhd> P \<approx> Q \<Longrightarrow> \<Psi> \<rhd> P \<parallel> P \<approx> Q \<parallel> Q"
	by(metis weakBisimParPres weakBisimParComm weakBisimE(4) weakBisimTransitive)
      moreover note bisimParPresSym
      moreover have "bisim \<subseteq> weakBisim" by(auto dest: strongBisimWeakBisim)
      moreover have "\<And>\<Psi> \<Psi>\<^isub>R P Q R A\<^isub>R. \<lbrakk>\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q; extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>; A\<^isub>R \<sharp>* \<Psi>; A\<^isub>R \<sharp>* P; A\<^isub>R \<sharp>* Q\<rbrakk> \<Longrightarrow> \<Psi> \<rhd> R \<parallel> P \<approx> R \<parallel> Q"
	by(metis weakBisimParComm weakBisimTransitive weakBisimParPresAux)
      moreover note weakBisimResChainPres bisimResChainPres weakBisimScopeExtChainSym bisimScopeExtChainSym
      moreover have "\<And>\<Psi> P R S Q. \<lbrakk>\<Psi> \<rhd> P \<approx> R; (\<Psi>, R, S) \<in> ?Y; \<Psi> \<rhd> S \<sim> Q\<rbrakk> \<Longrightarrow> (\<Psi>, P, Q) \<in> ?Y"
	by(blast dest: weakBisimTransitive bisimTransitive)
      moreover have "\<And>\<Psi> P Q R. \<lbrakk>\<Psi> \<rhd> P \<approx> Q; guarded P; guarded Q\<rbrakk> \<Longrightarrow> (\<Psi>, R \<parallel> !P, R \<parallel> !Q) \<in> ?Y"
	by(blast intro: bisimReflexive weakBisimReflexive)
      moreover from bangActE have "\<And>\<Psi> P \<alpha> P'. \<lbrakk>\<Psi> \<rhd> !P \<longmapsto>\<alpha> \<prec> P'; bn \<alpha> \<sharp>* P; guarded P; \<alpha> \<noteq> \<tau>; bn \<alpha> \<sharp>* subject \<alpha>\<rbrakk> \<Longrightarrow> \<exists>Q. \<Psi> \<rhd> P \<longmapsto>\<alpha> \<prec> Q \<and> P' \<sim> Q \<parallel> !P"
	by blast
      moreover from bangTauE have "\<And>\<Psi> P P'. \<lbrakk>\<Psi> \<rhd> !P \<longmapsto>\<tau> \<prec> P'; guarded P\<rbrakk> \<Longrightarrow> \<exists>Q. \<Psi> \<rhd> P \<parallel> P \<longmapsto>\<tau> \<prec> Q \<and> P' \<sim> Q \<parallel> !P"
	by blast
      moreover from tauChainBangI have "\<And>\<Psi> P P'. \<lbrakk>\<Psi> \<rhd> P \<parallel> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'; guarded P\<rbrakk> \<Longrightarrow> \<exists>Q. \<Psi> \<rhd> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> Q \<and> \<Psi> \<rhd> Q \<sim> P' \<parallel> !P"
	by blast
      ultimately have  "\<Psi> \<rhd> R \<parallel> !P \<leadsto><?Y> R \<parallel> !Q" 
	by(rule_tac weakSimBangPres)
    }
    ultimately show ?case by blast
  next
    case(cExt \<Psi> P Q \<Psi>')
    thus ?case by(blast dest: weakBisimE)
  next
    case(cSym \<Psi> P Q)
    thus ?case by(blast dest: weakBisimE)
  qed
qed


lemma weakBisimBangPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<approx> Q"
  and     "guarded P"
  and     "guarded Q"

  shows   "\<Psi> \<rhd> !P \<approx> !Q"
proof -
  from assms have "\<Psi> \<rhd> \<zero> \<parallel> !P \<approx> \<zero> \<parallel> !Q" by(rule weakBisimBangPresAux)
  thus ?thesis
    by(metis weakBisimParNil weakBisimParComm weakBisimTransitive weakBisimE(4))
qed

end

end

