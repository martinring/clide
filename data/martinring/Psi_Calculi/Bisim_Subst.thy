(* 
   Title: Psi-calculi   
   Author/Maintainer: Jesper Bengtson (jebe@itu.dk), 2012
*)
theory Bisim_Subst
  imports Bisim_Struct_Cong Close_Subst
begin

context env begin

abbreviation
  bisimSubstJudge ("_ \<rhd> _ \<sim>\<^sub>s _" [70, 70, 70] 65) where "\<Psi> \<rhd> P \<sim>\<^sub>s Q \<equiv> (\<Psi>, P, Q) \<in> closeSubst bisim"
abbreviation
  bisimSubstNilJudge ("_ \<sim>\<^sub>s _" [70, 70] 65) where "P \<sim>\<^sub>s Q \<equiv> SBottom' \<rhd> P \<sim>\<^sub>s Q"

lemmas bisimSubstClosed[eqvt] = closeSubstClosed[OF bisimEqvt]
lemmas bisimSubstEqvt[simp] = closeSubstEqvt[OF bisimEqvt]

lemma bisimSubstOutputPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   M :: 'a
  and   N :: 'a
  
  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"

  shows "\<Psi> \<rhd> M\<langle>N\<rangle>.P \<sim>\<^sub>s M\<langle>N\<rangle>.Q"
using assms
by(fastsimp intro: closeSubstI closeSubstE bisimOutputPres)


lemma seqSubstInputChain[simp]:
  fixes xvec :: "name list"
  and   N    :: "'a"
  and   P    :: "('a, 'b, 'c) psi"
  and   \<sigma>    :: "(name list \<times> 'a list) list"

  assumes "xvec \<sharp>* \<sigma>"

  shows "seqSubs' (inputChain xvec N P) \<sigma> = inputChain xvec (substTerm.seqSubst N \<sigma>) (seqSubs P \<sigma>)"
using assms
by(induct xvec) auto

lemma bisimSubstInputPres:
  fixes \<Psi>    :: 'b
  and   P    :: "('a, 'b, 'c) psi"
  and   Q    :: "('a, 'b, 'c) psi"
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a

  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"
  and     "xvec \<sharp>* \<Psi>"
  and     "distinct xvec"

  shows "\<Psi> \<rhd> M\<lparr>\<lambda>*xvec N\<rparr>.P \<sim>\<^sub>s M\<lparr>\<lambda>*xvec N\<rparr>.Q"
