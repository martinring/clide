(* 
   Title: Psi-calculi   
   Author/Maintainer: Jesper Bengtson (jebe@itu.dk), 2012
*)
theory Weak_Cong_Sim_Pres
  imports Weak_Sim_Pres Weak_Cong_Simulation
begin

context env begin

lemma caseWeakSimPres:
  fixes \<Psi>    :: 'b
  and   CsP  :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   Rel  :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   CsQ  :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   M    :: 'a
  and   N    :: 'a

  assumes PRelQ: "\<And>\<phi> Q. (\<phi>, Q) mem CsQ \<Longrightarrow> \<exists>P. (\<phi>, P) mem CsP \<and> guarded P \<and> Eq \<Psi> P Q"
  and     Sim:   "\<And>\<Psi>' P Q. (\<Psi>', P, Q) \<in> Rel \<Longrightarrow> \<Psi>' \<rhd> P \<leadsto><Rel> Q"
  and     EqRel: "\<And>\<Psi>' P Q. Eq \<Psi>' P Q \<Longrightarrow> (\<Psi>', P, Q) \<in> Rel"
  and     EqSim: "\<And>\<Psi>' P Q. Eq \<Psi>' P Q \<Longrightarrow> \<Psi>' \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"

  shows "\<Psi> \<rhd> Cases CsP \<leadsto><Rel> Cases CsQ"
proof(induct rule: weakSimI2)
  case(cAct \<Psi>' \<alpha> Q')
  from `bn \<alpha> \<sharp>* (Cases CsP)` have "bn \<alpha> \<sharp>* CsP" by auto
  from `\<Psi> \<rhd> Cases CsQ \<longmapsto>\<alpha> \<prec> Q'`
  show ?case
  proof(induct rule: caseCases)
    case(cCase \<phi> Q)
    from `(\<phi>, Q) mem CsQ` obtain P where "(\<phi>, P) mem CsP" and "guarded P" and "Eq \<Psi> P Q"
      by(metis PRelQ)
    from `Eq \<Psi> P Q` have "\<Psi> \<rhd> P \<leadsto><Rel> Q" by(metis EqRel Sim)
    moreover note `\<Psi> \<rhd> Q \<longmapsto>\<alpha> \<prec> Q'` `bn \<alpha> \<sharp>* \<Psi>`
    moreover from `bn \<alpha> \<sharp>* CsP` `(\<phi>, P) mem CsP` have "bn \<alpha> \<sharp>* P" by(auto dest: memFreshChain)
    ultimately obtain P'' P' where PTrans: "\<Psi> : Q \<rhd> P \<Longrightarrow>\<alpha> \<prec> P''"
                               and P''Chain: "\<Psi> \<otimes> \<Psi>' \<rhd> P'' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'" and P'RelQ': "(\<Psi> \<otimes> \<Psi>', P', Q') \<in> Rel"
      using `\<alpha> \<noteq> \<tau>`
      by(blast dest: weakSimE)
    note PTrans `(\<phi>, P) mem CsP` `\<Psi> \<turnstile> \<phi>` `guarded P`
    moreover from `guarded Q` have "insertAssertion (extractFrame Q) \<Psi> \<simeq>\<^sub>F \<langle>\<epsilon>, \<Psi> \<otimes> \<one>\<rangle>"
      by(rule insertGuardedAssertion)
    hence "insertAssertion (extractFrame(Cases CsQ)) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame Q) \<Psi>"
      by(auto simp add: FrameStatEq_def)
    moreover from Identity have "insertAssertion (extractFrame(Cases CsQ)) \<Psi> \<hookrightarrow>\<^sub>F \<langle>\<epsilon>, \<Psi>\<rangle>"
      by(auto simp add: AssertionStatEq_def)
    ultimately have "\<Psi> : (Cases CsQ) \<rhd> Cases CsP \<Longrightarrow>\<alpha> \<prec> P''"
      by(rule weakCase)
    with P''Chain P'RelQ' show ?case by blast
  qed
