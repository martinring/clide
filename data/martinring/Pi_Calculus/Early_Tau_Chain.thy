(* 
   Title: The pi-calculus   
   Author/Maintainer: Jesper Bengtson (jebe.dk), 2012
*)
theory Early_Tau_Chain
  imports Early_Semantics
begin

abbreviation tauChain :: "pi \<Rightarrow> pi \<Rightarrow> bool" ("_ \<Longrightarrow>\<^isub>\<tau> _" [80, 80] 80)
  where "P \<Longrightarrow>\<^isub>\<tau> P' \<equiv> (P, P') \<in> {(P, P') | P P'. P \<longmapsto>\<tau> \<prec> P'}^*"

lemma tauActTauChain:
  fixes P  :: pi
  and   P' :: pi

  assumes "P \<longmapsto>\<tau> \<prec> P'"

  shows "P \<Longrightarrow>\<^isub>\<tau> P'"
using assms
by auto

lemma tauChainAddTau[intro]:
  fixes P   :: pi
  and   P'  :: pi
  and   P'' :: pi

  shows "P \<Longrightarrow>\<^isub>\<tau> P' \<Longrightarrow> P' \<longmapsto>\<tau> \<prec> P'' \<Longrightarrow> P \<Longrightarrow>\<^isub>\<tau> P''" 
  and "P \<longmapsto>\<tau> \<prec> P' \<Longrightarrow> P' \<Longrightarrow>\<^isub>\<tau> P'' \<Longrightarrow> P \<Longrightarrow>\<^isub>\<tau> P''"
by(auto dest: tauActTauChain)

lemma tauChainInduct[consumes 1, case_names id ih]:
  fixes P  :: pi
  and   P' :: pi

  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     "F P"
  and     "\<And>P'' P'''. \<lbrakk>P \<Longrightarrow>\<^isub>\<tau> P''; P'' \<longmapsto>\<tau> \<prec> P'''; F P''\<rbrakk> \<Longrightarrow> F P'''"

  shows "F P'"
using assms
by(drule_tac rtrancl_induct) auto

lemma eqvtChainI:
  fixes P    :: pi
  and   P'   :: pi
  and   perm :: "name prm"

  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"

  shows "(perm \<bullet> P) \<Longrightarrow>\<^isub>\<tau> (perm \<bullet> P')"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P'' P''')
  have "P \<Longrightarrow>\<^isub>\<tau> P''" and "P'' \<longmapsto> \<tau> \<prec> P'''" by fact+
  hence "(perm \<bullet> P'') \<longmapsto>\<tau> \<prec> (perm \<bullet> P''')" by(drule_tac TransitionsEarly.eqvt) auto
  moreover have "(perm \<bullet> P) \<Longrightarrow>\<^isub>\<tau> (perm \<bullet> P'')" by fact
  ultimately show ?case by(force dest: tauActTauChain)
qed

lemma eqvtChainE:
  fixes perm :: "name prm"
  and   P    :: pi
  and   P'   :: pi

  assumes Trans: "(perm \<bullet> P) \<Longrightarrow>\<^isub>\<tau> (perm \<bullet> P')"

  shows   "P \<Longrightarrow>\<^isub>\<tau> P'"
proof -
  have "rev perm \<bullet> (perm \<bullet> P) = P" by(simp add: pt_rev_pi[OF pt_name_inst, OF at_name_inst])
  moreover have "rev perm \<bullet> (perm \<bullet> P') = P'" by(simp add: pt_rev_pi[OF pt_name_inst, OF at_name_inst])
  ultimately show ?thesis using assms
    by(drule_tac perm="rev perm" in eqvtChainI, simp)
qed

lemma eqvtChainEq:
  fixes P    :: pi
  and   P'   :: pi
  and   perm :: "name prm"

  shows   "P \<Longrightarrow>\<^isub>\<tau> P' = (perm \<bullet> P) \<Longrightarrow>\<^isub>\<tau> (perm \<bullet> P')"
by(blast intro: eqvtChainE eqvtChainI)

lemma freshChain:
  fixes P  :: pi
  and   P' :: pi
  and   x  :: name
  
  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     "x \<sharp> P"
 
  shows   "x \<sharp> P'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P' P'')
  have "x \<sharp> P" and "x \<sharp> P \<Longrightarrow> x \<sharp> P'" by fact+
  hence "x \<sharp> P'" by simp
  moreover have "P' \<longmapsto> \<tau> \<prec> P''" by fact
  ultimately show ?case by(force intro: freshTransition)