proof(rule_tac closeSubstI)
  fix \<sigma>
  assume "wellFormedSubst(\<sigma>::(name list \<times> 'a list) list)"
  obtain p where "(p \<bullet> xvec) \<sharp>* \<sigma>"
             and "(p \<bullet> xvec) \<sharp>* P" and "(p \<bullet> xvec) \<sharp>* Q" and "(p \<bullet> xvec) \<sharp>* \<Psi>" and "(p \<bullet> xvec) \<sharp>* N"
             and S: "set p \<subseteq> set xvec \<times> set (p \<bullet> xvec)"
      by(rule_tac c="(\<sigma>, P, Q, \<Psi>, N)" in name_list_avoiding) auto
    
  from `\<Psi> \<rhd> P \<sim>\<^sub>s Q` have "(p \<bullet> \<Psi>) \<rhd> (p \<bullet> P) \<sim>\<^sub>s (p \<bullet> Q)"
    by(rule bisimSubstClosed)
  with `xvec \<sharp>* \<Psi>` `(p \<bullet> xvec) \<sharp>* \<Psi>` S have "\<Psi> \<rhd> (p \<bullet> P) \<sim>\<^sub>s (p \<bullet> Q)"
    by simp

  {
    fix Tvec :: "'a list"
    from `\<Psi> \<rhd> (p \<bullet> P) \<sim>\<^sub>s (p \<bullet> Q)` `wellFormedSubst \<sigma>` have "\<Psi> \<rhd> (p \<bullet> P)[<\<sigma>>] \<sim>\<^sub>s (p \<bullet> Q)[<\<sigma>>]"
      by(rule closeSubstUnfold)
    moreover assume "length xvec = length Tvec" and "distinct xvec"
    ultimately have "\<Psi> \<rhd> ((p \<bullet> P)[<\<sigma>>])[(p \<bullet> xvec)::=Tvec] \<sim> ((p \<bullet> Q)[<\<sigma>>])[(p \<bullet> xvec)::=Tvec]" 
      by(drule_tac closeSubstE[where \<sigma>="[((p \<bullet> xvec), Tvec)]"]) auto
  }

  with `(p \<bullet> xvec) \<sharp>* \<sigma>` `distinct xvec`
  have "\<Psi> \<rhd> (M\<lparr>\<lambda>*(p \<bullet> xvec) (p \<bullet> N)\<rparr>.(p \<bullet> P))[<\<sigma>>] \<sim> (M\<lparr>\<lambda>*(p \<bullet> xvec) (p \<bullet> N)\<rparr>.(p \<bullet> Q))[<\<sigma>>]"
    by(force intro: bisimInputPres)
  moreover from `(p \<bullet> xvec) \<sharp>* N` `(p \<bullet> xvec) \<sharp>* P` S have "M\<lparr>\<lambda>*(p \<bullet> xvec) (p \<bullet> N)\<rparr>.(p \<bullet> P) = M\<lparr>\<lambda>*xvec N\<rparr>.P" 
    apply(simp add: psi.inject) by(rule inputChainAlpha[symmetric]) auto
  moreover from `(p \<bullet> xvec) \<sharp>* N` `(p \<bullet> xvec) \<sharp>* Q` S have "M\<lparr>\<lambda>*(p \<bullet> xvec) (p \<bullet> N)\<rparr>.(p \<bullet> Q) = M\<lparr>\<lambda>*xvec N\<rparr>.Q"
    apply(simp add: psi.inject) by(rule inputChainAlpha[symmetric]) auto
  ultimately show "\<Psi> \<rhd> (M\<lparr>\<lambda>*xvec N\<rparr>.P)[<\<sigma>>] \<sim> (M\<lparr>\<lambda>*xvec N\<rparr>.Q)[<\<sigma>>]"
    by force
qed

lemma bisimSubstCasePresAux:
  fixes \<Psi>   :: 'b
  and   CsP :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   CsQ :: "('c \<times> ('a, 'b, 'c) psi) list"
  
  assumes C1: "\<And>\<phi> P. (\<phi>, P) mem CsP \<Longrightarrow> \<exists>Q. (\<phi>, Q) mem CsQ \<and> guarded Q \<and> \<Psi> \<rhd> P \<sim>\<^sub>s Q"
  and     C2: "\<And>\<phi> Q. (\<phi>, Q) mem CsQ \<Longrightarrow> \<exists>P. (\<phi>, P) mem CsP \<and> guarded P \<and> \<Psi> \<rhd> P \<sim>\<^sub>s Q"

  shows "\<Psi> \<rhd> Cases CsP \<sim>\<^sub>s Cases CsQ"
