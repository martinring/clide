(* 
   Title: Psi-calculi   
   Author/Maintainer: Jesper Bengtson (jebe@itu.dk), 2012
*)
theory Weak_Bisim_Pres
  imports Weak_Bisimulation Weak_Sim_Pres Weak_Stat_Imp_Pres
begin

context env begin

lemma weakBisimInputPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a

  assumes "\<And>Tvec. length xvec = length Tvec \<Longrightarrow> \<Psi> \<rhd> P[xvec::=Tvec] \<approx> Q[xvec::=Tvec]"

  shows "\<Psi> \<rhd> M\<lparr>\<lambda>*xvec N\<rparr>.P \<approx> M\<lparr>\<lambda>*xvec N\<rparr>.Q"
proof -
  let ?X = "{(\<Psi>, M\<lparr>\<lambda>*xvec N\<rparr>.P, M\<lparr>\<lambda>*xvec N\<rparr>.Q) | \<Psi> M xvec N P Q. \<forall>Tvec. length xvec = length Tvec \<longrightarrow> \<Psi> \<rhd> P[xvec::=Tvec] \<approx> Q[xvec::=Tvec]}"

  from assms have "(\<Psi>, M\<lparr>\<lambda>*xvec N\<rparr>.P, M\<lparr>\<lambda>*xvec N\<rparr>.Q) \<in> ?X" by blast
  thus ?thesis
  proof(coinduct rule: weakBisimCoinduct)
    case(cStatImp \<Psi> P Q)
    thus ?case by(fastsimp intro: weakStatImpInputPres dest: weakBisimE(3))
  next
    case(cSim \<Psi> P Q)
    thus ?case
      by auto (blast intro: weakInputPres dest: weakBisimE)
  next
    case(cExt \<Psi> P Q \<Psi>')
    thus ?case by(blast dest: weakBisimE)
  next
    case(cSym \<Psi> P Q)
    thus ?case by(blast dest: weakBisimE)
  qed
qed
  
lemma weakBisimOutputPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a

  assumes "\<Psi> \<rhd> P \<approx> Q"

  shows "\<Psi> \<rhd> M\<langle>N\<rangle>.P \<approx> M\<langle>N\<rangle>.Q"
proof -
  let ?X = "{(\<Psi>, M\<langle>N\<rangle>.P, M\<langle>N\<rangle>.Q) | \<Psi> M N P Q. \<Psi> \<rhd> P \<approx> Q}"

  from assms have "(\<Psi>, M\<langle>N\<rangle>.P, M\<langle>N\<rangle>.Q) \<in> ?X" by blast
  thus ?thesis
  proof(coinduct rule: weakBisimCoinduct)
    case(cStatImp \<Psi> P Q)
    thus ?case by auto (blast intro: weakStatImpOutputPres dest: weakBisimE(3))
  next
    case(cSim \<Psi> P Q)
    thus ?case
      by(auto intro: weakOutputPres dest: weakBisimE)
  next
    case(cExt \<Psi> P Q \<Psi>')
    thus ?case by(blast dest: weakBisimE)
  next
    case(cSym \<Psi> P Q)
    thus ?case by(blast dest: weakBisimE)
  qed
qed

lemma weakBisimResPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   x :: name
  
  assumes "\<Psi> \<rhd> P \<approx> Q"
  and     "x \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<approx> \<lparr>\<nu>x\<rparr>Q"
proof -
  let ?X = "{(\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) | \<Psi> x P Q. \<Psi> \<rhd> P \<approx> Q \<and> x \<sharp> \<Psi>}"
  
  from assms have "(\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X" by auto
  thus ?thesis
  proof(coinduct rule: weakBisimCoinduct)
    case(cStatImp \<Psi> xP xQ)
    {
      fix \<Psi> P Q x
      assume "\<Psi> \<rhd> P \<approx> Q"
      hence "\<Psi> \<rhd> P \<lessapprox><weakBisim> Q" by(rule weakBisimE)
      moreover have "eqvt weakBisim" by auto
      moreover assume "(x::name) \<sharp> \<Psi>"
      moreover have "\<And>\<Psi> P Q x. \<lbrakk>(\<Psi>, P, Q) \<in> weakBisim; x \<sharp> \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X \<union> weakBisim"
        by auto
      ultimately have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<lessapprox><(?X \<union> weakBisim)> \<lparr>\<nu>x\<rparr>Q"
        by(rule weakStatImpResPres)
    }
    with `(\<Psi>, xP, xQ) \<in> ?X` show ?case by auto
  next
    case(cSim \<Psi> xP xQ)
    from `(\<Psi>, xP, xQ) \<in> ?X` obtain x P Q where "\<Psi> \<rhd> P \<approx> Q" and "x \<sharp> \<Psi>" and "xP = \<lparr>\<nu>x\<rparr>P" and "xQ = \<lparr>\<nu>x\<rparr>Q"
      by auto
    from `\<Psi> \<rhd> P \<approx> Q` have "\<Psi> \<rhd> P \<leadsto><weakBisim> Q" by(rule weakBisimE)
    moreover have "eqvt ?X"
      by(force simp add: eqvt_def weakBisimClosed pt_fresh_bij[OF pt_name_inst, OF at_name_inst])
    hence "eqvt(?X \<union> weakBisim)" by auto
    moreover note `x \<sharp> \<Psi>`
    moreover have "weakBisim \<subseteq> ?X \<union> weakBisim" by auto
    moreover have "\<And>\<Psi> P Q x. \<lbrakk>(\<Psi>, P, Q) \<in> weakBisim; x \<sharp> \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X \<union> weakBisim"
      by auto
    ultimately have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<leadsto><(?X \<union> weakBisim)> \<lparr>\<nu>x\<rparr>Q"
      by(rule weakResPres)
    with `xP = \<lparr>\<nu>x\<rparr>P` `xQ = \<lparr>\<nu>x\<rparr>Q` show ?case
      by simp
  next
    case(cExt \<Psi> xP xQ \<Psi>')
    from `(\<Psi>, xP, xQ) \<in> ?X` obtain x P Q where "\<Psi> \<rhd> P \<approx> Q" and "x \<sharp> \<Psi>" and "xP = \<lparr>\<nu>x\<rparr>P" and "xQ = \<lparr>\<nu>x\<rparr>Q"
      by auto
    obtain y::name where "y \<sharp> P" and "y \<sharp> Q" and "y \<sharp> \<Psi>" and "y \<sharp> \<Psi>'"
     by(generate_fresh "name", auto simp add: fresh_prod)
   from `\<Psi> \<rhd> P \<approx> Q` have "\<Psi> \<otimes> ([(x, y)] \<bullet> \<Psi>') \<rhd> P \<approx> Q"
     by(rule weakBisimE)
   hence "([(x, y)] \<bullet> (\<Psi> \<otimes> ([(x, y)] \<bullet> \<Psi>'))) \<rhd> ([(x, y)] \<bullet> P) \<approx> ([(x, y)] \<bullet> Q)"
     by(rule weakBisimClosed)
   with `x \<sharp> \<Psi>` `y \<sharp> \<Psi>` have "\<Psi> \<otimes> \<Psi>' \<rhd> ([(x, y)] \<bullet> P) \<approx> ([(x, y)] \<bullet> Q)"
     by(simp add: eqvts)
   with `y \<sharp> \<Psi>` `y \<sharp> \<Psi>'` have "(\<Psi> \<otimes> \<Psi>', \<lparr>\<nu>y\<rparr>([(x, y)] \<bullet> P), \<lparr>\<nu>y\<rparr>([(x, y)] \<bullet> Q)) \<in> ?X"
     by auto
   moreover from `y \<sharp> P` `y \<sharp> Q` have "\<lparr>\<nu>x\<rparr>P = \<lparr>\<nu>y\<rparr>([(x, y)] \<bullet> P)" and "\<lparr>\<nu>x\<rparr>Q = \<lparr>\<nu>y\<rparr>([(x, y)] \<bullet> Q)"
     by(simp add: alphaRes)+
   ultimately show ?case using `xP = \<lparr>\<nu>x\<rparr>P` `xQ = \<lparr>\<nu>x\<rparr>Q` by simp
 next
    case(cSym \<Psi> P Q)
    thus ?case by(blast dest: weakBisimE)
  qed
qed

lemma weakBisimResChainPres:
  fixes \<Psi>   :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   xvec :: "name list"

  assumes "\<Psi> \<rhd> P \<approx> Q"
  and     "xvec \<sharp>* \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>P \<approx> \<lparr>\<nu>*xvec\<rparr>Q"
using assms
by(induct xvec) (auto intro: weakBisimResPres)

lemma weakBisimParPresAux:
  fixes \<Psi>  :: 'b
  and   \<Psi>\<^isub>R :: 'b
  and   P  :: "('a, 'b, 'c) psi"
  and   Q  :: "('a, 'b, 'c) psi"
  and   R  :: "('a, 'b, 'c) psi"
  and   A\<^isub>R :: "name list"
  
  assumes "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
  and     FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
  and     "A\<^isub>R \<sharp>* \<Psi>"
  and     "A\<^isub>R \<sharp>* P"
  and     "A\<^isub>R \<sharp>* Q"

  shows "\<Psi> \<rhd> P \<parallel> R \<approx> Q \<parallel> R"
proof -
  let ?X = "{(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R), \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)) | xvec \<Psi> P Q R. xvec \<sharp>* \<Psi> \<and> (\<forall>A\<^isub>R \<Psi>\<^isub>R. (extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle> \<and> A\<^isub>R \<sharp>* \<Psi> \<and> A\<^isub>R \<sharp>* P \<and> A\<^isub>R \<sharp>* Q) \<longrightarrow>
                                                                                          \<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q)}"
  {
    fix xvec :: "name list"
    and \<Psi>    :: 'b 
    and P    :: "('a, 'b, 'c) psi"
    and Q    :: "('a, 'b, 'c) psi"
    and R    :: "('a, 'b, 'c) psi"

    assume "xvec \<sharp>* \<Psi>"
    and    "\<And>A\<^isub>R \<Psi>\<^isub>R. \<lbrakk>extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>; A\<^isub>R \<sharp>* \<Psi>; A\<^isub>R \<sharp>* P; A\<^isub>R \<sharp>* Q\<rbrakk> \<Longrightarrow> \<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"

    hence "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R), \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)) \<in> ?X"
      by blast
  }
  note XI = this

  {
    fix xvec :: "name list"
    and \<Psi>    :: 'b 
    and P    :: "('a, 'b, 'c) psi"
    and Q    :: "('a, 'b, 'c) psi"
    and R    :: "('a, 'b, 'c) psi"
    and C    :: "'d::fs_name"

    assume "xvec \<sharp>* \<Psi>"
    and    A: "\<And>A\<^isub>R \<Psi>\<^isub>R. \<lbrakk>extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>; A\<^isub>R \<sharp>* \<Psi>; A\<^isub>R \<sharp>* P; A\<^isub>R \<sharp>* Q; A\<^isub>R \<sharp>* C\<rbrakk> \<Longrightarrow> \<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"

    from `xvec \<sharp>* \<Psi>` have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R), \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)) \<in> ?X"
    proof(rule XI)
      fix A\<^isub>R \<Psi>\<^isub>R
      assume FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
      obtain p::"name prm" where "(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>" and "(p \<bullet> A\<^isub>R) \<sharp>* P" and "(p \<bullet> A\<^isub>R) \<sharp>* Q" and "(p \<bullet> A\<^isub>R) \<sharp>* R" and "(p \<bullet> A\<^isub>R) \<sharp>* C"
                             and "(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>\<^isub>R" and S: "(set p) \<subseteq> (set A\<^isub>R) \<times> (set(p \<bullet> A\<^isub>R))" and "distinctPerm p"
	by(rule_tac c="(\<Psi>, P, Q, R, \<Psi>\<^isub>R, C)" in name_list_avoiding) auto
      from FrR `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>\<^isub>R` S have "extractFrame R = \<langle>(p \<bullet> A\<^isub>R), p \<bullet> \<Psi>\<^isub>R\<rangle>" by(simp add: frameChainAlpha')

      moreover assume "A\<^isub>R \<sharp>* \<Psi>"
      hence "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> \<Psi>)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `A\<^isub>R \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>` S have "(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>" by simp
      moreover assume "A\<^isub>R \<sharp>* P"
      hence "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> P)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `A\<^isub>R \<sharp>* P` `(p \<bullet> A\<^isub>R) \<sharp>* P` S have "(p \<bullet> A\<^isub>R) \<sharp>* P" by simp
      moreover assume "A\<^isub>R \<sharp>* Q"
      hence "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> Q)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `A\<^isub>R \<sharp>* Q` `(p \<bullet> A\<^isub>R) \<sharp>* Q` S have "(p \<bullet> A\<^isub>R) \<sharp>* Q" by simp
      ultimately have "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P \<approx> Q" using `(p \<bullet> A\<^isub>R) \<sharp>* C` A by blast
      hence "(p \<bullet> (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R))) \<rhd> (p \<bullet> P) \<approx> (p \<bullet> Q)" by(rule weakBisimClosed)
      with `A\<^isub>R \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `(p \<bullet> A\<^isub>R) \<sharp>* P` `A\<^isub>R \<sharp>* Q` `(p \<bullet> A\<^isub>R) \<sharp>* Q` S `distinctPerm p`
      show "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q" by(simp add: eqvts)
    qed
  }
  note XI' = this

  have "eqvt ?X"
    apply(auto simp add: eqvt_def)
    apply(rule_tac x="p \<bullet> xvec" in exI)
    apply(rule_tac x="p \<bullet> P" in exI)
    apply(rule_tac x="p \<bullet> Q" in exI)
    apply(rule_tac x="p \<bullet> R" in exI)
    apply(simp add: eqvts)
    apply(simp add: fresh_star_bij)
    apply(clarify)
    apply(erule_tac x="(rev p) \<bullet> A\<^isub>R" in allE)
    apply(erule_tac x="(rev p) \<bullet> \<Psi>\<^isub>R" in allE)
    apply(drule mp)
    apply(rule conjI)
    apply(rule_tac pi=p in pt_bij4[OF pt_name_inst, OF at_name_inst])
    apply(simp add: eqvts)
    defer
    apply(drule_tac p=p in weakBisimClosed)
    apply(simp add: eqvts)
    apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of p, THEN sym])
    apply simp
    apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of p, THEN sym])
    apply simp
    apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of p, THEN sym])
    by simp

  moreover have Res: "\<And>\<Psi> P Q x. \<lbrakk>(\<Psi>, P, Q) \<in> ?X \<union> weakBisim; x \<sharp> \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X \<union> weakBisim"
  proof -
    fix \<Psi> P Q x
    assume "(\<Psi>, P, Q) \<in> ?X \<union> weakBisim" and "(x::name) \<sharp> \<Psi>"
    show "(\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X \<union> weakBisim"
    proof(case_tac "(\<Psi>, P, Q) \<in> ?X")
      assume "(\<Psi>, P, Q) \<in> ?X"
      with `x \<sharp> \<Psi>` have "(\<Psi>, \<lparr>\<nu>x\<rparr>P, \<lparr>\<nu>x\<rparr>Q) \<in> ?X"
	apply auto
	by(rule_tac x="x#xvec" in exI) auto
      thus ?thesis by simp
    next
      assume "\<not>(\<Psi>, P, Q) \<in> ?X"
      with `(\<Psi>, P, Q) \<in> ?X \<union> weakBisim` have "\<Psi> \<rhd> P \<approx> Q"
	by blast
      hence "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<approx> \<lparr>\<nu>x\<rparr>Q" using `x \<sharp> \<Psi>`
	by(rule weakBisimResPres)
      thus ?thesis
	by simp
    qed
  qed

  {
    fix \<Psi>  :: 'b
      and P  :: "('a, 'b, 'c) psi"
      and Q  :: "('a, 'b, 'c) psi"
      and \<Psi>' :: 'b

    assume "\<Psi> \<rhd> P \<approx> Q"

    hence "\<Psi> \<rhd> Q \<approx> P" by(rule weakBisimE)
    then obtain P' P'' where PChain: "\<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'"
                         and QimpP': "insertAssertion(extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P') \<Psi>"
                         and P'Chain: "\<Psi> \<otimes> \<Psi>' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P''"   
                         and "\<Psi> \<otimes> \<Psi>' \<rhd> Q \<approx> P''" using weakStatImp_def
      by(blast dest: weakBisimE)
    note PChain QimpP' P'Chain
    moreover from `\<Psi> \<otimes> \<Psi>' \<rhd> Q \<approx> P''` have "\<Psi> \<otimes> \<Psi>' \<rhd> P'' \<approx> Q" by(rule weakBisimE)
    ultimately have "\<exists>P' P''. \<Psi> \<rhd> P \<Longrightarrow>\<^sup>^\<^sub>\<tau> P' \<and> insertAssertion(extractFrame Q) \<Psi> \<hookrightarrow>\<^sub>F insertAssertion(extractFrame P') \<Psi> \<and>
                              \<Psi> \<otimes> \<Psi>' \<rhd> P' \<Longrightarrow>\<^sup>^\<^sub>\<tau> P'' \<and> \<Psi> \<otimes> \<Psi>' \<rhd> P'' \<approx> Q"
      by blast
  }
  moreover 
  {
    fix \<Psi> P Q A\<^isub>R \<Psi>\<^isub>R R
    assume PSimQ: "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
       and FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
       and "A\<^isub>R \<sharp>* \<Psi>"
       and "A\<^isub>R \<sharp>* P"
       and "A\<^isub>R \<sharp>* Q"
    hence "(\<Psi>, P \<parallel> R, Q \<parallel> R) \<in> ?X"
    proof -
      have "P \<parallel> R = \<lparr>\<nu>*[]\<rparr>(P \<parallel> R)" by simp
      moreover have "Q \<parallel> R = \<lparr>\<nu>*[]\<rparr>(Q \<parallel> R)" by simp
      moreover have "([]::name list) \<sharp>* \<Psi>" by simp
      moreover 
      {
	fix A\<^isub>R' \<Psi>\<^isub>R'

	assume FrR': "extractFrame R = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>"
	    and "A\<^isub>R' \<sharp>* \<Psi>"
	    and "A\<^isub>R' \<sharp>* P"
	    and "A\<^isub>R' \<sharp>* Q"
	obtain p where "(p \<bullet> A\<^isub>R') \<sharp>* A\<^isub>R"
                   and "(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>\<^isub>R'"
                   and "(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>"
                   and "(p \<bullet> A\<^isub>R') \<sharp>* P"
                   and "(p \<bullet> A\<^isub>R') \<sharp>* Q"
                   and S: "(set p) \<subseteq> (set A\<^isub>R') \<times> (set(p \<bullet> A\<^isub>R'))" and "distinctPerm p"
	  by(rule_tac c="(A\<^isub>R, \<Psi>, \<Psi>\<^isub>R', P, Q)" in name_list_avoiding) auto

        
	from `(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>\<^isub>R'` S have "\<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle> = \<langle>p \<bullet> A\<^isub>R', p \<bullet> \<Psi>\<^isub>R'\<rangle>"
	  by(simp add: frameChainAlpha)
        
	with FrR' have FrR'': "extractFrame R = \<langle>p \<bullet> A\<^isub>R', p \<bullet> \<Psi>\<^isub>R'\<rangle>" by simp
	with FrR `(p \<bullet> A\<^isub>R') \<sharp>* A\<^isub>R`
	obtain q where "p \<bullet> \<Psi>\<^isub>R' = (q::name prm) \<bullet> \<Psi>\<^isub>R" and S': "set q \<subseteq> (set A\<^isub>R) \<times> set(p \<bullet> A\<^isub>R')" and "distinctPerm q"
	  apply auto
	  apply(drule_tac sym) apply simp
	  by(drule_tac frameChainEq) auto
	from PSimQ have "(q \<bullet> (\<Psi> \<otimes> \<Psi>\<^isub>R)) \<rhd> (q \<bullet> P) \<approx> (q \<bullet> Q)"
	  by(rule weakBisimClosed)
	with `A\<^isub>R \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `A\<^isub>R \<sharp>* Q` `(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R') \<sharp>* P` `(p \<bullet> A\<^isub>R') \<sharp>* Q` S'
	have "\<Psi> \<otimes> (q \<bullet> \<Psi>\<^isub>R) \<rhd> P \<approx> Q" by(simp add: eqvts)
	hence "(p \<bullet> (\<Psi> \<otimes> (q \<bullet> \<Psi>\<^isub>R))) \<rhd> (p \<bullet> P) \<approx> (p \<bullet> Q)" by(rule weakBisimClosed)
	with `A\<^isub>R' \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P` `A\<^isub>R' \<sharp>* Q` `(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R') \<sharp>* P` `(p \<bullet> A\<^isub>R') \<sharp>* Q` S `distinctPerm p` `(p \<bullet> \<Psi>\<^isub>R') = q \<bullet> \<Psi>\<^isub>R` 
	have "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P \<approx> Q"
	  by(drule_tac sym) (simp add: eqvts)
      }
      ultimately show ?thesis
	by blast
    qed
    hence "(\<Psi>, P \<parallel> R, Q \<parallel> R) \<in> ?X \<union> weakBisim"
      by simp
  }
  note C1 = this

  have C2: "\<And>\<Psi> P Q xvec. \<lbrakk>(\<Psi>, P, Q) \<in> ?X \<union> weakBisim; (xvec::name list) \<sharp>* \<Psi>\<rbrakk> \<Longrightarrow> (\<Psi>, \<lparr>\<nu>*xvec\<rparr>P, \<lparr>\<nu>*xvec\<rparr>Q) \<in> ?X \<union> weakBisim"
  proof -
    fix \<Psi> P Q xvec
    assume "(\<Psi>, P, Q) \<in> ?X \<union> weakBisim"
    assume "(xvec::name list) \<sharp>* \<Psi>"
    thus "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>P, \<lparr>\<nu>*xvec\<rparr>Q) \<in> ?X \<union> weakBisim"
    proof(induct xvec)
      case Nil
      thus ?case using `(\<Psi>, P, Q) \<in> ?X \<union> weakBisim` by simp
    next
      case(Cons x xvec)
      thus ?case by(simp only: resChain.simps) (rule_tac Res, auto)
    qed
  qed

  {
    fix \<Psi> :: 'b
    and P :: "('a, 'b, 'c) psi"
    and Q :: "('a, 'b, 'c) psi"
    and R :: "('a, 'b, 'c) psi"
    and A\<^isub>R :: "name list"
    and \<Psi>\<^isub>R :: 'b

    assume "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
    and     FrR: "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>"
    and     "A\<^isub>R \<sharp>* \<Psi>"
    and     "A\<^isub>R \<sharp>* P"
    and     "A\<^isub>R \<sharp>* Q"

    
    have "(\<Psi>, P \<parallel> R, Q \<parallel> R) \<in> ?X" 
    proof -
      {
	fix A\<^isub>R' :: "name list"
        and \<Psi>\<^isub>R' :: 'b

        assume FrR': "extractFrame R = \<langle>A\<^isub>R', \<Psi>\<^isub>R'\<rangle>"
        and    "A\<^isub>R' \<sharp>* \<Psi>"
        and    "A\<^isub>R' \<sharp>* P"
        and    "A\<^isub>R' \<sharp>* Q"

        obtain p where "(p \<bullet> A\<^isub>R') \<sharp>* A\<^isub>R" and "(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>\<^isub>R'" and "(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>" and "(p \<bullet> A\<^isub>R') \<sharp>* P" and "(p \<bullet> A\<^isub>R') \<sharp>* Q"
                   and Sp: "(set p) \<subseteq> (set A\<^isub>R') \<times> (set(p \<bullet> A\<^isub>R'))" and "distinctPerm p"
    	  by(rule_tac c="(A\<^isub>R, \<Psi>, \<Psi>\<^isub>R', P, Q)" in name_list_avoiding) auto
	    
	from FrR' `(p \<bullet> A\<^isub>R') \<sharp>*  \<Psi>\<^isub>R'` Sp have "extractFrame R = \<langle>(p \<bullet> A\<^isub>R'), p \<bullet> \<Psi>\<^isub>R'\<rangle>"
	  by(simp add: frameChainAlpha eqvts)
	with FrR `(p \<bullet> A\<^isub>R') \<sharp>* A\<^isub>R` obtain q::"name prm" 
	  where Sq: "set q \<subseteq> set(p \<bullet> A\<^isub>R') \<times> set A\<^isub>R" and "distinctPerm q" and "\<Psi>\<^isub>R = q \<bullet> p \<bullet> \<Psi>\<^isub>R'"
	  by(force elim: frameChainEq)

	from `\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q` `\<Psi>\<^isub>R = q \<bullet> p \<bullet> \<Psi>\<^isub>R'` have "\<Psi> \<otimes> (q \<bullet> p \<bullet> \<Psi>\<^isub>R') \<rhd> P \<approx> Q" by simp
	hence "(q \<bullet> (\<Psi> \<otimes> (q \<bullet> p \<bullet> \<Psi>\<^isub>R'))) \<rhd> (q \<bullet> P) \<approx> (q \<bullet> Q)" by(rule weakBisimClosed)
	with Sq `A\<^isub>R \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>` `A\<^isub>R \<sharp>* P` `(p \<bullet> A\<^isub>R') \<sharp>* P` `A\<^isub>R \<sharp>* Q` `(p \<bullet> A\<^isub>R') \<sharp>* Q` `distinctPerm q`
	have "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R') \<rhd> P \<approx> Q" by(simp add: eqvts)
	hence "(p \<bullet> (\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R'))) \<rhd> (p \<bullet> P) \<approx> (p \<bullet> Q)" by(rule weakBisimClosed)
	with Sp `A\<^isub>R' \<sharp>* \<Psi>` `(p \<bullet> A\<^isub>R') \<sharp>* \<Psi>` `A\<^isub>R' \<sharp>* P` `(p \<bullet> A\<^isub>R') \<sharp>* P` `A\<^isub>R' \<sharp>* Q` `(p \<bullet> A\<^isub>R') \<sharp>* Q` `distinctPerm p`
	have "\<Psi> \<otimes> \<Psi>\<^isub>R' \<rhd> P \<approx> Q" by(simp add: eqvts)
      }
      thus ?thesis
	apply auto
	apply(rule_tac x="[]" in exI)
	by auto blast
    qed
  }
  note Goal = this
  with assms have "(\<Psi>, P \<parallel> R, Q \<parallel> R) \<in> ?X" by blast
  thus ?thesis
  proof(coinduct rule: weakBisimCoinduct)
    case(cStatImp \<Psi> PR QR)
    {
      fix xvec :: "name list"
      fix P Q R 
      assume A: "\<forall>A\<^isub>R \<Psi>\<^isub>R. extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle> \<and> A\<^isub>R \<sharp>* \<Psi> \<and> A\<^isub>R \<sharp>* P \<and> A\<^isub>R \<sharp>* Q \<longrightarrow> \<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
      {
        fix A\<^isub>R \<Psi>\<^isub>R
        assume "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* \<Psi>" and "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q"
        with A have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<lessapprox><weakBisim> Q" by(auto dest: weakBisimE)
      }
      moreover assume "xvec \<sharp>* \<Psi>"
      moreover have "eqvt weakBisim" by auto
      moreover note C1 C2 statEqWeakBisim
      ultimately have "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R) \<lessapprox><(?X \<union> weakBisim)> \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)" 
        by(rule weakStatImpParPres)
    }
    with `(\<Psi>, PR, QR) \<in> ?X` show ?case by auto
  next
    case(cSim \<Psi> PR QR)
    from `(\<Psi>, PR, QR) \<in> ?X`    
    obtain xvec P Q R A\<^isub>R \<Psi>\<^isub>R where PFrR: "PR = \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R)" and QFrR: "QR = \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)"
                               and "xvec \<sharp>* \<Psi>"
      by auto
    with `(\<Psi>, PR, QR) \<in> ?X` have "(\<Psi>, \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R), \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)) \<in> ?X" by simp
    hence "\<Psi> \<rhd> \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R) \<leadsto><(?X \<union> weakBisim)> \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)" using `xvec \<sharp>* \<Psi>`
    proof(induct xvec)
      case Nil
      from `(\<Psi>, \<lparr>\<nu>*[]\<rparr>(P \<parallel> R), \<lparr>\<nu>*[]\<rparr>(Q \<parallel> R)) \<in> ?X` have PRQR: "(\<Psi>, P \<parallel> R, Q \<parallel> R) \<in> ?X" by simp
      from PRQR have "\<And>A\<^isub>R \<Psi>\<^isub>R. \<lbrakk>extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>; A\<^isub>R \<sharp>* \<Psi>;  A\<^isub>R \<sharp>* P;  A\<^isub>R \<sharp>* Q\<rbrakk> \<Longrightarrow> (\<Psi> \<otimes> \<Psi>\<^isub>R, P, Q) \<in> weakBisim"
	by auto
      moreover note weakBisimEqvt
      moreover from `eqvt ?X` have "eqvt(?X \<union> weakBisim)" by auto
      moreover note weakBisimE(2) weakBisimE(4) weakBisimE(3) weakBisimE(1)
      moreover note C1 C2 
      ultimately have "\<Psi> \<rhd> P \<parallel> R \<leadsto><(?X \<union> weakBisim)> Q \<parallel> R" using statEqWeakBisim
	by(rule weakParPres)
      thus ?case by simp
    next
      case(Cons x xvec')
      from `(x#xvec') \<sharp>* \<Psi>` have "x \<sharp> \<Psi>" and "xvec' \<sharp>* \<Psi>" by simp+
      with `(\<Psi>, \<lparr>\<nu>*(x#xvec')\<rparr>P \<parallel> R, \<lparr>\<nu>*(x#xvec')\<rparr>Q \<parallel> R) \<in> ?X`
      have "(\<Psi>, \<lparr>\<nu>*(xvec')\<rparr>P \<parallel> R, \<lparr>\<nu>*(xvec')\<rparr>Q \<parallel> R) \<in> ?X"
	apply auto
	apply(subgoal_tac "\<exists>y yvec. xvec=y#yvec")
	apply(clarify)
	apply simp
	apply(simp add: psi.inject alpha)
	apply(clarify)
	apply(erule disjE)
	apply(erule disjE)
	apply(clarify)
	apply blast
	apply(clarify)
	apply(clarify)
	apply(simp add: eqvts)
	apply(rule_tac x="[(x, y)] \<bullet> yvec" in exI)
	apply(rule_tac x="[(x, y)] \<bullet> P" in exI)
	apply(rule_tac x="[(x, y)] \<bullet> Q" in exI)
	apply(rule_tac x="[(x, y)] \<bullet> R" in exI)
	apply(clarsimp)
	apply(rule conjI)
	apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of "[(x, y)]", THEN sym])
	apply simp
	apply(clarify)
	apply(erule_tac x="[(x, y)] \<bullet> A\<^isub>R" in allE)
	apply(erule_tac x="[(x, y)] \<bullet> \<Psi>\<^isub>R" in allE)
	apply(drule mp)
	apply(rule conjI)
	apply(rule_tac pi="[(x, y)]" in pt_bij4[OF pt_name_inst, OF at_name_inst])
	apply(simp add: eqvts)
	apply(rule conjI)
	apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of "[(x, y)]", THEN sym])
	apply simp
	apply(rule conjI)
	apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of "[(x, y)]", THEN sym])
	apply simp
	apply(subst pt_fresh_star_bij[OF pt_name_inst,OF at_name_inst, of "[(x, y)]", THEN sym])
	apply simp
	apply(drule_tac p="[(x, y)]" in weakBisimClosed)
	apply(simp add: eqvts)
	by(case_tac xvec) auto
      
      with `\<lbrakk>(\<Psi>, \<lparr>\<nu>*xvec'\<rparr>(P \<parallel> R), \<lparr>\<nu>*xvec'\<rparr>(Q \<parallel> R)) \<in> ?X; xvec' \<sharp>* \<Psi>\<rbrakk> \<Longrightarrow> \<Psi> \<rhd> \<lparr>\<nu>*xvec'\<rparr>(P \<parallel> R) \<leadsto><(?X \<union> weakBisim)> \<lparr>\<nu>*xvec'\<rparr>(Q \<parallel> R)` `xvec' \<sharp>* \<Psi>`
      have "\<Psi> \<rhd> \<lparr>\<nu>*xvec'\<rparr>(P \<parallel> R) \<leadsto><(?X \<union> weakBisim)> \<lparr>\<nu>*xvec'\<rparr>(Q \<parallel> R)" by blast
      moreover note `eqvt ?X` 
      moreover from `eqvt ?X` have "eqvt(?X \<union> weakBisim)" by auto
      moreover note `x \<sharp> \<Psi>`
      moreover have "?X \<union> weakBisim \<subseteq> ?X \<union> weakBisim" by simp
      ultimately have "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>*xvec'\<rparr>(P \<parallel> R)) \<leadsto><(?X \<union> weakBisim)> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>*xvec'\<rparr>(Q \<parallel> R))" using Res
	by(rule_tac weakResPres)
      thus ?case
	by simp
    qed
    with PFrR QFrR show ?case
      by simp
  next
    case(cExt \<Psi> PR QR \<Psi>')

    from `(\<Psi>, PR, QR) \<in> ?X`
    obtain xvec P Q R A\<^isub>R \<Psi>\<^isub>R where PFrR: "PR = \<lparr>\<nu>*xvec\<rparr>(P \<parallel> R)" and QFrR: "QR = \<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R)"
                               and "xvec \<sharp>* \<Psi>" and A: "\<forall>A\<^isub>R \<Psi>\<^isub>R. (extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle> \<and> A\<^isub>R \<sharp>* \<Psi> \<and> A\<^isub>R \<sharp>* P \<and> A\<^isub>R \<sharp>* Q) \<longrightarrow> \<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q"
      by auto
    
    obtain p where "(p \<bullet> xvec) \<sharp>* \<Psi>"
               and "(p \<bullet> xvec) \<sharp>* P"
               and "(p \<bullet> xvec) \<sharp>* Q"
               and "(p \<bullet> xvec) \<sharp>* R"
               and "(p \<bullet> xvec) \<sharp>* \<Psi>'"
               and S: "(set p) \<subseteq> (set xvec) \<times> (set(p \<bullet> xvec))" and "distinctPerm p"
      by(rule_tac c="(\<Psi>, P, Q, R, \<Psi>')" in name_list_avoiding) auto

    from `(p \<bullet> xvec) \<sharp>* P` `(p \<bullet> xvec) \<sharp>* R` S have "\<lparr>\<nu>*xvec\<rparr>(P \<parallel> R) = \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>(p \<bullet> (P \<parallel> R))"
      by(subst resChainAlpha) auto
    hence PRAlpha: "\<lparr>\<nu>*xvec\<rparr>(P \<parallel> R) = \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> P) \<parallel> (p \<bullet> R))"
      by(simp add: eqvts)

    from `(p \<bullet> xvec) \<sharp>* Q` `(p \<bullet> xvec) \<sharp>* R` S have "\<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R) = \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>(p \<bullet> (Q \<parallel> R))"
      by(subst resChainAlpha) auto
    hence QRAlpha: "\<lparr>\<nu>*xvec\<rparr>(Q \<parallel> R) = \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> Q) \<parallel> (p \<bullet> R))"
      by(simp add: eqvts)

    from `(p \<bullet> xvec) \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>'` have "(\<Psi> \<otimes> \<Psi>', \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> P) \<parallel> (p \<bullet> R)), \<lparr>\<nu>*(p \<bullet> xvec)\<rparr>((p \<bullet> Q) \<parallel> (p \<bullet> R))) \<in> ?X"
   proof(rule_tac C2="(\<Psi>, (p \<bullet> P), (p \<bullet> Q), R, \<Psi>', xvec, p \<bullet> xvec)" in XI', auto)
      fix A\<^isub>R \<Psi>\<^isub>R
      assume FrR: "extractFrame (p \<bullet> R) = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* \<Psi>" and "A\<^isub>R \<sharp>* \<Psi>'" and "A\<^isub>R \<sharp>* (p \<bullet> P)" and "A\<^isub>R \<sharp>* (p \<bullet> Q)"
      from FrR have "(p \<bullet> (extractFrame (p \<bullet> R))) = (p \<bullet> \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>)" by simp
      with `distinctPerm p` have "extractFrame R = \<langle>p \<bullet> A\<^isub>R, p \<bullet> \<Psi>\<^isub>R\<rangle>" by(simp add: eqvts)
      moreover from `A\<^isub>R \<sharp>* \<Psi>` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> \<Psi>)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S have "(p \<bullet> A\<^isub>R) \<sharp>* \<Psi>" by simp
      moreover from `A\<^isub>R \<sharp>* (p \<bullet> P)` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> p \<bullet> P)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `distinctPerm p` have "(p \<bullet> A\<^isub>R) \<sharp>* P" by simp
      moreover from `A\<^isub>R \<sharp>* (p \<bullet> Q)` have "(p \<bullet> A\<^isub>R) \<sharp>* (p \<bullet> p \<bullet> Q)" by(simp add: pt_fresh_star_bij[OF pt_name_inst, OF at_name_inst])
      with `distinctPerm p` have "(p \<bullet> A\<^isub>R) \<sharp>* Q" by simp
      ultimately have "\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P \<approx> Q" using A by blast
      hence "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> (p \<bullet> \<Psi>') \<rhd> P \<approx> Q" by(rule weakBisimE)
      moreover have "(\<Psi> \<otimes> (p \<bullet> \<Psi>\<^isub>R)) \<otimes> (p \<bullet> \<Psi>') \<simeq> (\<Psi> \<otimes> (p \<bullet> \<Psi>')) \<otimes> (p \<bullet> \<Psi>\<^isub>R)"
	by(metis Associativity Commutativity Composition AssertionStatEqTrans AssertionStatEqSym)
      ultimately have "(\<Psi> \<otimes> (p \<bullet> \<Psi>')) \<otimes> (p \<bullet> \<Psi>\<^isub>R) \<rhd> P \<approx> Q" 
	by(rule statEqWeakBisim)
      hence "(p \<bullet> ((\<Psi> \<otimes> (p \<bullet> \<Psi>')) \<otimes> (p \<bullet> \<Psi>\<^isub>R))) \<rhd> (p \<bullet> P) \<approx> (p \<bullet> Q)"
	by(rule weakBisimClosed)
      with `distinctPerm p` `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S show "(\<Psi> \<otimes> \<Psi>') \<otimes> \<Psi>\<^isub>R \<rhd> (p \<bullet> P) \<approx> (p \<bullet> Q)"
	by(simp add: eqvts)
    qed
    with PFrR QFrR PRAlpha QRAlpha show ?case by simp
  next
    case(cSym \<Psi> PR QR)
    thus ?case by(blast dest: weakBisimE)
  qed
qed

lemma weakBisimParPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<approx> Q"

  shows "\<Psi> \<rhd> P \<parallel> R \<approx> Q \<parallel> R"
proof -
  obtain A\<^isub>R \<Psi>\<^isub>R where "extractFrame R = \<langle>A\<^isub>R, \<Psi>\<^isub>R\<rangle>" and "A\<^isub>R \<sharp>* \<Psi>" and "A\<^isub>R \<sharp>* P" and "A\<^isub>R \<sharp>* Q"
    by(rule_tac C="(\<Psi>, P, Q)" in freshFrame) auto
  moreover from `\<Psi> \<rhd> P \<approx> Q` have "\<Psi> \<otimes> \<Psi>\<^isub>R \<rhd> P \<approx> Q" by(rule weakBisimE)
  ultimately show ?thesis by(rule_tac weakBisimParPresAux)
qed

end

end