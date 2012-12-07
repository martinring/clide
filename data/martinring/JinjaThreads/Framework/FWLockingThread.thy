(*  Title:      JinjaThreads/Framework/FWLockingThread.thy
    Author:     Andreas Lochbihler
*)

header {* \isaheader{Semantics of the thread action ReleaseAcquire for the thread state} *}

theory FWLockingThread
imports
  FWLocking
begin

fun upd_threadR :: "nat \<Rightarrow> 't lock \<Rightarrow> 't \<Rightarrow> lock_action \<Rightarrow> nat"
where
  "upd_threadR n l t ReleaseAcquire = n + has_locks l t"
| "upd_threadR n l t _ = n"

primrec upd_threadRs :: "nat \<Rightarrow> 't lock \<Rightarrow> 't \<Rightarrow> lock_action list \<Rightarrow> nat"
where
  "upd_threadRs n l t [] = n"
| "upd_threadRs n l t (la # las) = upd_threadRs (upd_threadR n l t la) (upd_lock l t la) t las"

lemma upd_threadRs_append [simp]:
  "upd_threadRs n l t (las @ las') = upd_threadRs (upd_threadRs n l t las) (upd_locks l t las) t las'"
by(induct las arbitrary: n l, auto)

definition redT_updLns :: "('l,'t) locks \<Rightarrow> 't \<Rightarrow> ('l \<Rightarrow>\<^isub>f nat) \<Rightarrow> 'l lock_actions \<Rightarrow> ('l \<Rightarrow>\<^isub>f nat)"
where "redT_updLns ls t ln las = (\<lambda>(l, n, la). upd_threadRs n l t la) \<circ>\<^isub>f (ls, (ln, las)\<^sup>f)\<^sup>f"

lemma redT_updLns_iff [simp]:
  "(redT_updLns ls t ln las)\<^sub>f l = upd_threadRs (ln\<^sub>f l) (ls\<^sub>f l) t (las\<^sub>f l)"
by(simp add: redT_updLns_def)

lemma upd_threadRs_comp_empty [simp]: "(\<lambda>(l, n, las). upd_threadRs n l t las) \<circ>\<^isub>f (ls, (lns, \<lambda>\<^isup>f [])\<^sup>f)\<^sup>f = lns"
by(auto intro!: finfun_ext)

lemma redT_updLs_empty [simp]: "redT_updLs ls t (\<lambda>\<^isup>f []) = ls"
by(simp add: redT_updLs_def)

end