proof -
  {
    fix \<sigma> :: "(name list \<times> 'a list) list"

    assume "wellFormedSubst \<sigma>"

    have "\<Psi> \<rhd> Cases(caseListSeqSubst CsP \<sigma>) \<sim> Cases(caseListSeqSubst CsQ \<sigma>)"
    proof(rule bisimCasePres)
      fix \<phi> P
      assume "(\<phi>, P) mem (caseListSeqSubst CsP \<sigma>)"
      then obtain \<phi>' P' where "(\<phi>', P') mem CsP" and "\<phi> = substCond.seqSubst \<phi>' \<sigma>" and PeqP': "P = (P'[<\<sigma>>])"
	by(induct CsP) force+
      from `(\<phi>', P') mem CsP` obtain Q' where "(\<phi>', Q') mem CsQ" and "guarded Q'" and "\<Psi> \<rhd> P' \<sim>\<^sub>s Q'" by(blast dest: C1)
      from `(\<phi>', Q') mem CsQ` `\<phi> = substCond.seqSubst \<phi>' \<sigma>` obtain Q where "(\<phi>, Q) mem (caseListSeqSubst CsQ \<sigma>)" and "Q = Q'[<\<sigma>>]"
	by(induct CsQ) auto
      with PeqP' `guarded Q'` `\<Psi> \<rhd> P' \<sim>\<^sub>s Q'` `wellFormedSubst \<sigma>` show "\<exists>Q. (\<phi>, Q) mem (caseListSeqSubst CsQ \<sigma>) \<and> guarded Q \<and> \<Psi> \<rhd> P \<sim> Q"
	by(blast dest: closeSubstE guardedSeqSubst)
    next
      fix \<phi> Q
      assume "(\<phi>, Q) mem (caseListSeqSubst CsQ \<sigma>)"
      then obtain \<phi>' Q' where "(\<phi>', Q') mem CsQ" and "\<phi> = substCond.seqSubst \<phi>' \<sigma>" and QeqQ': "Q = Q'[<\<sigma>>]"
	by(induct CsQ) force+
      from `(\<phi>', Q') mem CsQ` obtain P' where "(\<phi>', P') mem CsP" and "guarded P'" and "\<Psi> \<rhd> P' \<sim>\<^sub>s Q'" by(blast dest: C2)
      from `(\<phi>', P') mem CsP` `\<phi> = substCond.seqSubst \<phi>' \<sigma>` obtain P where "(\<phi>, P) mem (caseListSeqSubst CsP \<sigma>)" and "P = P'[<\<sigma>>]"
	by(induct CsP) auto
      with QeqQ' `guarded P'` `\<Psi> \<rhd> P' \<sim>\<^sub>s Q'` `wellFormedSubst \<sigma>`  show "\<exists>P. (\<phi>, P) mem (caseListSeqSubst CsP \<sigma>) \<and> guarded P \<and> \<Psi> \<rhd> P \<sim> Q"
	by(blast dest: closeSubstE guardedSeqSubst)
    qed
  }
  thus ?thesis
    by(rule_tac closeSubstI) auto
qed

lemma bisimSubstReflexive:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> P \<sim>\<^sub>s P"
by(auto intro: closeSubstI bisimReflexive)

lemma bisimSubstTransitive:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"
  and     "\<Psi> \<rhd> Q \<sim>\<^sub>s R"

  shows "\<Psi> \<rhd> P \<sim>\<^sub>s R"
using assms
by(auto intro: closeSubstI closeSubstE bisimTransitive)

lemma bisimSubstSymmetric:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"

  shows "\<Psi> \<rhd> Q \<sim>\<^sub>s P"
using assms
by(auto intro: closeSubstI closeSubstE bisimE)
(*
lemma bisimSubstCasePres:
  fixes \<Psi>   :: 'b
  and   CsP :: "('c \<times> ('a, 'b, 'c) psi) list"
  and   CsQ :: "('c \<times> ('a, 'b, 'c) psi) list"
  
  assumes "length CsP = length CsQ"
  and     C: "\<And>(i::nat) \<phi> P \<phi>' Q. \<lbrakk>i <= length CsP; (\<phi>, P) = nth CsP i; (\<phi>', Q) = nth CsQ i\<rbrakk> \<Longrightarrow> \<phi> = \<phi>' \<and> \<Psi> \<rhd> P \<sim> Q"

  shows "\<Psi> \<rhd> Cases CsP \<sim>\<^sub>s Cases CsQ"
proof -
  {
    fix \<phi> 
    and P

    assume "(\<phi>, P) mem CsP"

    with `length CsP = length CsQ` have "\<exists>Q. (\<phi>, Q) mem CsQ \<and> \<Psi> \<rhd> P \<sim>\<^sub>s Q"
      apply(induct n=="length CsP" arbitrary: CsP CsQ rule: nat.induct)
      apply simp
      apply simp
      apply auto

  }
using `length CsP = length CsQ`
proof(induct n=="length CsP" rule: nat.induct)
  case zero
  thus ?case by(fastsimp intro: bisimSubstReflexive)
next
  case(Suc n)
next
apply auto
apply(blast intro: bisimSubstReflexive)
apply auto
apply(simp add: nth.simps)
apply(auto simp add: nth.simps)
apply blast
apply(rule_tac bisimSubstCasePresAux)
apply auto
*)
lemma bisimSubstParPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"
  
  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"

  shows "\<Psi> \<rhd> P \<parallel> R \<sim>\<^sub>s Q \<parallel> R"
using assms
by(fastsimp intro: closeSubstI closeSubstE bisimParPres)

lemma bisimSubstResPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   x :: name

  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"
  and     "x \<sharp> \<Psi>"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>P \<sim>\<^sub>s \<lparr>\<nu>x\<rparr>Q"
proof(rule_tac closeSubstI)
  fix \<sigma> :: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> P" and "y \<sharp> Q" and "y \<sharp> \<sigma>"
    by(generate_fresh "name") (auto simp add: fresh_prod)

  from `\<Psi> \<rhd> P \<sim>\<^sub>s Q` have "([(x, y)] \<bullet> \<Psi>) \<rhd> ([(x, y)] \<bullet> P) \<sim>\<^sub>s ([(x, y)] \<bullet> Q)"
    by(rule bisimSubstClosed)
  with `x \<sharp> \<Psi>` `y \<sharp> \<Psi>` have "\<Psi> \<rhd> ([(x, y)] \<bullet> P) \<sim>\<^sub>s ([(x, y)] \<bullet> Q)"
    by simp
  hence "\<Psi> \<rhd> ([(x, y)] \<bullet> P)[<\<sigma>>] \<sim> ([(x, y)] \<bullet> Q)[<\<sigma>>]" using `wellFormedSubst \<sigma>` 
    by(rule closeSubstE)
  hence "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>(([(x, y)] \<bullet> P)[<\<sigma>>]) \<sim> \<lparr>\<nu>y\<rparr>(([(x, y)] \<bullet> Q)[<\<sigma>>])" using `y \<sharp> \<Psi>`
    by(rule bisimResPres)
  with `y \<sharp> P` `y \<sharp> Q` `y \<sharp> \<sigma>`
  show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>P)[<\<sigma>>] \<sim> (\<lparr>\<nu>x\<rparr>Q)[<\<sigma>>]"
    by(simp add: alphaRes)
qed

lemma bisimSubstBangPres:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
 
  assumes "\<Psi> \<rhd> P \<sim>\<^sub>s Q"
  and     "guarded P"
  and     "guarded Q"

  shows "\<Psi> \<rhd> !P \<sim>\<^sub>s !Q"
using assms
by(fastsimp intro: closeSubstI closeSubstE bisimBangPres guardedSeqSubst)

lemma substNil[simp]:
  fixes xvec :: "name list"
  and   Tvec :: "'a list"

  assumes "wellFormedSubst \<sigma>"
  and     "distinct xvec"

  shows "(\<zero>[<\<sigma>>]) = \<zero>"
using assms
by simp

lemma bisimSubstParNil:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> P \<parallel> \<zero> \<sim>\<^sub>s P" 
by(fastsimp intro: closeSubstI bisimParNil)

lemma bisimSubstParComm:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> P \<parallel> Q \<sim>\<^sub>s Q \<parallel> P"
apply(rule closeSubstI)
by(fastsimp intro: closeSubstI bisimParComm)

lemma bisimSubstParAssoc:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"
  and   R :: "('a, 'b, 'c) psi"

  shows "\<Psi> \<rhd> (P \<parallel> Q) \<parallel> R \<sim>\<^sub>s P \<parallel> (Q \<parallel> R)"
apply(rule closeSubstI)
by(fastsimp intro: closeSubstI bisimParAssoc)

lemma bisimSubstResNil:
  fixes \<Psi> :: 'b
  and   x :: name

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>\<zero> \<sim>\<^sub>s \<zero>"
proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> \<sigma>"
    by(generate_fresh "name") (auto simp add: fresh_prod)
  have "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>\<zero> \<sim> \<zero>" by(rule bisimResNil)
  with `y \<sharp> \<sigma>` `wellFormedSubst \<sigma>`  show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>\<zero>)[<\<sigma>>] \<sim> \<zero>[<\<sigma>>]"
    by(subst alphaRes[of y]) auto
qed

lemma seqSubst2:
  fixes x :: name
  and   P :: "('a, 'b, 'c) psi"

  assumes "wellFormedSubst \<sigma>"
  and     "x \<sharp> \<sigma>"
  and     "x \<sharp> P"

  shows "x \<sharp> P[<\<sigma>>]"
using assms
by(induct \<sigma> arbitrary: P, auto) (blast dest: subst2)

notation substTerm.seqSubst ("_[<_>]" [100, 100] 100)

lemma bisimSubstScopeExt:
  fixes \<Psi> :: 'b
  and   x :: name
  and   P :: "('a, 'b, 'c) psi"
  and   Q :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> P"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(P \<parallel> Q) \<sim>\<^sub>s P \<parallel> \<lparr>\<nu>x\<rparr>Q" 
proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> \<sigma>" and "y \<sharp> P" and "y \<sharp> Q"
    by(generate_fresh "name") (auto simp add: fresh_prod)
  moreover from `wellFormedSubst \<sigma>`  `y \<sharp> \<sigma>` `y \<sharp> P` have "y \<sharp> P[<\<sigma>>]"
    by(rule seqSubst2)
  hence "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>((P[<\<sigma>>]) \<parallel> (([(x, y)] \<bullet> Q)[<\<sigma>>])) \<sim> (P[<\<sigma>>]) \<parallel> \<lparr>\<nu>y\<rparr>(([(x, y)] \<bullet> Q)[<\<sigma>>])"
    by(rule bisimScopeExt)
  with `x \<sharp> P` `y \<sharp> P` `y \<sharp> Q` `y \<sharp> \<sigma>` show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>(P \<parallel> Q))[<\<sigma>>] \<sim> (P \<parallel> \<lparr>\<nu>x\<rparr>Q)[<\<sigma>>]"
    apply(subst alphaRes[of y], simp)
    apply(subst alphaRes[of y Q], simp)
    by(simp add: eqvts)
qed  

lemma bisimSubstCasePushRes:
  fixes x  :: name
  and   \<Psi>  :: 'b
  and   Cs :: "('c \<times> ('a, 'b, 'c) psi) list"

  assumes "x \<sharp> map fst Cs"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(Cases Cs) \<sim>\<^sub>s Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) Cs"
proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> \<sigma>" and "y \<sharp> Cs"
    by(generate_fresh "name") (auto simp add: fresh_prod)
  
  {
    fix x    :: name
    and Cs   :: "('c \<times> ('a, 'b, 'c) psi) list"
    and \<sigma>    :: "(name list \<times> 'a list) list"

    assume "x \<sharp> \<sigma>"

    hence "(Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) Cs)[<\<sigma>>] = Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) (caseListSeqSubst Cs \<sigma>)"
      by(induct Cs) auto
  }
  note C1 = this

  {
    fix x    :: name
    and y    :: name
    and Cs   :: "('c \<times> ('a, 'b, 'c) psi) list"

    assume "x \<sharp> map fst Cs"
    and    "y \<sharp> map fst Cs"
    and    "y \<sharp> Cs"

    hence "(Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) Cs) = Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>y\<rparr>P)) ([(x, y)] \<bullet> Cs)"
      by(induct Cs) (auto simp add: fresh_list_cons alphaRes)
  }
  note C2 = this

  from `y \<sharp> Cs` have "y \<sharp> map fst Cs" by(induct Cs) (auto simp add: fresh_list_cons fresh_list_nil)
  from `y \<sharp> Cs` `y \<sharp> \<sigma>` `x \<sharp> map fst Cs` `wellFormedSubst \<sigma>`  have "y \<sharp> map fst (caseListSeqSubst ([(x, y)] \<bullet> Cs) \<sigma>)"
    by(induct Cs) (auto intro: substCond.seqSubst2 simp add: fresh_list_cons fresh_list_nil fresh_prod)
  hence "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>(Cases(caseListSeqSubst ([(x, y)] \<bullet> Cs) \<sigma>)) \<sim> Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>y\<rparr>P)) (caseListSeqSubst ([(x, y)] \<bullet> Cs) \<sigma>)"
    by(rule bisimCasePushRes)

  with `y \<sharp> Cs` `x \<sharp> map fst Cs` `y \<sharp> map fst Cs` `y \<sharp> \<sigma>` `wellFormedSubst \<sigma>` 
  show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>(Cases Cs))[<\<sigma>>] \<sim> (Cases map (\<lambda>(\<phi>, P). (\<phi>, \<lparr>\<nu>x\<rparr>P)) Cs)[<\<sigma>>]"
    apply(subst C2[of x Cs y])
    apply assumption+
    apply(subst C1)
    apply assumption+
    apply(subst alphaRes[of y], simp)
    by(simp add: eqvts)
qed

lemma bisimSubstOutputPushRes:
  fixes x :: name
  and   \<Psi> :: 'b
  and   M :: 'a
  and   N :: 'a
  and   P :: "('a, 'b, 'c) psi"

  assumes "x \<sharp> M"
  and     "x \<sharp> N"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(M\<langle>N\<rangle>.P) \<sim>\<^sub>s M\<langle>N\<rangle>.\<lparr>\<nu>x\<rparr>P"
proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> \<sigma>" and "y \<sharp> P" and "y \<sharp> M" and "y \<sharp> N"
    by(generate_fresh "name") (auto simp add: fresh_prod)
  from `wellFormedSubst \<sigma>`  `y \<sharp> M` `y \<sharp> \<sigma>` have "y \<sharp> M[<\<sigma>>]" by auto
  moreover from `wellFormedSubst \<sigma>`  `y \<sharp> N` `y \<sharp> \<sigma>` have "y \<sharp> N[<\<sigma>>]" by auto
  ultimately have "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>((M[<\<sigma>>])\<langle>(N[<\<sigma>>])\<rangle>.(([(x, y)] \<bullet> P)[<\<sigma>>])) \<sim> (M[<\<sigma>>])\<langle>(N[<\<sigma>>])\<rangle>.(\<lparr>\<nu>y\<rparr>(([(x, y)] \<bullet> P)[<\<sigma>>]))"
    by(rule bisimOutputPushRes)
  with `y \<sharp> M` `y \<sharp> N` `y \<sharp> P` `x \<sharp> M` `x \<sharp> N` `y \<sharp> \<sigma>` `wellFormedSubst \<sigma>` 
  show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>(M\<langle>N\<rangle>.P))[<\<sigma>>] \<sim> (M\<langle>N\<rangle>.\<lparr>\<nu>x\<rparr>P)[<\<sigma>>]"
    apply(subst alphaRes[of y], simp)
    apply(subst alphaRes[of y P], simp)
    by(simp add: eqvts)
qed

lemma bisimSubstInputPushRes:
  fixes x    :: name
  and   \<Psi>    :: 'b
  and   M    :: 'a
  and   xvec :: "name list"
  and   N    :: 'a

  assumes "x \<sharp> M"
  and     "x \<sharp> xvec"
  and     "x \<sharp> N"

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(M\<lparr>\<lambda>*xvec N\<rparr>.P) \<sim>\<^sub>s M\<lparr>\<lambda>*xvec N\<rparr>.\<lparr>\<nu>x\<rparr>P"
proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"

  assume "wellFormedSubst \<sigma>"
  obtain y::name where "y \<sharp> \<Psi>" and "y \<sharp> \<sigma>" and "y \<sharp> P" and "y \<sharp> M" and "y \<sharp> xvec" and "y \<sharp> N"
    by(generate_fresh "name") (auto simp add: fresh_prod)
  obtain p::"name prm" where "(p \<bullet> xvec) \<sharp>* N" and  "(p \<bullet> xvec) \<sharp>* P" and "x \<sharp> (p \<bullet> xvec)" and "y \<sharp> (p \<bullet> xvec)" and "(p \<bullet> xvec) \<sharp>* \<sigma>"
                         and S: "set p \<subseteq> set xvec \<times> set(p \<bullet> xvec)"
   by(rule_tac c="(N, P, x, y, \<sigma>)" in name_list_avoiding) auto
    
  from `wellFormedSubst \<sigma>` `y \<sharp> M` `y \<sharp> \<sigma> ` have "y \<sharp> M[<\<sigma>>]" by auto
  moreover note `y \<sharp> (p \<bullet> xvec)`
  moreover from `y \<sharp> N` have "(p \<bullet> y) \<sharp> (p \<bullet> N)" by(simp add: pt_fresh_bij[OF pt_name_inst, OF at_name_inst])
  with `y \<sharp> xvec` `y \<sharp> (p \<bullet> xvec)` S have "y \<sharp> p \<bullet> N" by simp
  with `wellFormedSubst \<sigma>` have "y \<sharp> (p \<bullet> N)[<\<sigma>>]" using `y \<sharp> \<sigma>` by auto
  ultimately have "\<Psi> \<rhd> \<lparr>\<nu>y\<rparr>((M[<\<sigma>>])\<lparr>\<lambda>*(p \<bullet> xvec) ((p \<bullet> N)[<\<sigma>>])\<rparr>.(([(x, y)] \<bullet> (p \<bullet> P))[<\<sigma>>])) \<sim> (M[<\<sigma>>])\<lparr>\<lambda>*(p \<bullet> xvec) ((p \<bullet> N)[<\<sigma>>])\<rparr>.(\<lparr>\<nu>y\<rparr>(([(x, y)] \<bullet> p \<bullet> P)[<\<sigma>>]))"
    by(rule bisimInputPushRes)
  with `y \<sharp> M` `y \<sharp> N` `y \<sharp> P` `x \<sharp> M` `x \<sharp> N` `y \<sharp> xvec` `x \<sharp> xvec` `(p \<bullet> xvec) \<sharp>* N` `(p \<bullet> xvec) \<sharp>* P` 
       `x \<sharp> (p \<bullet> xvec)` `y \<sharp> (p \<bullet> xvec)` `y \<sharp> \<sigma>` `(p \<bullet> xvec) \<sharp>* \<sigma>` S `wellFormedSubst \<sigma>`
  show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>(M\<lparr>\<lambda>*xvec N\<rparr>.P))[<\<sigma>>] \<sim> (M\<lparr>\<lambda>*xvec N\<rparr>.\<lparr>\<nu>x\<rparr>P)[<\<sigma>>]"
    apply(subst inputChainAlpha')
    apply assumption+
    apply(subst inputChainAlpha'[of p xvec])
    apply(simp add: abs_fresh_star)
    apply assumption+
    apply(simp add: eqvts)
    apply(subst alphaRes[of y], simp)
    apply(simp add: inputChainFresh)
    apply(simp add: freshChainSimps)
    apply(subst alphaRes[of y "(p \<bullet> P)"])
    apply(simp add: freshChainSimps)
    by(simp add: freshChainSimps eqvts)
qed

lemma bisimSubstResComm:
  fixes x :: name
  and   y :: name

  shows "\<Psi> \<rhd> \<lparr>\<nu>x\<rparr>(\<lparr>\<nu>y\<rparr>P) \<sim>\<^sub>s \<lparr>\<nu>y\<rparr>(\<lparr>\<nu>x\<rparr>P)"
proof(case_tac "x = y")
  assume "x = y"
  thus ?thesis by(force intro: bisimSubstReflexive)
next
  assume "x \<noteq> y"
  show ?thesis
  proof(rule closeSubstI)
  fix \<sigma>:: "(name list \<times> 'a list) list"
  assume "wellFormedSubst \<sigma>"


    obtain x'::name where "x' \<sharp>  \<Psi>" and "x' \<sharp> \<sigma>" and "x' \<sharp> P" and "x \<noteq> x'" and "y \<noteq> x'"
      by(generate_fresh "name") (auto simp add: fresh_prod)
    obtain y'::name where "y' \<sharp>  \<Psi>" and "y' \<sharp> \<sigma>" and "y' \<sharp> P" and "x \<noteq> y'" and "y \<noteq> y'" and "x' \<noteq> y'"
      by(generate_fresh "name") (auto simp add: fresh_prod)

    have "\<Psi> \<rhd> \<lparr>\<nu>x'\<rparr>(\<lparr>\<nu>y'\<rparr>(([(x, x')] \<bullet> [(y, y')] \<bullet> P)[<\<sigma>>])) \<sim> \<lparr>\<nu>y'\<rparr>(\<lparr>\<nu>x'\<rparr>(([(x, x')] \<bullet> [(y, y')] \<bullet> P)[<\<sigma>>]))"
      by(rule bisimResComm)
    moreover from `x' \<sharp> P` `y' \<sharp> P` `x \<noteq> y'` `x' \<noteq> y'` have "\<lparr>\<nu>x\<rparr>(\<lparr>\<nu>y\<rparr>P) = \<lparr>\<nu>x'\<rparr>(\<lparr>\<nu>y'\<rparr>(([(x, x')] \<bullet> [(y, y')] \<bullet> P)))"
      apply(subst alphaRes[of y' P], simp)
      by(subst alphaRes[of x']) (auto simp add: abs_fresh fresh_left calc_atm eqvts)
    moreover from `x' \<sharp> P` `y' \<sharp> P` `y \<noteq> x'` `x \<noteq> y'` `x' \<noteq> y'` `x \<noteq> x'` `x \<noteq> y` have "\<lparr>\<nu>y\<rparr>(\<lparr>\<nu>x\<rparr>P) = \<lparr>\<nu>y'\<rparr>(\<lparr>\<nu>x'\<rparr>(([(x, x')] \<bullet> [(y, y')] \<bullet> P)))"
      apply(subst alphaRes[of x' P], simp)
      apply(subst alphaRes[of y'], simp add: abs_fresh fresh_left calc_atm) 
      apply(simp add: eqvts calc_atm)
      by(subst perm_compose) (simp add: calc_atm)

    ultimately show "\<Psi> \<rhd> (\<lparr>\<nu>x\<rparr>(\<lparr>\<nu>y\<rparr>P))[<\<sigma>>] \<sim> (\<lparr>\<nu>y\<rparr>(\<lparr>\<nu>x\<rparr>P))[<\<sigma>>]" 
      using `wellFormedSubst \<sigma>`  `x' \<sharp> \<sigma>` `y' \<sharp> \<sigma>`
      by simp
  qed
qed

lemma bisimSubstExtBang:
  fixes \<Psi> :: 'b
  and   P :: "('a, 'b, 'c) psi"
  
  assumes "guarded P"

  shows "\<Psi> \<rhd> !P \<sim>\<^sub>s P \<parallel> !P"
using assms
by(fastsimp intro: closeSubstI bangExt guardedSeqSubst)

lemma structCongBisimSubst:
  fixes P :: "('a, 'b, 'c) psi"  
  and   Q :: "('a, 'b, 'c) psi"

  assumes "P \<equiv>\<^sub>s Q"

  shows "P \<sim>\<^sub>s Q"
using assms
by(induct rule: structCong.induct)
  (auto intro: bisimSubstReflexive bisimSubstSymmetric bisimSubstTransitive bisimSubstParComm bisimSubstParAssoc bisimSubstParNil bisimSubstResNil bisimSubstResComm bisimSubstScopeExt bisimSubstCasePushRes bisimSubstInputPushRes bisimSubstOutputPushRes bisimSubstExtBang)

end

end