next
  case(cTau Q')
  from `\<Psi> \<rhd> Cases CsQ \<longmapsto>\<tau> \<prec> Q'` show ?case
  proof(induct rule: caseCases)
    case(cCase \<phi> Q)
    from `(\<phi>, Q) mem CsQ` obtain P where "(\<phi>, P) mem CsP" and "guarded P" and "Eq \<Psi> P Q"
      by(metis PRelQ)
    from `Eq \<Psi> P Q` `\<Psi> \<rhd> Q \<longmapsto>\<tau> \<prec> Q'`
    obtain P' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'" and P'RelQ': "(\<Psi>, P', Q') \<in> Rel"
      by(blast dest: EqSim weakCongSimE)
    from PChain `(\<phi>, P) mem CsP` `\<Psi> \<turnstile> \<phi>` `guarded P` have "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sub>\<tau> P'"
      by(rule tauStepChainCase)
    hence "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'" by(simp add: trancl_into_rtrancl)
    with P'RelQ' show ?case by blast
  qed
qed

lemma weakCongSimCasePres:
  fixes \<Psi>    :: 'b
  and   CsP  :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   Rel  :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   CsQ  :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   M    :: 'a
  and   N    :: 'a

  assumes PRelQ: "\<And>\<phi> Q. (\<phi>, Q) mem CsQ \<Longrightarrow> \<exists>P. (\<phi>, P) mem CsP \<and> guarded P \<and> Eq \<Psi> P Q"
  and     EqSim: "\<And>\<Psi>' P Q. Eq \<Psi>' P Q \<Longrightarrow> \<Psi>' \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"

  shows "\<Psi> \<rhd> Cases CsP \<leadsto>\<guillemotleft>Rel\<guillemotright> Cases CsQ"
proof(induct rule: weakCongSimI)
  case(cTau Q')
  from `\<Psi> \<rhd> Cases CsQ \<longmapsto>\<tau> \<prec> Q'` show ?case
  proof(induct rule: caseCases)
    case(cCase \<phi> Q)
    from `(\<phi>, Q) mem CsQ` obtain P where "(\<phi>, P) mem CsP" and "guarded P" and "Eq \<Psi> P Q"
      by(metis PRelQ)
    from `Eq \<Psi> P Q` `\<Psi> \<rhd> Q \<longmapsto>\<tau> \<prec> Q'`
    obtain P' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'" and P'RelQ': "(\<Psi>, P', Q') \<in> Rel"
      by(blast dest: EqSim weakCongSimE)
    from PChain `(\<phi>, P) mem CsP` `\<Psi> \<turnstile> \<phi>` `guarded P` have "\<Psi> \<rhd> Cases CsP \<Longrightarrow>\<^sub>\<tau> P'"
      by(rule tauStepChainCase)
    with P'RelQ' show ?case by blast
  qed
qed

lemma weakCongSimResPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Rel  :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   Q    :: "('a, 'b, 'c) psi"
  and   x    :: name
  and   Rel' :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"

  assumes PSimQ: "\<Psi> \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"
  and     "eqvt Rel'"
  and     "x \<sharp> \<Psi>"
  and     "Rel \<subseteq> Rel'"
  and     C1: "\<And>\<Psi>' R S x. \<lbrakk>(\<Psi>', R, S) \<in> Rel; x \<sharp> \<Psi>'\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>x\<rparr>R, \<lparr>\<nu>x\<rparr>S) \<in> Rel'"

  shows   "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<leadsto>\<guillemotleft>Rel'\<guillemotright> \<lparr>\<nu>x\<rparr>Q"
proof(induct rule: weakCongSimI)
  case(cTau Q')
  from `\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>Q \<longmapsto>\<tau> \<prec> Q'` have "x \<sharp> Q'" by(auto dest: tauFreshDerivative simp add: abs_fresh) 
  with  `\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>Q \<longmapsto>\<tau> \<prec> Q'` `x \<sharp> \<Psi>` show ?case
  proof(induct rule: resTauCases)
    case(cRes Q')
    from PSimQ `\<Psi> \<rhd> Q \<longmapsto>\<tau> \<prec> Q'` obtain P' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'" and P'RelQ': "(\<Psi>, P', Q') \<in> Rel" 
      by(blast dest: weakCongSimE)
    from PChain `x \<sharp> \<Psi>` have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>x\<rparr>P'" by(rule tauStepChainResPres)
    moreover from P'RelQ' `x \<sharp> \<Psi>` have "(\<Psi>, \<lparr>\<nu>x\<rparr>P', \<lparr>\<nu>x\<rparr>Q') \<in> Rel'" by(rule C1)
    ultimately show ?case by blast
  qed
qed

lemma weakCongSimResChainPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Rel  :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   Q    :: "('a, 'b, 'c) psi"
  and   xvec :: "name list"

  assumes PSimQ: "\<Psi> \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"
  and     "eqvt Rel"
  and     "xvec \<sharp>* \<Psi>"
  and     C1:    "\<And>\<Psi>' R S xvec. \<lbrakk>(\<Psi>', R, S) \<in> Rel; xvec \<sharp>* \<Psi>'\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>R, \<lparr>\<nu>*xvec\<rparr>S) \<in> Rel"

  shows   "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<leadsto>\<guillemotleft>Rel\<guillemotright> \<lparr>\<nu>*xvec\<rparr>Q"
using `xvec \<sharp>* \<Psi>`
proof(induct xvec)
  case Nil
  from PSimQ show ?case by simp
next
  case(Cons x xvec)
  from `(x#xvec) \<sharp>* \<Psi>` have "x \<sharp> \<Psi>" and "xvec \<sharp>* \<Psi>" by simp+
  from `xvec \<sharp>* \<Psi> \<Longrightarrow> \<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<leadsto>\<guillemotleft>Rel\<guillemotright> \<lparr>\<nu>*xvec\<rparr>Q` `xvec \<sharp>* \<Psi>`
  have "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<leadsto>\<guillemotleft>Rel\<guillemotright> \<lparr>\<nu>*xvec\<rparr>Q" by simp
  moreover note `eqvt Rel` `x \<sharp> \<Psi>`
  moreover have "Rel \<subseteq> Rel" by simp
  moreover have "\<And>\<Psi> P Q x. \<lbrakk>(\<Psi>, P, Q) \<in> Rel; x \<sharp> \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>*[x]\<rparr>P, \<lparr>\<nu>*[x]\<rparr>Q) \<in> Rel"
    by(rule_tac xvec="[x]" in C1) auto
  hence "\<And>\<Psi> P Q x. \<lbrakk>(\<Psi>, P, Q) \<in> Rel; x \<sharp> \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> Rel"
    by simp
  ultimately have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>*xvec\<rparr>P) \<leadsto>\<guillemotleft>Rel\<guillemotright> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>*xvec\<rparr>Q)"
    by(rule weakCongSimResPres)
  thus ?case by simp
qed

lemma weakCongSimParPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Rel  :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   Q    :: "('a, 'b, 'c) psi"
  and   R    :: "('a, 'b, 'c) psi"
  and   Rel' :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  
  assumes PSimQ: "\<And>\<Psi>'. \<Psi>' \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"
  and     PSimQ': "\<And>\<Psi>'. \<Psi>' \<rhd> P \<leadsto><Rel> Q"
  and     StatImp: "\<And>\<Psi>'. \<Psi>' \<rhd> Q \<lessapprox><Rel> P"

  and            "eqvt Rel"
  and            "eqvt Rel'"

  and     Sym:    "\<And>\<Psi>' S T. \<lbrakk>(\<Psi>', S, T) \<in> Rel\<rbrakk> \<Longrightarrow> (\<Psi>', T, S) \<in> Rel"
  and     Ext:    "\<And>\<Psi>' S T \<Psi>''. \<lbrakk>(\<Psi>', S, T) \<in> Rel\<rbrakk> \<Longrightarrow> (\<Psi>' \<otimes> \<Psi>'', S, T) \<in> Rel"

  and     C1: "\<And>\<Psi>' S T A\<^isub>U \<Psi>\<^isub>U U. \<lbrakk>(\<Psi>' \<otimes> \<Psi>\<^isub>U, S, T) \<in> Rel; extractFrame U = \<langle>A\<^isub>U, \<Psi>\<^isub>U\<rangle>; A\<^isub>U \<sharp>* \<Psi>'; A\<^isub>U \<sharp>* S; A\<^isub>U \<sharp>* T\<rbrakk> \<Longrightarrow> (\<Psi>', S \<parallel> U, T \<parallel> U) \<in> Rel'"
  and     C2: "\<And>\<Psi>' S T xvec. \<lbrakk>(\<Psi>', S, T) \<in> Rel'; xvec \<sharp>* \<Psi>'\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>S, \<lparr>\<nu>*xvec\<rparr>T) \<in> Rel'"
  and     C3: "\<And>\<Psi>' S T \<Psi>''. \<lbrakk>(\<Psi>', S, T) \<in> Rel; \<Psi>' \<simeq> \<Psi>''\<rbrakk> \<Longrightarrow> (\<Psi>'', S, T) \<in> Rel"

  shows "\<Psi> \<rhd> P \<parallel> R \<leadsto>\<guillemotleft>Rel'\<guillemotright> Q \<parallel> R"
proof(induct rule: weakCongSimI)
  case(cTau QR)
  from `\<Psi> \<rhd> Q \<parallel> R \<longmapsto>\<tau> \<prec> QR` show ?case
  proof(induct rule: parTauCases[where C="(P, R)"])
    case(cPar1 Q' A\<^isub>R \<Psi>\<^isub>R)
    from `A\<^isub>R \<sharp>* (P, R)` have "A\<^isub>R \<sharp>* P"
      by simp+
    have FrR: " extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    with `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<leadsto>\<guillemotleft>Rel\<guillemotright> Q"
      by(rule_tac PSimQ)
    moreover have QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>\<tau> \<prec> Q'" by fact
    ultimately obtain P' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sub>\<tau> P'" and P'RelQ': "(\<Psi> \<otimes> \<Psi>\<^isub>R, P', Q') \<in> Rel"
      by(rule weakCongSimE)
    from PChain QTrans `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` have "A\<^isub>R \<sharp>* P'" and "A\<^isub>R \<sharp>* Q'"
      by(force dest: freeFreshChainDerivative tauStepChainFreshChain)+
    from PChain FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sub>\<tau> (P' \<parallel> R)"
      by(rule tauStepChainPar1)
    moreover from P'RelQ' FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P'` `A\<^isub>R \<sharp>* Q'` have "(\<Psi>, P' \<parallel> R, Q' \<parallel> R) \<in> Rel'" by(rule C1)
    ultimately show ?case by blast
  next
    case(cPar2 R' A\<^isub>Q \<Psi>\<^isub>Q)
    from `A\<^isub>Q \<sharp>* (P, R)` have "A\<^isub>Q \<sharp>* P" and "A\<^isub>Q \<sharp>* R" by simp+
    obtain A\<^isub>P \<Psi>\<^isub>P where FrP: "extractFrame P = \<langle>A\<^isub>P, \<Psi>\<^isub>P\<rangle>" and "A\<^isub>P \<sharp>* (\<Psi>, A\<^isub>Q, \<Psi>\<^isub>Q, R)"
      by(rule freshFrame)
    hence "A\<^isub>P \<sharp>* \<Psi>" and "A\<^isub>P \<sharp>* A\<^isub>Q" and "A\<^isub>P \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P \<sharp>* R"
      by simp+
    
    have FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" by fact
    from `A\<^isub>Q \<sharp>* P` FrP `A\<^isub>P \<sharp>* A\<^isub>Q` have "A\<^isub>Q \<sharp>* \<Psi>\<^isub>P"
      by(drule_tac extractFrameFreshChain) auto
      
    obtain A\<^isub>R \<Psi>\<^isub>R where FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* (\<Psi>, P, Q, A\<^isub>Q, A\<^isub>P, \<Psi>\<^isub>Q, \<Psi>\<^isub>P, R)" and "distinct A\<^isub>R"
      by(rule freshFrame)
    then have "A\<^isub>R \<sharp>* \<Psi>" and "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q" and "A\<^isub>R \<sharp>* A\<^isub>Q" and  "A\<^isub>R \<sharp>* A\<^isub>P" and  "A\<^isub>R \<sharp>* \<Psi>\<^isub>Q" and  "A\<^isub>R \<sharp>* \<Psi>\<^isub>P"
          and "A\<^isub>R \<sharp>* R"
      by simp+
    
    from `A\<^isub>Q \<sharp>* R`  FrR `A\<^isub>R \<sharp>* A\<^isub>Q` have "A\<^isub>Q \<sharp>* \<Psi>\<^isub>R" by(drule_tac extractFrameFreshChain) auto
    from `A\<^isub>P \<sharp>* R` `A\<^isub>R \<sharp>* A\<^isub>P` FrR  have "A\<^isub>P \<sharp>* \<Psi>\<^isub>R" by(drule_tac extractFrameFreshChain) auto
    
    moreover from `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>\<tau> \<prec> R'` FrR `distinct A\<^isub>R` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* R`
    obtain \<Psi>' A\<^isub>R' \<Psi>\<^isub>R' where "\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'" and FrR': "extractFrame R' = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>"
                         and "A\<^isub>R' \<sharp>* \<Psi>" and "A\<^isub>R' \<sharp>* P" and "A\<^isub>R' \<sharp>* Q"
      by(rule_tac C="(\<Psi>, P, Q, R)" in expandTauFrame) (assumption | simp)+

    from FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q`
    obtain P' P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
                    and QimpP': "insertAssertion(extractFrame Q) (\<Psi> \<otimes> \<Psi>\<^isub>R) \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P') (\<Psi> \<otimes> \<Psi>\<^isub>R)"
	            and P'Chain: "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                    and P'RelQ: "((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>', P'', Q) \<in> Rel"
      by(metis StatImp weakStatImp_def Sym)
    obtain A\<^isub>P' \<Psi>\<^isub>P' where FrP': "extractFrame P' = \<langle>A\<^isub>P', \<Psi>\<^isub>P'\<rangle>" and "A\<^isub>P' \<sharp>* \<Psi>" and "A\<^isub>P' \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>P' \<sharp>* \<Psi>\<^isub>Q"
                      and "A\<^isub>P' \<sharp>* A\<^isub>Q" and "A\<^isub>P' \<sharp>* R" and "A\<^isub>P' \<sharp>* A\<^isub>R"
      by(rule_tac C="(\<Psi>, \<Psi>\<^isub>R, \<Psi>\<^isub>Q, A\<^isub>Q, R, A\<^isub>R)" in freshFrame) auto

    from PChain P'Chain `A\<^isub>R \<sharp>* P` `A\<^isub>Q \<sharp>* P` `A\<^isub>R' \<sharp>* P` have "A\<^isub>Q \<sharp>* P'" and "A\<^isub>R \<sharp>* P'" and "A\<^isub>R' \<sharp>* P'" and "A\<^isub>R' \<sharp>* P''"
      by(force intro: tauChainFreshChain)+
    from `A\<^isub>R \<sharp>* P'` `A\<^isub>P' \<sharp>* A\<^isub>R` `A\<^isub>Q \<sharp>* P'` `A\<^isub>P' \<sharp>* A\<^isub>Q` FrP' have "A\<^isub>Q \<sharp>* \<Psi>\<^isub>P'" and "A\<^isub>R \<sharp>* \<Psi>\<^isub>P'"
      by(force dest: extractFrameFreshChain)+
      
    from PChain FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<parallel> R" by(rule tauChainPar1)
    moreover have RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>P' \<rhd> R \<longmapsto>\<tau> \<prec> R'"
    proof -
      have "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>\<tau> \<prec> R'" by fact
      moreover have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P', (\<Psi> \<otimes> \<Psi>\<^isub>P') \<otimes> \<Psi>\<^isub>R\<rangle>"
      proof -
	have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle>"
	  by(metis frameIntAssociativity Commutativity FrameStatEqTrans frameIntCompositionSym FrameStatEqSym)
	moreover with FrP' FrQ QimpP' `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* \<Psi>\<^isub>R` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>R`
	have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P'\<rangle>" using freshCompChain
	  by simp
	moreover have "\<langle>A\<^isub>P', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P'\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P', (\<Psi> \<otimes> \<Psi>\<^isub>P') \<otimes> \<Psi>\<^isub>R\<rangle>"
	  by(metis frameIntAssociativity Commutativity FrameStatEqTrans frameIntCompositionSym frameIntAssociativity[THEN FrameStatEqSym])
	ultimately show ?thesis
	  by(rule FrameStatEqImpCompose)
      qed
      ultimately show ?thesis
	using `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>P'` `A\<^isub>P' \<sharp>* R` `A\<^isub>Q \<sharp>* R` 
              `A\<^isub>P' \<sharp>* A\<^isub>R` `A\<^isub>R \<sharp>* A\<^isub>Q` `A\<^isub>R \<sharp>* \<Psi>\<^isub>P'` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>\<^isub>P'` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>P'` FrR `distinct A\<^isub>R`
	by(force intro: transferTauFrame)
    qed
    hence "\<Psi> \<rhd> P' \<parallel> R \<longmapsto>\<tau> \<prec> (P' \<parallel> R')" using FrP' `A\<^isub>P' \<sharp>* \<Psi>` `A\<^isub>P' \<sharp>* R`
      by(rule_tac Par2) auto
    moreover from P'Chain have "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
      by(metis tauChainStatEq Associativity)
    with `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''" 
      by(rule_tac tauChainStatEq, auto) (metis compositionSym)
    hence "\<Psi> \<rhd> P' \<parallel> R' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<parallel> R'" using FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P'` by(rule_tac tauChainPar1)
    ultimately have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sub>\<tau> (P'' \<parallel> R')"
      by(drule_tac tauActTauStepChain) auto
    
    moreover from P'RelQ `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "(\<Psi> \<otimes> \<Psi>\<^isub>R', P'', Q) \<in> Rel" by(blast intro: C3 Associativity compositionSym)
    with FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P''` `A\<^isub>R' \<sharp>* Q` have "(\<Psi>, P'' \<parallel> R', Q \<parallel> R') \<in> Rel'" by(rule_tac C1) 
    ultimately show ?case by blast
  next
    case(cComm1 \<Psi>\<^isub>R M N Q' A\<^isub>Q \<Psi>\<^isub>Q K xvec R' A\<^isub>R)
    have  FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" by fact
    from `A\<^isub>Q \<sharp>* (P, R)` have "A\<^isub>Q \<sharp>* P" and "A\<^isub>Q \<sharp>* R" by simp+
    
    have  FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    from `A\<^isub>R \<sharp>* (P, R)` have "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* R" by simp+
    from `xvec \<sharp>* (P, R)` have "xvec \<sharp>* P" and "xvec \<sharp>* R" by simp+
    
    have QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>M\<lparr>N\<rparr> \<prec> Q'" and RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> R'"
      and MeqK: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<otimes> \<Psi>\<^isub>R \<turnstile> M \<leftrightarrow>K" by fact+

    from RTrans FrR `distinct A\<^isub>R` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* xvec` `xvec \<sharp>* R` `xvec \<sharp>* Q` `xvec \<sharp>* \<Psi>` `xvec \<sharp>* \<Psi>\<^isub>Q` `A\<^isub>R \<sharp>* Q`
                    `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* \<Psi>\<^isub>Q` `xvec \<sharp>* K` `A\<^isub>R \<sharp>* K` `A\<^isub>R \<sharp>* R` `xvec \<sharp>* R` `A\<^isub>R \<sharp>* P` `xvec \<sharp>* P`
                     `A\<^isub>Q \<sharp>* A\<^isub>R` `A\<^isub>Q \<sharp>* xvec` `A\<^isub>R \<sharp>* K` `A\<^isub>R \<sharp>* N` `xvec \<sharp>* K` `distinct xvec`
    obtain p \<Psi>' A\<^isub>R' \<Psi>\<^isub>R' where S: "set p \<subseteq> set xvec \<times> set(p \<bullet> xvec)" and FrR': "extractFrame R' = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>"
                           and "(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'" and "A\<^isub>R' \<sharp>* Q" and "A\<^isub>R' \<sharp>* \<Psi>" and "(p \<bullet> xvec) \<sharp>* \<Psi>"
                           and "(p \<bullet> xvec) \<sharp>* Q" and "(p \<bullet> xvec) \<sharp>* \<Psi>\<^isub>Q" and "(p \<bullet> xvec) \<sharp>* K" and "(p \<bullet> xvec) \<sharp>* R"
                           and "(p \<bullet> xvec) \<sharp>* P" and "(p \<bullet> xvec) \<sharp>* A\<^isub>Q" and "A\<^isub>R' \<sharp>* P" and "A\<^isub>R' \<sharp>* N"
      by(rule_tac C="(\<Psi>, Q, \<Psi>\<^isub>Q, K, R, P, A\<^isub>Q)"  and C'="(\<Psi>, Q, \<Psi>\<^isub>Q, K, R, P, A\<^isub>Q)" in expandFrame) (assumption | simp)+

    from `A\<^isub>R \<sharp>* \<Psi>` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> \<Psi>)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
    with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S have "(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>" by simp
    from `A\<^isub>R \<sharp>* P` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> P)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
    with `xvec \<sharp>* P` `(p \<bullet> xvec) \<sharp>* P` S have "(p \<bullet> A\<^isub>R) \<sharp>* P" by simp
    from `A\<^isub>R \<sharp>* Q` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> Q)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
    with `xvec \<sharp>* Q` `(p \<bullet> xvec) \<sharp>* Q` S have "(p \<bullet> A\<^isub>R) \<sharp>* Q" by simp
    from `A\<^isub>R \<sharp>* R` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> R)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
    with `xvec \<sharp>* R` `(p \<bullet> xvec) \<sharp>* R` S have "(p \<bullet> A\<^isub>R) \<sharp>* R" by simp
    from `A\<^isub>R \<sharp>* K` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> K)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
    with `xvec \<sharp>* K` `(p \<bullet> xvec) \<sharp>* K` S have "(p \<bullet> A\<^isub>R) \<sharp>* K" by simp
    
    from `A\<^isub>Q \<sharp>* xvec` `(p \<bullet> xvec) \<sharp>* A\<^isub>Q` `A\<^isub>Q \<sharp>* M` S have "A\<^isub>Q \<sharp>* (p \<bullet> M)" by(simp add: freshChainSimps)
    from `A\<^isub>Q \<sharp>* xvec` `(p \<bullet> xvec) \<sharp>* A\<^isub>Q` `A\<^isub>Q \<sharp>* A\<^isub>R` S have "A\<^isub>Q \<sharp>* (p \<bullet> A\<^isub>R)" by(simp add: freshChainSimps)
    
    from QTrans S `xvec \<sharp>* Q` `(p \<bullet> xvec) \<sharp>* Q` have "(p \<bullet> (\<Psi> \<otimes> \<Psi>\<^isub>R)) \<rhd> Q \<longmapsto> (p \<bullet> M)\<lparr>N\<rparr> \<prec> Q'"
      by(rule_tac inputPermFrameSubject) (assumption | auto simp add: fresh_star_def)+
    with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S have QTrans: "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<rhd> Q \<longmapsto> (p \<bullet> M)\<lparr>N\<rparr> \<prec> Q'"
      by(simp add: eqvts)
    from FrR have "(p \<bullet> extractFrame R) = p \<bullet> \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by simp
    with `xvec \<sharp>* R` `(p \<bullet> xvec) \<sharp>* R` S have FrR: "extractFrame R = \<langle>(p \<bullet> A\<^isub>R), (p \<bullet> \<Psi>\<^isub>R)\<rangle>"
      by(simp add: eqvts)
    
    from MeqK have "(p \<bullet> (\<Psi> \<otimes> \<Psi>\<^isub>Q \<otimes> \<Psi>\<^isub>R)) \<turnstile> (p \<bullet> M) \<leftrightarrow> (p \<bullet> K)" by(rule chanEqClosed)
    with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` `xvec \<sharp>* \<Psi>\<^isub>Q` `(p \<bullet> xvec) \<sharp>* \<Psi>\<^isub>Q` `xvec \<sharp>* K` `(p \<bullet> xvec) \<sharp>* K` S
    have MeqK: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<turnstile> (p \<bullet> M) \<leftrightarrow> K" by(simp add: eqvts)
    
    have "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P \<leadsto><Rel> Q" by(rule PSimQ')

    with QTrans obtain P' P'' where PTrans: "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) : Q \<rhd> P \<Longrightarrow>(p \<bullet> M)\<lparr>N\<rparr> \<prec> P''"
                                and P''Chain: "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>' \<rhd> P'' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
                                and P'RelQ': "((\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>', P', Q') \<in> Rel"
      by(fastsimp dest: weakSimE)
    from PTrans QTrans `A\<^isub>R' \<sharp>* P` `A\<^isub>R' \<sharp>* Q` `A\<^isub>R' \<sharp>* N` have "A\<^isub>R' \<sharp>* P''" and "A\<^isub>R' \<sharp>* Q'"
      by(blast dest: weakInputFreshChainDerivative inputFreshChainDerivative)+

    from PTrans obtain P''' where PChain: "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'''"
                              and QimpP''': "insertAssertion (extractFrame Q) (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P''') (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R))"
                              and P'''Trans: "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P''' \<longmapsto>(p \<bullet> M)\<lparr>N\<rparr> \<prec> P''"
      by(rule weakTransitionE)
    
    from PChain `xvec \<sharp>* P` `(p \<bullet> A\<^isub>R) \<sharp>* P` `A\<^isub>R' \<sharp>* P` have "xvec \<sharp>* P'''" and "(p \<bullet> A\<^isub>R) \<sharp>* P'''" and "A\<^isub>R' \<sharp>* P'''"
      by(force intro: tauChainFreshChain)+
    from P'''Trans `A\<^isub>R' \<sharp>* P'''` `A\<^isub>R' \<sharp>* N` have "A\<^isub>R' \<sharp>* P''" by(force dest: inputFreshChainDerivative)
    
    obtain A\<^isub>P''' \<Psi>\<^isub>P''' where FrP''': "extractFrame P''' = \<langle>A\<^isub>P''', \<Psi>\<^isub>P'''\<rangle>" and "A\<^isub>P''' \<sharp>* (\<Psi>, A\<^isub>Q, \<Psi>\<^isub>Q, p \<bullet> A\<^isub>R, p \<bullet> \<Psi>\<^isub>R, p \<bullet> M, N, K, R, P''', xvec)" and "distinct A\<^isub>P'''"
      by(rule freshFrame)
    hence "A\<^isub>P''' \<sharp>* \<Psi>" and "A\<^isub>P''' \<sharp>* A\<^isub>Q" and "A\<^isub>P''' \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P''' \<sharp>* (p \<bullet> M)" and "A\<^isub>P''' \<sharp>* R"
      and "A\<^isub>P''' \<sharp>* N" and "A\<^isub>P''' \<sharp>* K" and "A\<^isub>P''' \<sharp>* (p \<bullet> A\<^isub>R)" and "A\<^isub>P''' \<sharp>* P'''" and "A\<^isub>P''' \<sharp>* xvec" and "A\<^isub>P''' \<sharp>* (p \<bullet> \<Psi>\<^isub>R)"
      by simp+

    have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> (p \<bullet> \<Psi>\<^isub>R)\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q, (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>\<^isub>Q\<rangle>" 
      by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
    moreover with QimpP''' FrP''' FrQ `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* (p \<bullet> \<Psi>\<^isub>R)` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>R` `A\<^isub>Q \<sharp>* xvec` `(p \<bullet> xvec) \<sharp>* A\<^isub>Q` S
    have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>\<^isub>P'''\<rangle>" using freshCompChain
      by(simp add: freshChainSimps)
    moreover have "\<langle>A\<^isub>P''', (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>\<^isub>P'''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>P''') \<otimes> (p \<bullet> \<Psi>\<^isub>R)\<rangle>"
      by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
    ultimately have QImpP''': "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> (p \<bullet> \<Psi>\<^isub>R)\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>P''') \<otimes> (p \<bullet> \<Psi>\<^isub>R)\<rangle>"
      by(rule FrameStatEqImpCompose)
      
    from PChain FrR `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R) \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''' \<parallel> R" by(rule tauChainPar1)
    moreover from RTrans FrR P'''Trans MeqK QImpP''' FrP''' FrQ `distinct A\<^isub>P'''` `distinct A\<^isub>R` `A\<^isub>P''' \<sharp>* (p \<bullet> A\<^isub>R)` `A\<^isub>Q \<sharp>* (p \<bullet> A\<^isub>R)`
      `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R) \<sharp>* P'''` `(p \<bullet> A\<^isub>R) \<sharp>* Q` `(p \<bullet> A\<^isub>R) \<sharp>* R` `(p \<bullet> A\<^isub>R) \<sharp>* K` `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* R`
      `A\<^isub>P''' \<sharp>* P'''` `A\<^isub>P''' \<sharp>* (p \<bullet> M)` `A\<^isub>Q \<sharp>* R`  `A\<^isub>Q \<sharp>* (p \<bullet> M)` 
    obtain K' where "\<Psi> \<otimes> \<Psi>\<^isub>P''' \<rhd> R \<longmapsto>K'\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> R'" and "\<Psi> \<otimes> \<Psi>\<^isub>P''' \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<turnstile> (p \<bullet> M) \<leftrightarrow> K'" and "(p \<bullet> A\<^isub>R) \<sharp>* K'"
      by(rule_tac comm1Aux) (assumption | simp)+
    
    with P'''Trans FrP''' have "\<Psi> \<rhd> P''' \<parallel> R \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P'' \<parallel> R')" using FrR `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R) \<sharp>* P'''` `(p \<bullet> A\<^isub>R) \<sharp>* R`
      `xvec \<sharp>* P'''` `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* P'''` `A\<^isub>P''' \<sharp>* R` `A\<^isub>P''' \<sharp>* (p \<bullet> M)` `(p \<bullet> A\<^isub>R) \<sharp>* K'` `A\<^isub>P''' \<sharp>* (p \<bullet> A\<^isub>R)`
      by(rule_tac Comm1)
    
    moreover from P''Chain `A\<^isub>R' \<sharp>* P''` have "A\<^isub>R' \<sharp>* P'" by(rule tauChainFreshChain)
    from `(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>' \<simeq> \<Psi> \<otimes> \<Psi>\<^isub>R'"
      by(metis Associativity AssertionStatEqTrans AssertionStatEqSym compositionSym)
    with P''Chain have "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P'' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'" by(rule tauChainStatEq)
    hence "\<Psi> \<rhd> P'' \<parallel> R' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<parallel> R'" using FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P''` by(rule tauChainPar1)
    hence "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P'' \<parallel> R') \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R')" using `xvec \<sharp>* \<Psi>` by(rule tauChainResChainPres)
    ultimately have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R')"
      by(drule_tac tauActTauStepChain) auto
    moreover from P'RelQ' `(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "(\<Psi> \<otimes> \<Psi>\<^isub>R', P', Q') \<in> Rel"  by(metis C3 Associativity compositionSym)
    with FrR' `A\<^isub>R' \<sharp>* P'` `A\<^isub>R' \<sharp>* Q'` `A\<^isub>R' \<sharp>* \<Psi>` have "(\<Psi>, P' \<parallel> R', Q' \<parallel> R') \<in> Rel'" by(rule_tac C1)
    with `xvec \<sharp>* \<Psi>` have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R'), \<lparr>\<nu>*xvec\<rparr>(Q' \<parallel> R')) \<in> Rel'"
      by(rule_tac C2)
    ultimately show ?case by blast
  next
    case(cComm2 \<Psi>\<^isub>R M xvec N Q' A\<^isub>Q \<Psi>\<^isub>Q K R' A\<^isub>R)
    have  FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" by fact
    from `A\<^isub>Q \<sharp>* (P, R)` have "A\<^isub>Q \<sharp>* P" and "A\<^isub>Q \<sharp>* R" by simp+
    
    have  FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    from `A\<^isub>R \<sharp>* (P, R)` have "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* R" by simp+
    from `xvec \<sharp>* (P, R)` have "xvec \<sharp>* P" and "xvec \<sharp>* R" by simp+
    
    have QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q'" and RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>K\<lparr>N\<rparr> \<prec> R'"
     and MeqK: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<otimes> \<Psi>\<^isub>R \<turnstile> M \<leftrightarrow>K" by fact+

    from RTrans FrR `distinct A\<^isub>R` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* Q'` `A\<^isub>R \<sharp>* N` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* xvec` `A\<^isub>R \<sharp>* K`
    obtain \<Psi>' A\<^isub>R' \<Psi>\<^isub>R' where  ReqR': "\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'" and FrR': "extractFrame R' = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>" 
                         and "A\<^isub>R' \<sharp>* \<Psi>" and "A\<^isub>R' \<sharp>* P" and "A\<^isub>R' \<sharp>* Q'" and "A\<^isub>R' \<sharp>* N" and "A\<^isub>R' \<sharp>* xvec"
      by(rule_tac C="(\<Psi>, P, Q', N, xvec)" and C'="(\<Psi>, P, Q', N, xvec)" in expandFrame) auto
    
    have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<leadsto><Rel> Q" by(rule PSimQ')
    
    with QTrans `xvec \<sharp>* \<Psi>` `xvec \<sharp>* \<Psi>\<^isub>R` `xvec \<sharp>* P`
    obtain P'' P' where PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R : Q \<rhd> P \<Longrightarrow>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P''"
                    and P''Chain: "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<rhd> P'' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
                    and P'RelQ': "((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>', P', Q') \<in> Rel"
      by(fastsimp dest: weakSimE)

    from PTrans obtain P''' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'''"
                              and QimpP''': "insertAssertion (extractFrame Q) (\<Psi> \<otimes> \<Psi>\<^isub>R) \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P''') (\<Psi> \<otimes> \<Psi>\<^isub>R)"
                              and P'''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P''' \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P''"
      by(rule weakTransitionE)
      
    from PChain `A\<^isub>R \<sharp>* P` have "A\<^isub>R \<sharp>* P'''" by(rule tauChainFreshChain)

    obtain A\<^isub>P''' \<Psi>\<^isub>P''' where FrP''': "extractFrame P''' = \<langle>A\<^isub>P''', \<Psi>\<^isub>P'''\<rangle>" and "A\<^isub>P''' \<sharp>* (\<Psi>, A\<^isub>Q, \<Psi>\<^isub>Q, A\<^isub>R, \<Psi>\<^isub>R, M, N, K, R, P''', xvec)" and "distinct A\<^isub>P'''"
      by(rule freshFrame)
    hence "A\<^isub>P''' \<sharp>* \<Psi>" and "A\<^isub>P''' \<sharp>* A\<^isub>Q" and "A\<^isub>P''' \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>P''' \<sharp>* M" and "A\<^isub>P''' \<sharp>* R"
      and "A\<^isub>P''' \<sharp>* N" and "A\<^isub>P''' \<sharp>* K" and "A\<^isub>P''' \<sharp>* A\<^isub>R" and "A\<^isub>P''' \<sharp>* P'''" and "A\<^isub>P''' \<sharp>* xvec" and "A\<^isub>P''' \<sharp>* \<Psi>\<^isub>R"
      by simp+

    have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle>" 
      by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
    moreover with QimpP''' FrP''' FrQ `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>Q \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* \<Psi>\<^isub>R` `A\<^isub>Q \<sharp>* \<Psi>\<^isub>R`
    have "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P'''\<rangle>" using freshCompChain
      by simp
    moreover have "\<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P'''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>P''') \<otimes> \<Psi>\<^isub>R\<rangle>"
      by(metis frameResChainPres frameNilStatEq Commutativity AssertionStatEqTrans Composition Associativity)
    ultimately have QImpP''': "\<langle>A\<^isub>Q, (\<Psi> \<otimes> \<Psi>\<^isub>Q) \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P''', (\<Psi> \<otimes> \<Psi>\<^isub>P''') \<otimes> \<Psi>\<^isub>R\<rangle>"
      by(rule FrameStatEqImpCompose)

    from PChain FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''' \<parallel> R" by(rule tauChainPar1)
    moreover from RTrans FrR P'''Trans MeqK QImpP''' FrP''' FrQ `distinct A\<^isub>P'''` `distinct A\<^isub>R` `A\<^isub>P''' \<sharp>* A\<^isub>R` `A\<^isub>Q \<sharp>* A\<^isub>R`
      `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P'''` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* K` `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* R`
      `A\<^isub>P''' \<sharp>* P'''` `A\<^isub>P''' \<sharp>* M` `A\<^isub>Q \<sharp>* R`  `A\<^isub>Q \<sharp>* M` `A\<^isub>R \<sharp>* xvec` `xvec \<sharp>* M`
    obtain K' where "\<Psi> \<otimes> \<Psi>\<^isub>P''' \<rhd> R \<longmapsto>K'\<lparr>N\<rparr> \<prec> R'" and "\<Psi> \<otimes> \<Psi>\<^isub>P''' \<otimes> \<Psi>\<^isub>R \<turnstile> M \<leftrightarrow> K'" and "A\<^isub>R \<sharp>* K'"
      by(rule_tac comm2Aux) (assumption | simp)+
    
    with P'''Trans FrP''' have "\<Psi> \<rhd> P''' \<parallel> R \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(P'' \<parallel> R')" using FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P'''` `A\<^isub>R \<sharp>* R`
      `xvec \<sharp>* R` `A\<^isub>P''' \<sharp>* \<Psi>` `A\<^isub>P''' \<sharp>* P'''` `A\<^isub>P''' \<sharp>* R` `A\<^isub>P''' \<sharp>* M` `A\<^isub>R \<sharp>* K'` `A\<^isub>P''' \<sharp>* A\<^isub>R`
      by(rule_tac Comm2)
    moreover from P'''Trans `A\<^isub>R \<sharp>* P'''` `A\<^isub>R \<sharp>* xvec` `xvec \<sharp>* M` `distinct xvec` have "A\<^isub>R \<sharp>* P''"
      by(rule_tac outputFreshChainDerivative) auto

    from PChain `A\<^isub>R' \<sharp>* P` have "A\<^isub>R' \<sharp>* P'''" by(rule tauChainFreshChain)
    with P'''Trans `xvec \<sharp>* M` `distinct xvec` have "A\<^isub>R' \<sharp>* P''" using `A\<^isub>R' \<sharp>* xvec`
      by(rule_tac outputFreshChainDerivative) auto
    
    with P''Chain have "A\<^isub>R' \<sharp>* P'" by(rule tauChainFreshChain)
    from `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi> \<otimes> \<Psi>\<^isub>R'"
      by(metis Associativity AssertionStatEqTrans AssertionStatEqSym compositionSym)
    with P''Chain have "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P'' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'" by(rule tauChainStatEq)
    hence "\<Psi> \<rhd> P'' \<parallel> R' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<parallel> R'" using FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P''` 
      by(rule tauChainPar1)
    hence "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P'' \<parallel> R') \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R')" 
      using `xvec \<sharp>* \<Psi>` by(rule tauChainResChainPres)
    ultimately have "\<Psi> \<rhd> P \<parallel> R \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R')" by(drule_tac tauActTauStepChain) auto
    moreover from P'RelQ' `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'` have "(\<Psi> \<otimes> \<Psi>\<^isub>R', P', Q') \<in> Rel"  by(metis C3 Associativity compositionSym)
    with FrR' `A\<^isub>R' \<sharp>* P'` `A\<^isub>R' \<sharp>* Q'` `A\<^isub>R' \<sharp>* \<Psi>` have "(\<Psi>, P' \<parallel> R', Q' \<parallel> R') \<in> Rel'" by(rule_tac C1)
    with `xvec \<sharp>* \<Psi>` have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P' \<parallel> R'), \<lparr>\<nu>*xvec\<rparr>(Q' \<parallel> R')) \<in> Rel'"
      by(rule_tac C2)
    ultimately show ?case by blast
  qed
qed
no_notation relcomp (infixr "O" 75)

lemma weakCongSimBangPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   Rel :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   Rel' :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"
  and   Rel'' :: "('b \<times> ('a, 'b, 'c) psi \<times> ('a, 'b, 'c) psi) set"

  assumes PEqQ:   "Eq P Q"
  and     PRelQ: "(\<Psi>, P, Q) \<in> Rel"
  and     "guarded P"
  and     "guarded Q"
  and     Rel'Rel: "Rel' \<subseteq> Rel"
  and     FrameParPres: "\<And>\<Psi>' \<Psi>\<^isub>U S T U A\<^isub>U. \<lbrakk>(\<Psi>' \<otimes> \<Psi>\<^isub>U, S, T) \<in> Rel; extractFrame U = \<langle>A\<^isub>U, \<Psi>\<^isub>U\<rangle>; A\<^isub>U \<sharp>* \<Psi>'; A\<^isub>U \<sharp>* S; A\<^isub>U \<sharp>* T\<rbrakk> \<Longrightarrow>
                                            (\<Psi>', U \<parallel> S, U \<parallel> T) \<in> Rel"
  and     C1: "\<And>\<Psi>' S T U. \<lbrakk>(\<Psi>', S, T) \<in> Rel; guarded S; guarded T\<rbrakk> \<Longrightarrow> (\<Psi>', U \<parallel> !S, U \<parallel> !T) \<in> Rel''"
  and     Closed: "\<And>\<Psi>' S T p. (\<Psi>', S, T) \<in> Rel \<Longrightarrow> ((p::name prm) \<bullet> \<Psi>', p \<bullet> S, p \<bullet> T) \<in> Rel"
  and     Closed': "\<And>\<Psi>' S T p. (\<Psi>', S, T) \<in> Rel' \<Longrightarrow> ((p::name prm) \<bullet> \<Psi>', p \<bullet> S, p \<bullet> T) \<in> Rel'"
  and     StatEq: "\<And>\<Psi>' S T \<Psi>''. \<lbrakk>(\<Psi>', S, T) \<in> Rel; \<Psi>' \<simeq> \<Psi>''\<rbrakk> \<Longrightarrow> (\<Psi>'', S, T) \<in> Rel"
  and     StatEq': "\<And>\<Psi>' S T \<Psi>''. \<lbrakk>(\<Psi>', S, T) \<in> Rel'; \<Psi>' \<simeq> \<Psi>''\<rbrakk> \<Longrightarrow> (\<Psi>'', S, T) \<in> Rel'"
  and     Trans: "\<And>\<Psi>' S T U. \<lbrakk>(\<Psi>', S, T) \<in> Rel; (\<Psi>', T, U) \<in> Rel\<rbrakk> \<Longrightarrow> (\<Psi>', S, U) \<in> Rel"
  and     Trans': "\<And>\<Psi>' S T U. \<lbrakk>(\<Psi>', S, T) \<in> Rel'; (\<Psi>', T, U) \<in> Rel'\<rbrakk> \<Longrightarrow> (\<Psi>', S, U) \<in> Rel'"
  and     EqSim: "\<And>\<Psi>' S T. Eq S T \<Longrightarrow> \<Psi>' \<rhd> S \<leadsto>\<guillemotleft>Rel\<guillemotright> T"
  and     cSim: "\<And>\<Psi>' S T. (\<Psi>', S, T) \<in> Rel \<Longrightarrow> \<Psi>' \<rhd> S \<leadsto><Rel> T"
  and     cSym: "\<And>\<Psi>' S T. (\<Psi>', S, T) \<in> Rel \<Longrightarrow> (\<Psi>', T, S) \<in> Rel"
  and     cSym': "\<And>\<Psi>' S T. (\<Psi>', S, T) \<in> Rel' \<Longrightarrow> (\<Psi>', T, S) \<in> Rel'"
  and     cExt: "\<And>\<Psi>' S T \<Psi>''. (\<Psi>', S, T) \<in> Rel \<Longrightarrow> (\<Psi>' \<otimes> \<Psi>'', S, T) \<in> Rel"
  and     cExt': "\<And>\<Psi>' S T \<Psi>''. (\<Psi>', S, T) \<in> Rel' \<Longrightarrow> (\<Psi>' \<otimes> \<Psi>'', S, T) \<in> Rel'"
  and     ParPres: "\<And>\<Psi>' S T U. (\<Psi>', S, T) \<in> Rel \<Longrightarrow> (\<Psi>', S \<parallel> U, T \<parallel> U) \<in> Rel"
  and     ParPres': "\<And>\<Psi>' S T U. (\<Psi>', S, T) \<in> Rel' \<Longrightarrow> (\<Psi>', U \<parallel> S, U \<parallel> T) \<in> Rel'"
  and     ParPres2: "\<And>\<Psi>' S T. Eq S T \<Longrightarrow> Eq (S \<parallel> S) (T \<parallel> T)"
  and     ResPres: "\<And>\<Psi>' S T xvec. \<lbrakk>(\<Psi>', S, T) \<in> Rel; xvec \<sharp>* \<Psi>'\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>S, \<lparr>\<nu>*xvec\<rparr>T) \<in> Rel"
  and     ResPres': "\<And>\<Psi>' S T xvec. \<lbrakk>(\<Psi>', S, T) \<in> Rel'; xvec \<sharp>* \<Psi>'\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>S, \<lparr>\<nu>*xvec\<rparr>T) \<in> Rel'"
  and     Assoc: "\<And>\<Psi>' S T U. (\<Psi>', S \<parallel> (T \<parallel> U), (S \<parallel> T) \<parallel> U) \<in> Rel"
  and     Assoc': "\<And>\<Psi>' S T U. (\<Psi>', S \<parallel> (T \<parallel> U), (S \<parallel> T) \<parallel> U) \<in> Rel'"
  and     ScopeExt: "\<And>xvec \<Psi>' T S. \<lbrakk>xvec \<sharp>* \<Psi>'; xvec \<sharp>* T\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>(S \<parallel> T), (\<lparr>\<nu>*xvec\<rparr>S) \<parallel> T) \<in> Rel"
  and     ScopeExt': "\<And>xvec \<Psi>' T S. \<lbrakk>xvec \<sharp>* \<Psi>'; xvec \<sharp>* T\<rbrakk> \<Longrightarrow> (\<Psi>', \<lparr>\<nu>*xvec\<rparr>(S \<parallel> T), (\<lparr>\<nu>*xvec\<rparr>S) \<parallel> T) \<in> Rel'"
  and     Compose: "\<And>\<Psi>' S T U O. \<lbrakk>(\<Psi>', S, T) \<in> Rel; (\<Psi>', T, U) \<in> Rel''; (\<Psi>', U, O) \<in> Rel'\<rbrakk> \<Longrightarrow> (\<Psi>', S, O) \<in> Rel''"
  and     rBangActE: "\<And>\<Psi>' S \<alpha> S'. \<lbrakk>\<Psi>' \<rhd> !S \<longmapsto>\<alpha> \<prec> S'; guarded S; bn \<alpha> \<sharp>* S; \<alpha> \<noteq> \<tau>; bn \<alpha> \<sharp>* subject \<alpha>\<rbrakk> \<Longrightarrow> \<exists>T. \<Psi>' \<rhd> S \<longmapsto>\<alpha> \<prec> T \<and> (\<one>, S', T \<parallel> !S) \<in> Rel'"
  and     rBangTauE: "\<And>\<Psi>' S S'. \<lbrakk>\<Psi>' \<rhd> !S \<longmapsto>\<tau> \<prec> S'; guarded S\<rbrakk> \<Longrightarrow> \<exists>T. \<Psi>' \<rhd> S \<parallel> S \<longmapsto>\<tau> \<prec> T \<and> (\<one>, S', T \<parallel> !S) \<in> Rel'"
  and     rBangTauI: "\<And>\<Psi>' S S'. \<lbrakk>\<Psi>' \<rhd> S \<parallel> S \<Longrightarrow>\<^sub>\<tau> S'; guarded S\<rbrakk> \<Longrightarrow> \<exists>T. \<Psi>' \<rhd> !S \<Longrightarrow>\<^sub>\<tau> T \<and> (\<Psi>', T, S' \<parallel> !S) \<in> Rel'"
  shows "\<Psi> \<rhd> R \<parallel> !P \<leadsto>\<guillemotleft>Rel''\<guillemotright> R \<parallel> !Q"
proof(induct rule: weakCongSimI)
  case(cTau RQ')
  from `\<Psi> \<rhd> R \<parallel> !Q \<longmapsto>\<tau> \<prec> RQ'` show ?case
  proof(induct rule: parTauCases[where C="(P, Q, R)"])
    case(cPar1 R' A\<^isub>Q \<Psi>\<^isub>Q)
    from `extractFrame (!Q) = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>` have "A\<^isub>Q = []" and "\<Psi>\<^isub>Q = SBottom'" by simp+
    with `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>\<tau> \<prec> R'` `\<Psi>\<^isub>Q = SBottom'`
    have "\<Psi> \<rhd> R \<parallel> !P \<longmapsto>\<tau> \<prec> (R' \<parallel> !P)" by(rule_tac Par1) (assumption | simp)+
    hence "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> R' \<parallel> !P" by auto
    moreover from `(\<Psi>, P, Q) \<in> Rel` have "(\<Psi>, R' \<parallel> !P, R' \<parallel> !Q) \<in> Rel''" using `guarded P` `guarded Q` 
      by(rule C1)
    ultimately show ?case by blast
  next
    case(cPar2 Q' A\<^isub>R \<Psi>\<^isub>R)
    from `A\<^isub>R \<sharp>* (P, Q, R)` have "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q" and "A\<^isub>R \<sharp>* R" by simp+
    have FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    
    obtain A\<^isub>Q \<Psi>\<^isub>Q where FrQ: "extractFrame Q = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" and "A\<^isub>Q \<sharp>* \<Psi>" and "A\<^isub>Q \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>Q \<sharp>* A\<^isub>R"
      by(rule_tac C="(\<Psi>, \<Psi>\<^isub>R, A\<^isub>R)" in freshFrame) auto
    from FrQ `guarded Q` have "\<Psi>\<^isub>Q \<simeq> \<one>" and "supp \<Psi>\<^isub>Q = ({}::name set)" by(blast dest: guardedStatEq)+
    hence "A\<^isub>R \<sharp>* \<Psi>\<^isub>Q" and "A\<^isub>Q \<sharp>* \<Psi>\<^isub>Q" by(auto simp add: fresh_star_def fresh_def)

    from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !Q \<longmapsto>\<tau> \<prec> Q'` `guarded Q` 
    obtain T where QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<parallel> Q \<longmapsto>\<tau> \<prec> T" and "(\<one>, Q', T \<parallel> !Q) \<in> Rel'" 
      by(blast dest: rBangTauE)
    
    from `Eq P Q` have "Eq (P \<parallel> P) (Q \<parallel> Q)" by(rule ParPres2)
    with QTrans 
    obtain S where PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<parallel> P \<Longrightarrow>\<^sub>\<tau> S" and SRelT: "(\<Psi> \<otimes> \<Psi>\<^isub>R, S, T) \<in> Rel"
      by(blast dest: EqSim weakCongSimE)
    from PTrans `guarded P` obtain U where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<Longrightarrow>\<^sub>\<tau> U" and "(\<Psi> \<otimes> \<Psi>\<^isub>R, U, S \<parallel> !P) \<in> Rel'"
      by(blast dest: rBangTauI)
    from PChain `A\<^isub>R \<sharp>* P` have "A\<^isub>R \<sharp>* U" by(force dest: tauStepChainFreshChain)
    from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<Longrightarrow>\<^sub>\<tau> U` FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` have "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> R \<parallel> U"
      by(rule_tac tauStepChainPar2) auto
    moreover from PTrans `A\<^isub>R \<sharp>* P` have "A\<^isub>R \<sharp>* S" by(force dest: tauStepChainFreshChain)
    from QTrans `A\<^isub>R \<sharp>* Q` have "A\<^isub>R \<sharp>* T" by(force dest: tauFreshChainDerivative)
    have "(\<Psi>, R \<parallel> U, R \<parallel> Q') \<in> Rel''"
    proof -
      from `(\<Psi> \<otimes> \<Psi>\<^isub>R, U, S \<parallel> !P) \<in> Rel'` Rel'Rel have "(\<Psi> \<otimes> \<Psi>\<^isub>R, U, S \<parallel> !P) \<in> Rel"
	by auto
      hence "(\<Psi>, R \<parallel> U, R \<parallel> (S \<parallel> !P)) \<in> Rel" using FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* U` `A\<^isub>R \<sharp>* S` `A\<^isub>R \<sharp>* P`
	by(rule_tac FrameParPres) auto

      moreover from `(\<Psi> \<otimes> \<Psi>\<^isub>R, S, T) \<in> Rel` FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* S` `A\<^isub>R \<sharp>* T` have "(\<Psi>, R \<parallel> S, R \<parallel> T) \<in> Rel"
	by(rule_tac FrameParPres) auto
      hence "(\<Psi>, R \<parallel> T, R \<parallel> S) \<in> Rel" by(rule cSym)
      hence "(\<Psi>, (R \<parallel> T) \<parallel> !P, (R \<parallel> S) \<parallel> !P) \<in> Rel" by(rule ParPres)
      hence "(\<Psi>, (R \<parallel> S) \<parallel> !P, (R \<parallel> T) \<parallel> !P) \<in> Rel" by(rule cSym)
      hence "(\<Psi>, R \<parallel> (S \<parallel> !P), (R \<parallel> T) \<parallel> !P) \<in> Rel" by(metis Trans Assoc)
      ultimately have "(\<Psi>, R \<parallel> U, (R \<parallel> T) \<parallel> !P) \<in> Rel" by(rule Trans)
      moreover from `(\<Psi>, P, Q) \<in> Rel` have "(\<Psi>, (R \<parallel> T) \<parallel> !P, (R \<parallel> T) \<parallel> !Q) \<in> Rel''" using `guarded P` `guarded Q` by(rule C1)
      moreover from `(\<one>, Q', T \<parallel> !Q) \<in> Rel'` have "(\<one> \<otimes> \<Psi>, Q', T \<parallel> !Q) \<in> Rel'" by(rule cExt')
      hence "(\<Psi>, Q', T \<parallel> !Q) \<in> Rel'" 
	by(rule StatEq') (metis Identity AssertionStatEqSym Commutativity AssertionStatEqTrans)
      hence "(\<Psi>, R \<parallel> Q', R \<parallel> (T \<parallel> !Q)) \<in> Rel'" by(rule ParPres')
      hence "(\<Psi>, R \<parallel> Q', (R \<parallel> T) \<parallel> !Q) \<in> Rel'" by(metis Trans' Assoc')
      hence "(\<Psi>, (R \<parallel> T) \<parallel> !Q, R \<parallel> Q') \<in> Rel'" by(rule cSym')
      ultimately show ?thesis by(rule_tac Compose)
    qed
    ultimately show ?case by blast
  next
    case(cComm1 \<Psi>\<^isub>Q M N R' A\<^isub>R \<Psi>\<^isub>R K xvec Q' A\<^isub>Q)
    from `A\<^isub>R \<sharp>* (P, Q, R)` have "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q" and "A\<^isub>R \<sharp>* R" by simp+
    from `xvec \<sharp>* (P, Q, R)` have "xvec \<sharp>* P" and "xvec \<sharp>* Q" and "xvec \<sharp>* R" by simp+
    have FrQ: "extractFrame(!Q) = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" by fact
    have FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    from `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>N\<rparr> \<prec> R'` FrR `distinct A\<^isub>R` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* N` `A\<^isub>R \<sharp>* xvec` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* M`
    obtain A\<^isub>R' \<Psi>\<^isub>R' \<Psi>' where FrR': "extractFrame R' = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>" and "\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'" and "A\<^isub>R' \<sharp>* xvec" and "A\<^isub>R' \<sharp>* P" and "A\<^isub>R' \<sharp>* Q" and "A\<^isub>R' \<sharp>* \<Psi>"
      by(rule_tac C="(\<Psi>, xvec, P, Q)" and C'="(\<Psi>, xvec, P, Q)" in expandFrame) auto
    from `(\<Psi>, P, Q) \<in> Rel` have "(\<Psi> \<otimes> \<Psi>\<^isub>R, P, Q) \<in> Rel" by(rule cExt)
    moreover from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !Q \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> Q'` `guarded Q` `xvec \<sharp>* Q` `xvec \<sharp>* K`
    obtain S where QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> S" and "(\<one>, Q', S \<parallel> !Q) \<in> Rel'"
      by(fastsimp dest: rBangActE)
    ultimately obtain P' T where PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R : Q \<rhd> P \<Longrightarrow>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'" and P'Chain: "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> T" and "((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>', T, S) \<in> Rel"
      using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* \<Psi>\<^isub>R` `xvec \<sharp>* P`
      by(fastsimp dest: cSim weakSimE)

    from PTrans `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* xvec` `A\<^isub>R' \<sharp>* P` `A\<^isub>R' \<sharp>* xvec` `xvec \<sharp>* K` `distinct xvec`
    have "A\<^isub>R \<sharp>* P'" and  "A\<^isub>R' \<sharp>* P'"
      by(force dest: weakOutputFreshChainDerivative)+
    with P'Chain have "A\<^isub>R' \<sharp>* T" by(force dest: tauChainFreshChain)+
    from QTrans `A\<^isub>R' \<sharp>* Q` `A\<^isub>R' \<sharp>* xvec` `xvec \<sharp>* K` `distinct xvec` 
    have "A\<^isub>R' \<sharp>* S" by(force dest: outputFreshChainDerivative)

    obtain A\<^isub>Q' \<Psi>\<^isub>Q' where FrQ': "extractFrame Q = \<langle>A\<^isub>Q', \<Psi>\<^isub>Q'\<rangle>" and "A\<^isub>Q' \<sharp>* \<Psi>" and "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>Q' \<sharp>* A\<^isub>R" and "A\<^isub>Q' \<sharp>* M" and "A\<^isub>Q' \<sharp>* R" and "A\<^isub>Q' \<sharp>* K"
      by(rule_tac C="(\<Psi>, \<Psi>\<^isub>R, A\<^isub>R, K, M, R)" in freshFrame) auto
    from FrQ' `guarded Q` have "\<Psi>\<^isub>Q' \<simeq> \<one>" and "supp \<Psi>\<^isub>Q' = ({}::name set)" by(blast dest: guardedStatEq)+
    hence "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>Q'" by(auto simp add: fresh_star_def fresh_def)

    from PTrans obtain P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                             and NilImpP'': "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') (\<Psi> \<otimes> \<Psi>\<^isub>R)"
                             and P''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P'' \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
      using FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R` freshCompChain
      by(drule_tac weakTransitionE) auto

    from PChain have "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (P' \<parallel> !P))"
    proof(induct rule: tauChainCases)
      case TauBase
      from `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>N\<rparr> \<prec> R'` FrQ have "\<Psi> \<otimes> \<one> \<rhd> R \<longmapsto>M\<lparr>N\<rparr> \<prec> R'" by simp
      moreover note FrR
      moreover from P''Trans `P = P''` have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'" by simp
      hence "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'" by(rule statEqTransition) (metis Identity AssertionStatEqSym)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<parallel> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (P' \<parallel> !P)" using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* \<Psi>\<^isub>R` `xvec \<sharp>* P`
	by(force intro: Par1)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (P' \<parallel> !P)" using `guarded P` by(rule Bang)
      moreover from `\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K` FrQ have "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<one> \<turnstile> M \<leftrightarrow> K" by simp
      ultimately have "\<Psi> \<rhd> R \<parallel> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (P' \<parallel> !P))" using `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* M` `xvec \<sharp>* R`
	by(force intro: Comm1)
      thus ?case by(rule tauActTauStepChain)
    next
      case TauStep
      obtain A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "A\<^isub>P'' \<sharp>* \<Psi>" and "A\<^isub>P'' \<sharp>* K" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>P'' \<sharp>* R" and "A\<^isub>P'' \<sharp>* P''" and "A\<^isub>P'' \<sharp>* P"
                          and "A\<^isub>P'' \<sharp>* A\<^isub>R" and "distinct A\<^isub>P''"
	by(rule_tac C="(\<Psi>, K, A\<^isub>R, \<Psi>\<^isub>R, R, P'', P)" in freshFrame) auto
      from PChain `A\<^isub>R \<sharp>* P` have "A\<^isub>R \<sharp>* P''" by(drule_tac tauChainFreshChain) auto
      with FrP'' `A\<^isub>P'' \<sharp>* A\<^isub>R` have "A\<^isub>R \<sharp>* \<Psi>\<^isub>P''" by(drule_tac extractFrameFreshChain) auto
      from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sub>\<tau> P''` have "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P''" by(rule tauStepChainStatEq) (metis Identity AssertionStatEqSym)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<parallel> !P \<Longrightarrow>\<^sub>\<tau> P'' \<parallel> !P" by(rule_tac tauStepChainPar1) auto
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<Longrightarrow>\<^sub>\<tau> P'' \<parallel> !P" using `guarded P` by(rule tauStepChainBang)
      hence  "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> R \<parallel> (P'' \<parallel> !P)" using FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P`
	by(rule_tac tauStepChainPar2) auto
      moreover have "\<Psi> \<rhd> R \<parallel> (P'' \<parallel> !P) \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (P' \<parallel> !P))"
      proof -
	from FrQ `\<Psi>\<^isub>Q' \<simeq> \<one>` `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>N\<rparr> \<prec> R'` have "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<rhd> R \<longmapsto>M\<lparr>N\<rparr> \<prec> R'"
	  by simp (metis statEqTransition AssertionStatEqSym compositionSym)
	moreover from P''Trans have "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P'' \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> P'"
	  by(rule statEqTransition) (metis Identity AssertionStatEqSym)
	hence P''PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P'' \<parallel> !P \<longmapsto>K\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> (P' \<parallel> !P)" using `xvec \<sharp>* P`
	  by(rule_tac Par1) auto
	moreover from FrP'' have FrP''P: "extractFrame(P'' \<parallel> !P) = \<langle>A\<^isub>P'', \<Psi>\<^isub>P'' \<otimes> \<one>\<rangle>"
	  by auto
	moreover from FrQ `\<Psi>\<^isub>Q' \<simeq> \<one>` `\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K` have "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<otimes> \<Psi>\<^isub>R \<turnstile> M \<leftrightarrow> K"
	  by simp (metis statEqEnt Composition AssertionStatEqSym Commutativity)
	hence "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M" by(rule chanEqSym)
	moreover have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>Q') \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>)) \<otimes> \<Psi>\<^isub>R\<rangle>"
	proof -
	  have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>Q') \<otimes> \<Psi>\<^isub>R\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle>"
	    by(rule_tac frameResChainPres, simp)
	      (metis Associativity Commutativity Composition AssertionStatEqTrans AssertionStatEqSym)
	  moreover from NilImpP'' FrQ FrP'' `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R` freshCompChain have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P''\<rangle>"
	    by auto
	  moreover have "\<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R\<rangle>"
	    by(rule frameResChainPres, simp) 
              (metis Identity AssertionStatEqSym Associativity Commutativity Composition AssertionStatEqTrans)
	  ultimately show ?thesis by(rule FrameStatEqImpCompose)
	qed
	ultimately obtain M' where RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one> \<rhd> R \<longmapsto>M'\<lparr>N\<rparr> \<prec> R'" and "\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M'" and "A\<^isub>R \<sharp>* M'"
	  using FrR FrQ' `distinct A\<^isub>R` `distinct A\<^isub>P''` `A\<^isub>P'' \<sharp>* A\<^isub>R` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P''` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* R`  `A\<^isub>R \<sharp>* M` `A\<^isub>Q' \<sharp>* R` `A\<^isub>Q' \<sharp>* K` `A\<^isub>Q' \<sharp>* A\<^isub>R` `A\<^isub>R \<sharp>* P` `A\<^isub>P'' \<sharp>* P` `A\<^isub>R \<sharp>* xvec`
   		     `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R`  `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* K` `xvec \<sharp>* K` `distinct xvec`
	  by(rule_tac A\<^isub>Q="A\<^isub>Q'" and Q="Q" in comm2Aux) (assumption | simp)+

	note RTrans FrR P''PTrans FrP''P
	moreover from `\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M'` have "\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> M' \<leftrightarrow> K" by(rule chanEqSym)
	hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one> \<turnstile> M' \<leftrightarrow> K" by(metis statEqEnt Composition AssertionStatEqSym Commutativity)
	ultimately show ?thesis using `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* P''` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* M'` `A\<^isub>P'' \<sharp>* A\<^isub>R` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R` `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* P` `A\<^isub>P'' \<sharp>* K` `xvec \<sharp>* R`
	  by(rule_tac Comm1) (assumption | simp)+
      qed
      ultimately show ?thesis
	by(drule_tac tauActTauStepChain) auto
    qed

    moreover from P'Chain have "((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>') \<otimes> \<one> \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> T"
      by(rule tauChainStatEq) (metis Identity AssertionStatEqSym)
    hence "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<rhd> P' \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> T \<parallel> !P"
      by(rule_tac tauChainPar1) auto
    hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>' \<rhd> P' \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> T \<parallel> !P"
      by(rule tauChainStatEq) (metis Associativity)
    hence "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P' \<parallel> !P\<Longrightarrow>\<^sup>^\<^sub>\<tau> T \<parallel> !P" using `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'`
      by(rule_tac tauChainStatEq) (auto intro: compositionSym)
    hence "\<Psi> \<rhd> R' \<parallel> (P' \<parallel> !P) \<Longrightarrow>\<^sup>^\<^sub>\<tau> R' \<parallel> (T \<parallel> !P)" using FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P` `A\<^isub>R' \<sharp>* P'`
      by(rule_tac tauChainPar2) auto
    hence "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (P' \<parallel> !P)) \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (T \<parallel> !P))" using `xvec \<sharp>* \<Psi>`
      by(rule tauChainResChainPres)
    ultimately have "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (T \<parallel> !P))"
      by auto
    moreover have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (T \<parallel> !P)), \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel''"
    proof -
      from `((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>', T, S) \<in> Rel` have "(\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>', T, S) \<in> Rel"
	by(rule StatEq) (metis Associativity)
      hence "(\<Psi> \<otimes> \<Psi>\<^isub>R', T, S) \<in> Rel" using `\<Psi>\<^isub>R \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'`
	by(rule_tac StatEq) (auto dest: compositionSym)

      with FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* S` `A\<^isub>R' \<sharp>* T` have "(\<Psi>, R' \<parallel> T, R' \<parallel> S) \<in> Rel"
	by(rule_tac FrameParPres) auto
      hence "(\<Psi>, (R' \<parallel> T) \<parallel> !P, (R' \<parallel> S) \<parallel> !P) \<in> Rel" by(rule ParPres)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> T) \<parallel> !P), \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> S) \<parallel> !P)) \<in> Rel" using `xvec \<sharp>* \<Psi>`
	by(rule ResPres)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> T) \<parallel> !P, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> S)) \<parallel> !P) \<in> Rel" using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* P`
	by(force intro: Trans ScopeExt)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (T \<parallel> !P)), (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> S)) \<parallel> !P) \<in> Rel" using `xvec \<sharp>* \<Psi>`
	by(force intro: Trans ResPres Assoc)

      moreover from `(\<Psi>, P, Q) \<in> Rel` `guarded P` `guarded Q` have "(\<Psi>, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> S)) \<parallel> !P, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> S)) \<parallel> !Q) \<in> Rel''"
	by(rule C1)
      moreover from `(\<one>, Q', S \<parallel> !Q) \<in> Rel'` have "(\<one> \<otimes> \<Psi>, Q', S \<parallel> !Q) \<in> Rel'" by(rule cExt')
      hence "(\<Psi>, Q', S \<parallel> !Q) \<in> Rel'" 
	by(rule StatEq') (metis Identity AssertionStatEqSym Commutativity AssertionStatEqTrans)
      hence "(\<Psi>, R' \<parallel> Q', R' \<parallel> (S \<parallel> !Q)) \<in> Rel'" by(rule ParPres')
      hence "(\<Psi>, R' \<parallel> Q', (R' \<parallel> S) \<parallel> !Q) \<in> Rel'" by(metis Trans' Assoc')
      hence "(\<Psi>, (R' \<parallel> S) \<parallel> !Q, R' \<parallel> Q') \<in> Rel'" by(rule cSym')
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> S) \<parallel> !Q), \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel'" using `xvec \<sharp>* \<Psi>`
	by(rule ResPres')
      hence "(\<Psi>, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> S)) \<parallel> !Q, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel'" using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* Q`
	by(force intro: Trans' ScopeExt'[THEN cSym'])
      ultimately show ?thesis by(rule_tac Compose)
    qed
    ultimately show ?case by blast
  next
    case(cComm2 \<Psi>\<^isub>Q M xvec N R' A\<^isub>R \<Psi>\<^isub>R K Q' A\<^isub>Q)
    from `A\<^isub>R \<sharp>* (P, Q, R)` have "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q" and "A\<^isub>R \<sharp>* R" by simp+
    from `xvec \<sharp>* (P, Q, R)` have "xvec \<sharp>* P" and "xvec \<sharp>* Q" and "xvec \<sharp>* R" by simp+
    have FrQ: "extractFrame(!Q) = \<langle>A\<^isub>Q, \<Psi>\<^isub>Q\<rangle>" by fact
    have FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" by fact
    from `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> R'` FrR `distinct A\<^isub>R` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* N` `A\<^isub>R \<sharp>* xvec` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* \<Psi>` `xvec \<sharp>* R` `xvec \<sharp>* \<Psi>` `xvec \<sharp>* P` `xvec \<sharp>* Q` `xvec \<sharp>* M` `distinct xvec` `A\<^isub>R \<sharp>* M`
    obtain p A\<^isub>R' \<Psi>\<^isub>R' \<Psi>' where FrR': "extractFrame R' = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>" and "(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'" and "A\<^isub>R' \<sharp>* xvec" and "A\<^isub>R' \<sharp>* P" and "A\<^isub>R' \<sharp>* Q" and "A\<^isub>R' \<sharp>* \<Psi>" and S: "set p \<subseteq> set xvec \<times> set(p \<bullet> xvec)" and "distinctPerm p" and "(p \<bullet> xvec) \<sharp>* N" and "(p \<bullet> xvec) \<sharp>* Q" and "(p \<bullet> xvec) \<sharp>* R'" and "(p \<bullet> xvec) \<sharp>* P" and "(p \<bullet> xvec) \<sharp>* \<Psi>" and "A\<^isub>R' \<sharp>* N" and "A\<^isub>R' \<sharp>* xvec" and "A\<^isub>R' \<sharp>* (p \<bullet> xvec)"
      by(rule_tac C="(\<Psi>, P, Q)"  and C'="(\<Psi>, P, Q)" in expandFrame) (assumption | simp)+

    from `\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>\<nu>*xvec\<rparr>\<langle>N\<rangle> \<prec> R'` S `(p \<bullet> xvec) \<sharp>* N` `(p \<bullet> xvec) \<sharp>* R'`
    have  RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>Q \<rhd> R \<longmapsto>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> R')"
      by(simp add: boundOutputChainAlpha'' residualInject)
    from `(\<Psi>, P, Q) \<in> Rel` have "(\<Psi> \<otimes> \<Psi>\<^isub>R, P, Q) \<in> Rel" by(rule cExt)
    moreover from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !Q \<longmapsto>K\<lparr>N\<rparr> \<prec> Q'` S `(p \<bullet> xvec) \<sharp>* Q` `xvec \<sharp>* Q` `distinctPerm p`
    have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !Q \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> (p \<bullet> Q')" by(rule_tac inputAlpha) auto
    then obtain S where QTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> Q \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> S" and "(\<one>, (p \<bullet> Q'), S \<parallel> !Q) \<in> Rel'" 
      using `guarded Q`
      by(fastsimp dest: rBangActE)
    ultimately obtain P' T where PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R : Q \<rhd> P \<Longrightarrow>K\<lparr>(p \<bullet> N)\<rparr> \<prec> P'" 
                             and P'Chain: "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> (p \<bullet> \<Psi>') \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> T" 
                             and "((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> (p \<bullet> \<Psi>'), T, S) \<in> Rel"
      by(fastsimp dest: cSim weakSimE)

    from `A\<^isub>R' \<sharp>* N` `A\<^isub>R' \<sharp>* xvec` `A\<^isub>R' \<sharp>* (p \<bullet> xvec)` S have "A\<^isub>R' \<sharp>* (p \<bullet> N)"
      by(simp add: freshChainSimps)
    with PTrans `A\<^isub>R' \<sharp>* P` have "A\<^isub>R' \<sharp>* P'" by(force dest: weakInputFreshChainDerivative)
    with P'Chain have "A\<^isub>R' \<sharp>* T" by(force dest: tauChainFreshChain)+
    from QTrans `A\<^isub>R' \<sharp>* Q` `A\<^isub>R' \<sharp>* (p \<bullet> N)` have "A\<^isub>R' \<sharp>* S" by(force dest: inputFreshChainDerivative)

    obtain A\<^isub>Q' \<Psi>\<^isub>Q' where FrQ': "extractFrame Q = \<langle>A\<^isub>Q', \<Psi>\<^isub>Q'\<rangle>" and "A\<^isub>Q' \<sharp>* \<Psi>" and "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>Q' \<sharp>* A\<^isub>R" and "A\<^isub>Q' \<sharp>* M" and "A\<^isub>Q' \<sharp>* R" and "A\<^isub>Q' \<sharp>* K"
      by(rule_tac C="(\<Psi>, \<Psi>\<^isub>R, A\<^isub>R, K, M, R)" in freshFrame) auto
    from FrQ' `guarded Q` have "\<Psi>\<^isub>Q' \<simeq> \<one>" and "supp \<Psi>\<^isub>Q' = ({}::name set)" by(blast dest: guardedStatEq)+
    hence "A\<^isub>Q' \<sharp>* \<Psi>\<^isub>Q'" by(auto simp add: fresh_star_def fresh_def)

    from PTrans obtain P'' where PChain: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"
                             and NilImpP'': "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle> \<hookrightarrow>\<^sub>F insertAssertion (extractFrame P'') (\<Psi> \<otimes> \<Psi>\<^isub>R)"
                             and P''Trans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P'' \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> P'"
      using FrQ' `A\<^isub>Q' \<sharp>* \<Psi>` `A\<^isub>Q' \<sharp>* \<Psi>\<^isub>R` freshCompChain
      by(drule_tac weakTransitionE) auto

    from `(p \<bullet> xvec) \<sharp>* P` `xvec \<sharp>* P` PChain have "(p \<bullet> xvec) \<sharp>* P''" and "xvec \<sharp>* P''" 
      by(force dest: tauChainFreshChain)+
    from `(p \<bullet> xvec) \<sharp>* N` `distinctPerm p` have "xvec \<sharp>* (p \<bullet> N)"
      by(subst pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst, where pi=p, symmetric]) simp
    with P''Trans `xvec \<sharp>* P''` have "xvec \<sharp>* P'" by(force dest: inputFreshChainDerivative)
    hence "(p \<bullet> xvec) \<sharp>* (p \<bullet> P')" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])

    from PChain have "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> R') \<parallel> (P' \<parallel> !P))"
    proof(induct rule: tauChainCases)
      case TauBase
      from RTrans FrQ have "\<Psi> \<otimes> \<one> \<rhd> R \<longmapsto>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> R')" by simp
      moreover note FrR
      moreover from P''Trans `P = P''` have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr>\<prec> P'" by simp
      hence "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> P'" 
	by(rule statEqTransition) (metis Identity AssertionStatEqSym)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<parallel> !P \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> (P' \<parallel> !P)" by(force intro: Par1)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> (P' \<parallel> !P)" using `guarded P` by(rule Bang)
      moreover from `\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K` FrQ have "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<one> \<turnstile> M \<leftrightarrow> K" by simp
      ultimately have "\<Psi> \<rhd> R \<parallel> !P \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> R') \<parallel> (P' \<parallel> !P))" using `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* M` `(p \<bullet> xvec) \<sharp>* P`
	by(force intro: Comm2)
      thus ?case by(rule tauActTauStepChain)
    next
      case TauStep
      obtain A\<^isub>P'' \<Psi>\<^isub>P'' where FrP'': "extractFrame P'' = \<langle>A\<^isub>P'', \<Psi>\<^isub>P''\<rangle>" and "A\<^isub>P'' \<sharp>* \<Psi>" and "A\<^isub>P'' \<sharp>* K" and "A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R" and "A\<^isub>P'' \<sharp>* R" and "A\<^isub>P'' \<sharp>* P''" and "A\<^isub>P'' \<sharp>* P"
                          and "A\<^isub>P'' \<sharp>* A\<^isub>R" and "distinct A\<^isub>P''"
	by(rule_tac C="(\<Psi>, K, A\<^isub>R, \<Psi>\<^isub>R, R, P'', P)" in freshFrame) auto
      from PChain `A\<^isub>R \<sharp>* P` have "A\<^isub>R \<sharp>* P''" by(drule_tac tauChainFreshChain) auto
      with FrP'' `A\<^isub>P'' \<sharp>* A\<^isub>R` have "A\<^isub>R \<sharp>* \<Psi>\<^isub>P''" by(drule_tac extractFrameFreshChain) auto
      from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<Longrightarrow>\<^sub>\<tau> P''` have "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P \<Longrightarrow>\<^sub>\<tau> P''" by(rule tauStepChainStatEq) (metis Identity AssertionStatEqSym)
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<parallel> !P \<Longrightarrow>\<^sub>\<tau> P'' \<parallel> !P" by(rule_tac tauStepChainPar1) auto
      hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> !P \<Longrightarrow>\<^sub>\<tau> P'' \<parallel> !P" using `guarded P` by(rule tauStepChainBang)
      hence  "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> R \<parallel> (P'' \<parallel> !P)" using FrR `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P`
	by(rule_tac tauStepChainPar2) auto
      moreover have "\<Psi> \<rhd> R \<parallel> (P'' \<parallel> !P) \<longmapsto>\<tau> \<prec> \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> R') \<parallel> (P' \<parallel> !P))"
      proof -
	from FrQ `\<Psi>\<^isub>Q' \<simeq> \<one>` RTrans have "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<rhd> R \<longmapsto>M\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> R')"
	  by simp (metis statEqTransition AssertionStatEqSym compositionSym)
	moreover from P''Trans have "(\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<one> \<rhd> P'' \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> P'"
	  by(rule statEqTransition) (metis Identity AssertionStatEqSym)
	hence P''PTrans: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P'' \<parallel> !P \<longmapsto>K\<lparr>(p \<bullet> N)\<rparr> \<prec> (P' \<parallel> !P)"
	  by(rule_tac Par1) auto
	moreover from FrP'' have FrP''P: "extractFrame(P'' \<parallel> !P) = \<langle>A\<^isub>P'', \<Psi>\<^isub>P'' \<otimes> \<one>\<rangle>"
	  by auto
	moreover from FrQ `\<Psi>\<^isub>Q' \<simeq> \<one>` `\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>Q \<turnstile> M \<leftrightarrow> K` have "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<otimes> \<Psi>\<^isub>R \<turnstile> M \<leftrightarrow> K"
	  by simp (metis statEqEnt Composition AssertionStatEqSym Commutativity)
	hence "\<Psi> \<otimes> \<Psi>\<^isub>Q' \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M" by(rule chanEqSym)
	moreover have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>Q') \<otimes> \<Psi>\<^isub>R\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>)) \<otimes> \<Psi>\<^isub>R\<rangle>"
	proof -
	  have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>Q') \<otimes> \<Psi>\<^isub>R\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle>"
	    by(rule_tac frameResChainPres, simp)
	      (metis Associativity Commutativity Composition AssertionStatEqTrans AssertionStatEqSym)
	  moreover from NilImpP'' FrQ FrP'' `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* \<Psi>\<^isub>R` freshCompChain have "\<langle>A\<^isub>Q', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>Q'\<rangle> \<hookrightarrow>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P''\<rangle>"
	    by auto
	  moreover have "\<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> \<Psi>\<^isub>P''\<rangle> \<simeq>\<^sub>F \<langle>A\<^isub>P'', (\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R\<rangle>"
	    by(rule frameResChainPres, simp) 
              (metis Identity AssertionStatEqSym Associativity Commutativity Composition AssertionStatEqTrans)
	  ultimately show ?thesis by(rule FrameStatEqImpCompose)
	qed
	ultimately obtain M' where RTrans: "\<Psi> \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one> \<rhd> R \<longmapsto>M'\<lparr>\<nu>*(p \<bullet> xvec)\<rparr>\<langle>(p \<bullet> N)\<rangle> \<prec> (p \<bullet> R')" and "\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M'" and "A\<^isub>R \<sharp>* M'"
	  using FrR FrQ' `distinct A\<^isub>R` `distinct A\<^isub>P''` `A\<^isub>P'' \<sharp>* A\<^isub>R` `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P''` `A\<^isub>R \<sharp>* Q` `A\<^isub>R \<sharp>* R`  `A\<^isub>R \<sharp>* M` `A\<^isub>Q' \<sharp>* R` `A\<^isub>Q' \<sharp>* K` `A\<^isub>Q' \<sharp>* A\<^isub>R` `A\<^isub>R \<sharp>* P` `A\<^isub>P'' \<sharp>* P`
   		     `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R`  `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* K`
	  by(rule_tac A\<^isub>Q="A\<^isub>Q'" and Q="Q" in comm1Aux) (assumption | simp)+

	note RTrans FrR P''PTrans FrP''P
	moreover from `\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> K \<leftrightarrow> M'` have "\<Psi> \<otimes> (\<Psi>\<^isub>P'' \<otimes> \<one>) \<otimes> \<Psi>\<^isub>R \<turnstile> M' \<leftrightarrow> K" by(rule chanEqSym)
	hence "\<Psi> \<otimes> \<Psi>\<^isub>R \<otimes> \<Psi>\<^isub>P'' \<otimes> \<one> \<turnstile> M' \<leftrightarrow> K" by(metis statEqEnt Composition AssertionStatEqSym Commutativity)
	ultimately show ?thesis using `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* R` `A\<^isub>R \<sharp>* P''` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* M'` `A\<^isub>P'' \<sharp>* A\<^isub>R` `A\<^isub>P'' \<sharp>* \<Psi>` `A\<^isub>P'' \<sharp>* R` `A\<^isub>P'' \<sharp>* P''` `A\<^isub>P'' \<sharp>* P` `A\<^isub>P'' \<sharp>* K` `(p \<bullet> xvec) \<sharp>* P''` `(p \<bullet> xvec) \<sharp>* P`
	  by(rule_tac Comm2) (assumption | simp)+
      qed
      ultimately show ?thesis
	by(drule_tac tauActTauStepChain) auto
    qed
    hence "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> P') \<parallel> !P))" 
      using `xvec \<sharp>* P` `(p \<bullet> xvec) \<sharp>* P` `(p \<bullet> xvec) \<sharp>* (p \<bullet> P')` `(p \<bullet> xvec) \<sharp>* R'` S `distinctPerm p`
      by(subst resChainAlpha[where p=p]) auto
    moreover from P'Chain have "(p \<bullet> ((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> (p \<bullet> \<Psi>'))) \<rhd> (p \<bullet> P') \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T)"
      by(rule tauChainEqvt)
    with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S `distinctPerm p`
    have "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>' \<rhd> (p \<bullet> P') \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T)" by(simp add: eqvts)
    hence "((\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>') \<otimes> \<one> \<rhd> (p \<bullet> P') \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T)"
      by(rule tauChainStatEq) (metis Identity AssertionStatEqSym)
    hence "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>' \<rhd> (p \<bullet> P') \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T) \<parallel> !P"
      by(rule_tac tauChainPar1) auto
    hence "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<rhd> (p \<bullet> P') \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T) \<parallel> !P"
      by(rule tauChainStatEq) (metis Associativity)
    hence "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> (p \<bullet> P') \<parallel> !P \<Longrightarrow>\<^sup>^\<^sub>\<tau> (p \<bullet> T) \<parallel> !P" using `(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq>  \<Psi>\<^isub>R'`
      by(rule_tac tauChainStatEq) (auto intro: compositionSym)
    hence "\<Psi> \<rhd> R' \<parallel> ((p \<bullet> P') \<parallel> !P) \<Longrightarrow>\<^sup>^\<^sub>\<tau> R' \<parallel> ((p \<bullet> T) \<parallel> !P)" 
      using FrR' `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P` `A\<^isub>R' \<sharp>* P'` `A\<^isub>R' \<sharp>* xvec` `A\<^isub>R' \<sharp>* (p \<bullet> xvec)` S
      by(rule_tac tauChainPar2) (auto simp add: freshChainSimps)
    hence "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> P') \<parallel> !P)) \<Longrightarrow>\<^sup>^\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> T) \<parallel> !P))" using `xvec \<sharp>* \<Psi>`
      by(rule tauChainResChainPres)
    ultimately have "\<Psi> \<rhd> R \<parallel> !P \<Longrightarrow>\<^sub>\<tau> \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> T) \<parallel> !P))"
      by auto
    moreover have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> T) \<parallel> !P)), \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel''"
    proof -
      from `((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> (p \<bullet> \<Psi>'), T, S) \<in> Rel` 
      have "(p \<bullet> ((\<Psi> \<otimes> \<Psi>\<^isub>R) \<otimes> (p \<bullet> \<Psi>')), (p \<bullet> T), (p \<bullet> S)) \<in> Rel"
	by(rule Closed)
      with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` `distinctPerm p` S
      have "((\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> \<Psi>', p \<bullet> T, p \<bullet> S) \<in> Rel"
	by(simp add: eqvts)
      hence "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>', p \<bullet> T, p \<bullet> S) \<in> Rel"
	by(rule StatEq) (metis Associativity)
      hence "(\<Psi> \<otimes> \<Psi>\<^isub>R', p \<bullet> T, p \<bullet> S) \<in> Rel" using `(p \<bullet> \<Psi>\<^isub>R) \<otimes> \<Psi>' \<simeq> \<Psi>\<^isub>R'`
	by(rule_tac StatEq) (auto dest: compositionSym)
      moreover from `A\<^isub>R' \<sharp>* S` `A\<^isub>R' \<sharp>* T` `A\<^isub>R' \<sharp>* xvec` `A\<^isub>R' \<sharp>* (p \<bullet> xvec)` S
      have "A\<^isub>R' \<sharp>* (p \<bullet> S)" and "A\<^isub>R' \<sharp>* (p \<bullet> T)"
	by(simp add: freshChainSimps)+
      ultimately have "(\<Psi>, R' \<parallel> (p \<bullet> T), R' \<parallel> (p \<bullet> S)) \<in> Rel" using FrR' `A\<^isub>R' \<sharp>* \<Psi>`
	by(rule_tac FrameParPres) auto
      hence "(\<Psi>, (R' \<parallel> (p \<bullet> T)) \<parallel> !P, (R' \<parallel> (p \<bullet> S)) \<parallel> !P) \<in> Rel" by(rule ParPres)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> (p \<bullet> T)) \<parallel> !P), \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> (p \<bullet> S)) \<parallel> !P)) \<in> Rel" 
	using `xvec \<sharp>* \<Psi>`
	by(rule ResPres)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> T)) \<parallel> !P, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> S))) \<parallel> !P) \<in> Rel" 
	using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* P`
	by(force intro: Trans ScopeExt)
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> ((p \<bullet> T) \<parallel> !P)), (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> S))) \<parallel> !P) \<in> Rel"
	using `xvec \<sharp>* \<Psi>`
	by(force intro: Trans ResPres Assoc)
      moreover from `(\<Psi>, P, Q) \<in> Rel` `guarded P` `guarded Q` 
      have "(\<Psi>, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> S))) \<parallel> !P, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> S))) \<parallel> !Q) \<in> Rel''"
	by(rule C1)
      moreover from `(\<one>, (p \<bullet> Q'), S \<parallel> !Q) \<in> Rel'` 
      have "(p \<bullet> \<one>, p \<bullet> p \<bullet> Q', p \<bullet> (S \<parallel> !Q)) \<in> Rel'" by(rule Closed')
      with `xvec \<sharp>* Q` `(p \<bullet> xvec) \<sharp>* Q` S `distinctPerm p` 
	have "(\<one>, Q', (p \<bullet> S) \<parallel> !Q) \<in> Rel'" by(simp add: eqvts)
      hence "(\<one> \<otimes> \<Psi>, Q', (p \<bullet> S) \<parallel> !Q) \<in> Rel'" by(rule cExt')
      hence "(\<Psi>, Q', (p \<bullet> S) \<parallel> !Q) \<in> Rel'" 
	by(rule StatEq') (metis Identity AssertionStatEqSym Commutativity AssertionStatEqTrans)
      hence "(\<Psi>, R' \<parallel> Q', R' \<parallel> ((p \<bullet> S) \<parallel> !Q)) \<in> Rel'" by(rule ParPres')
      hence "(\<Psi>, R' \<parallel> Q', (R' \<parallel> (p \<bullet> S)) \<parallel> !Q) \<in> Rel'" by(metis Trans' Assoc')
      hence "(\<Psi>, (R' \<parallel> (p \<bullet> S)) \<parallel> !Q, R' \<parallel> Q') \<in> Rel'" by(rule cSym')
      hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>((R' \<parallel> (p \<bullet> S)) \<parallel> !Q), \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel'" using `xvec \<sharp>* \<Psi>`
	by(rule ResPres')
      hence "(\<Psi>, (\<lparr>\<nu>*xvec\<rparr>(R' \<parallel> (p \<bullet> S))) \<parallel> !Q, \<lparr>\<nu>*xvec\<rparr>(R' \<parallel> Q')) \<in> Rel'" using `xvec \<sharp>* \<Psi>` `xvec \<sharp>* Q`
	by(force intro: Trans' ScopeExt'[THEN cSym'])
      ultimately show ?thesis by(rule_tac Compose)
    qed
    ultimately show ?case by blast
  qed
qed
notation relcomp (infixr "O" 75)

end

end