qed

lemma matchChain:
  fixes b :: name
  and   P :: pi
  and   P' :: pi
  
  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     "P \<noteq> P'"
 
  shows "[b\<frown>b]P \<Longrightarrow>\<^isub>\<tau> P'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P'' P''')
  have P''TransP''':  "P'' \<longmapsto>\<tau> \<prec> P'''"  by fact
  show "[b\<frown>b]P \<Longrightarrow>\<^isub>\<tau> P'''" 
  proof(cases "P = P''")
    assume "P=P''"
    moreover with P''TransP''' have "[b\<frown>b]P \<longmapsto>\<tau> \<prec> P'''" by(force intro: Match)
    thus "[b\<frown>b]P \<Longrightarrow>\<^isub>\<tau> P'''" by(rule tauActTauChain)
  next
    assume "P \<noteq> P''"
    moreover have "P \<noteq> P'' \<Longrightarrow> [b\<frown>b]P \<Longrightarrow>\<^isub>\<tau> P''" by fact
    ultimately show "[b\<frown>b]P \<Longrightarrow>\<^isub>\<tau> P'''" using P''TransP''' by(blast)
  qed
qed

lemma mismatchChain:
  fixes a :: name
  and   b :: name
  and   P :: pi
  and   P' :: pi
  
  assumes PChain: "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     aineqb: "a \<noteq> b"
  and     PineqP': "P \<noteq> P'"
 
  shows "[a\<noteq>b]P \<Longrightarrow>\<^isub>\<tau> P'"
proof -
  from PChain PineqP' show ?thesis
  proof(induct rule: tauChainInduct)
    case id
    thus ?case by simp
  next
    case(ih P'' P''')
    have P''TransP''':  "P'' \<longmapsto>\<tau> \<prec> P'''"  by fact
    show "[a\<noteq>b]P \<Longrightarrow>\<^isub>\<tau> P'''" 
    proof(cases "P = P''")
      assume "P=P''"
      moreover with aineqb P''TransP''' have "[a\<noteq>b]P \<longmapsto>\<tau> \<prec> P'''" by(force intro: Mismatch)
      thus "[a\<noteq>b]P \<Longrightarrow>\<^isub>\<tau> P'''" by(rule tauActTauChain)
    next
      assume "P \<noteq> P''"
      moreover have "P \<noteq> P'' \<Longrightarrow> [a\<noteq>b]P \<Longrightarrow>\<^isub>\<tau> P''" by fact
      ultimately show "[a\<noteq>b]P \<Longrightarrow>\<^isub>\<tau> P'''" using P''TransP''' by(blast)
    qed
  qed
qed

lemma sum1Chain:
  fixes P  :: pi
  and   P' :: pi
  and   Q  :: pi

  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     "P \<noteq> P'"
 
  shows "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> P'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P'' P''')
  have P''TransP''':  "P'' \<longmapsto>\<tau> \<prec> P'''" by fact
  show "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> P'''"
  proof(cases "P = P''")
    assume "P=P''"
    moreover with P''TransP''' have "P \<oplus> Q \<longmapsto>\<tau> \<prec> P'''" by(force intro: Sum1)
    thus "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> P'''" by(force intro: tauActTauChain)
  next
    assume "P \<noteq> P''"
    moreover have "P \<noteq> P'' \<Longrightarrow> P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> P''" by fact
    ultimately show "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> P'''" using P''TransP''' by(force dest: tauActTauChain)
  qed
qed

lemma sum2Chain:
  fixes P  :: pi
  and   Q :: pi
  and   Q'  :: pi

  assumes "Q \<Longrightarrow>\<^isub>\<tau> Q'"
  and     "Q \<noteq> Q'"
 
  shows "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> Q'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih Q'' Q''')
  have Q''TransQ''':  "Q'' \<longmapsto>\<tau> \<prec> Q'''" by fact
  show "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> Q'''"
  proof(cases "Q = Q''")
    assume "Q=Q''"
    moreover with Q''TransQ''' have "P \<oplus> Q \<longmapsto>\<tau> \<prec> Q'''" by(force intro: Sum2)
    thus "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> Q'''" by(force intro: tauActTauChain)
  next
    assume "Q \<noteq> Q''"
    moreover have "Q \<noteq> Q'' \<Longrightarrow> P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> Q''" by fact
    ultimately show "P \<oplus> Q \<Longrightarrow>\<^isub>\<tau> Q'''" using Q''TransQ''' by blast
  qed
qed

lemma Par1Chain:
  fixes P  :: pi
  and   P' :: pi
  and   Q  :: pi

  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"

  shows "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P' \<parallel> Q"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P'' P')
  have P''TransP':  "P'' \<longmapsto>\<tau> \<prec> P'" by fact
  have IH: "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P'' \<parallel> Q" by fact
  
  have "P'' \<parallel> Q \<longmapsto>\<tau> \<prec> P' \<parallel> Q" using P''TransP' by(force intro: Par1F)
  thus "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P' \<parallel> Q" using IH by(force dest: tauActTauChain)
qed

lemma Par2Chain:
  fixes P  :: pi
  and   Q  :: pi
  and   Q' :: pi

  assumes "Q \<Longrightarrow>\<^isub>\<tau> Q'"

  shows "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P \<parallel> Q'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih Q'' Q')
  have Q''TransQ':  "Q'' \<longmapsto>\<tau> \<prec> Q'" by fact
  have IH: "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P \<parallel> Q''" by fact
  
  have "P \<parallel> Q'' \<longmapsto>\<tau> \<prec> P \<parallel> Q'" using Q''TransQ' by(force intro: Par2F)
  thus "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P \<parallel> Q'" using IH by(force dest: tauActTauChain)
qed

lemma chainPar:
  fixes P  :: pi
  and   P' :: pi
  and   Q  :: pi
  and   Q' :: pi
  
  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"
  and     "Q \<Longrightarrow>\<^isub>\<tau> Q'"

  shows "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P' \<parallel> Q'"
proof -
  from `P \<Longrightarrow>\<^isub>\<tau> P'` have "P \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P' \<parallel> Q" by(rule Par1Chain)
  moreover from `Q \<Longrightarrow>\<^isub>\<tau> Q'` have "P' \<parallel> Q \<Longrightarrow>\<^isub>\<tau> P' \<parallel> Q'" by(rule Par2Chain)
  ultimately show ?thesis by auto
qed

lemma ResChain:
  fixes P  :: pi
  and   P' :: pi
  and   a  :: name

  assumes "P \<Longrightarrow>\<^isub>\<tau> P'"

  shows "<\<nu>a>P \<Longrightarrow>\<^isub>\<tau> <\<nu>a>P'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P'' P''')
  have "P'' \<longmapsto>\<tau> \<prec> P'''" by fact
  hence "<\<nu>a>P'' \<longmapsto>\<tau> \<prec> <\<nu>a>P'''" by(force intro: ResF)
  moreover have "<\<nu>a>P \<Longrightarrow>\<^isub>\<tau> <\<nu>a>P''" by fact
  ultimately show ?case by(force dest: tauActTauChain)
qed

lemma substChain:
  fixes P  :: pi
  and   x  :: name
  and   b  :: name
  and   P' :: pi

  assumes PTrans: "P[x::=b] \<Longrightarrow>\<^isub>\<tau> P'"

  shows "P[x::=b] \<Longrightarrow>\<^isub>\<tau> P'[x::=b]"
proof(cases "x=b")
  assume "x = b"
  with PTrans show ?thesis by simp
next
  assume "x \<noteq> b"
  hence "x \<sharp> P[x::=b]" by(simp add: fresh_fact2)
  with PTrans have "x \<sharp> P'" by(force intro: freshChain)
  hence "P' = P'[x::=b]" by(simp add: forget)
  with PTrans show ?thesis by simp
qed

lemma bangChain:
  fixes P  :: pi
  and   P' :: pi

  assumes PTrans: "P \<parallel> !P \<Longrightarrow>\<^isub>\<tau> P'"
  and     P'ineq: "P' \<noteq> P \<parallel> !P"

  shows "!P \<Longrightarrow>\<^isub>\<tau> P'"
using assms
proof(induct rule: tauChainInduct)
  case id
  thus ?case by simp
next
  case(ih P' P'')
  show ?case
  proof(cases "P' = P \<parallel> !P")
    case True
    from `P' \<longmapsto>\<tau> \<prec> P''` `P' = P \<parallel> !P` have "!P \<longmapsto>\<tau> \<prec> P''" by(blast intro: Bang)
    thus ?thesis by auto
  next
    case False
    from `P' \<noteq> P \<parallel> !P` have "!P \<Longrightarrow>\<^isub>\<tau> P'" by(rule ih)
    with `P' \<longmapsto>\<tau> \<prec> P''` show ?thesis by(auto dest: tauActTauChain)
  qed
qed

end